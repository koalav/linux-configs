{ pkgs }:


with pkgs; [
  syncthing
  ddgr
  fabric-ai
  yt-dlp
  podman podman-compose podman-tui
  gocryptfs 

  vdirsyncer khal

  # --- 기본 ---
  taskwarrior3
  timewarrior

  marksman
  #(nerd-fonts.override { fonts = [ "Hack" ]; })
  nerd-fonts.hack

  # Base Utils

  curl git wget unzip gnutar gnumake
  fzf jq ripgrep fd bottom tealdeer
  ffmpeg imagemagick poppler-utils p7zip


  # Modern Unix Tools
  eza bat dust zoxide hyperfine difftastic yazi

  # Charm / TUI
  glow mods
  lazygit lazydocker

  zellij

  # Dev base
  uv httpie mitmproxy tree-sitter
  helix

  # GitHub / Python quality
  gh ruff pyright


  # SSH (바이너리만. 서비스 enable은 OS에서)
  openssh


  # Misc tools
  gping fx croc tty-clock
  # dog / up 은 채널에 따라 이름/존재가 달라질 수 있어 필요 시 hm-addpkg로 조정
  # dog
  # doggo
  # up


  # Android (2번 방식: SDK/NDK는 Studio에서 설치/관리)
  android-studio
  android-tools
  jdk17 gradle cmake ninja pkg-config clang

  # Java/Kotlin/Python
  maven
  kotlin kotlin-language-server
  jdt-language-server


  # LangChain 작업 보조(로컬 개발/테스트)
  sqlite


  # DB/packet/network/tools
  visidata
  # lazysql은 채널에 따라 없을 수 있음 -> 있으면 켜고 없으면 주석/대체
  # lazysql

  wireshark-cli   # tshark 포함(보통 GUI 없는 쪽)
  ngrep
  bettercap
  gron
  ffuf
  httpx
  sqlmap
  termshark
  #wireshark
  ngrep
  iftop
  bmon
  rustscan

  # --- Helix LSP Servers ---

  # Java
  jdt-language-server


  # JS/TS
  nodePackages.typescript-language-server

  # Python

  pyright

  # Go
  gopls

  # Bash
  nodePackages.bash-language-server

  # C/C++
  clang-tools      # clangd 포함

  # CMake
  cmake-language-server


  # CSS/HTML/JSON

  nodePackages.vscode-langservers-extracted

  # YAML
  nodePackages.yaml-language-server

  # SQL
  sqls

  # --- AUTO-ADD START ---

  # hm-addpkg가 여기에 자동으로 추가함
  # --- AUTO-ADD END ---
]



