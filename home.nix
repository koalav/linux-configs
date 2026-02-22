{ config, pkgs, lib, ... }:


{
  # -------------------------------------------------------
  # Home 기본
  # -------------------------------------------------------
  home.username = "sangjin";
  home.homeDirectory = "/home/sangjin";
  home.stateVersion = "25.11";

  # 기존 dotfile 충돌 시 백업(처음 적용 때 특히 유용)
  # home-manager.backupFileExtension = "hm-bak";


  # Android Studio 등 unfree 필요
  nixpkgs.config.allowUnfree = true;

  # 공용 환경 변수 (bash/fish 공통)
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    # 필요하면 Android/Gradle용 JAVA_HOME 고정:
    # JAVA_HOME = \"${pkgs.jdk17}/lib/openjdk\";
  };

  home.sessionPath = [
    "/home/sangjin/.local/bin"
  ];


  # 패키지 목록은 별도 파일로 분리
  home.packages = import ./packages.nix { inherit pkgs; };

  # -------------------------------------------------------
  # 프로그램 설정
  # -------------------------------------------------------
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  programs.starship = {
    enable = true;

    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

  };


  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };


  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

 home.file.".task/hooks/on-modify.timewarrior" = {
    source = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
    executable = true;
  };

  # syncthing service 정의 
  services.syncthing.enable = true;

  # HM 모듈의 기본 ExecStart(-no-browser...)를 Syncthing 2.x 방식으로 강제 교체
  systemd.user.services.syncthing.Service.ExecStart = lib.mkForce
    "${pkgs.syncthing}/bin/syncthing --no-browser --no-restart --logflags=0";

  # podman
  # 1. Podman 서비스 정의
  systemd.user.services.podman = {
    Unit = {
      Description = "Podman API Service";
      Documentation = "man:podman-system-service(1)";
    };
    Service = {
      Type = "exec";
      KillMode = "process";
      ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
    };
  };

  # 2. Podman 소켓 정의 (이게 있어야 lazydocker가 연결됨)
  systemd.user.sockets.podman = {
    Unit = {
      Description = "Podman API Socket";
    };
    Socket = {
      ListenStream = "%t/podman/podman.sock"; # %t는 $XDG_RUNTIME_DIR을 의미합니다.
      SocketMode = "0600";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
    };
  };

  # 3. lazydocker가 소켓을 찾을 수 있도록 환경 변수 설정
  home.sessionVariables = {
    DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
  };

  # fish를 주력으로
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -alh --icons --group-directories-first --git";
      lt = "eza --tree --level=2 --icons";
      hmconfig = "hx $HOME/.config/home-manager/home.nix";
    };

    functions = {
      yy = {
        description = "Yazi wrapper for changing directory";
        body = ''
          set -l tmp (mktemp -t "yazi-cwd.XXXXX")
          yazi $argv --cwd-file="$tmp"
          set -l cwd (cat -- "$tmp")
          if test -n "$cwd"; and test "$cwd" != "$PWD"
              cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };

      # 2. Home Manager Package Adder (Python Script Fix)
      hm-addpkg = {
        description = "Append nixpkgs package to packages.nix and switch";
        body = ''
          if test (count $argv) -lt 1
              echo "usage: hm-addpkg <nixpkgs-attr-or-expression>"
              return 1
          end

          set -l pkg $argv[1]
          # Nix 방식의 경로 대신 $HOME을 사용하여 런타임 경로 계산
          set -l target_file (string replace "~" "$HOME" ~/.config/home-manager/packages.nix)

          if not test -f "$target_file"
              echo "Error: packages.nix not found at $target_file"
              return 1
          end

          # Python 스크립트를 변수에 담습니다. (Fish 문법 호환성 확보)
          set -l py_updater "
import sys, pathlib, re

try:
    pkg = sys.argv[1].strip()
    file_path = pathlib.Path(sys.argv[2])
    content = file_path.read_text(encoding='utf-8')

    start_marker = '# --- AUTO-ADD START ---'
    end_marker = '# --- AUTO-ADD END ---'

    if start_marker not in content or end_marker not in content:
        print(f'Error: Markers not found in {file_path}', file=sys.stderr)
        sys.exit(1)

    # 중복 체크
    pattern = re.compile(rf'^\s*{re.escape(pkg)}\s*(#.*)?$', re.M)
    if pattern.search(content):
        sys.exit(2) # 2: 이미 존재함

    # 마커 사이 삽입
    parts = content.split(end_marker)
    pre = parts[0]
    post = end_marker + parts[1]

    if not pre.endswith('\n'): pre += '\n'

    new_content = pre + f'  {pkg}\n' + post
    file_path.write_text(new_content, encoding='utf-8')
    print(f'Added to file: {pkg}')

except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
          "

          # Python 실행
          python3 -c "$py_updater" "$pkg" "$target_file"
          set -l py_status $status

          # 결과 처리
          if test $py_status -eq 0
              echo "🔄 Rebuilding Home Manager..."
              home-manager switch
          else if test $py_status -eq 2
              echo "ℹ️  Package '$pkg' is already in packages.nix"
          else
              echo "❌ Failed to update packages.nix"
              return 1
          end
        '';
    };

    copy = {
      description = "Copy to local clipboard using OSC 52";

      body = ''
        # 1. 터미널에 'OSC 52 시작' 신호를 보냅니다.
        printf "\033]52;c;"

        # 2. 들어오는 입력을 즉시 base64로 인코딩하고, 줄바꿈을 없애서 쏘아 보냅니다.
        #    (변수에 담지 않고 바로 stdout으로 내보냄)
        if count $argv > /dev/null
            # 인자가 있으면 인자를 복사 (예: copy "hello")
            echo -n "$argv" | base64 | tr -d '\n'
        else
            # 인자가 없으면 파이프 입력을 복사 (예: cat file | copy)
            base64 | tr -d '\n'
        end

        # 3. 'OSC 52 종료' 신호를 보냅니다. (\a = Bell)
        printf "\007"

        # (선택사항) 사용자에게 복사되었다고 알림 (stderr로 보내야 파이프 안 꼬임)
        echo " copied to clipboard!" >&2
        '';
      };
    };
    };
   
  # bash는 나중에 쓸 수도 있게 주석 처리
  # programs.bash = {
  #   enable = true;
  #   enableCompletion = true;
  #
  #   shellAliases = {
  #     ls = "eza --icons --group-directories-first";
  #     ll = "eza -alh --icons --group-directories-first --git";
  #     lt = "eza --tree --level=2 --icons";
  #   };
  #
  #   initExtra = ''
  #     function ya() {
  #         local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  #         yazi "$@" --cwd-file="$tmp"
  #
  #         if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
  #             cd -- "$cwd"
  #         fi
  #         rm -f -- "$tmp"
  #     }
  #   '';
  # };

  # 폰트 캐시 자동 갱신
  fonts.fontconfig.enable = true;

  # SSH server enable은 시스템 레벨에서:
  # Ubuntu/Debian:
  #   sudo apt install openssh-server
  #   sudo systemctl enable --now ssh

  # Let Home Manager Install and manage itself.
  programs.home-manager.enable = true;
}

