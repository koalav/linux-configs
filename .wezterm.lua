local wezterm = require("wezterm")
local config = {}

-- 탭 숨기기
config.enable_tab_bar = false

-- 기본 WSL 실행
config.default_domain = "WSL:Debian"

config.color_scheme = "AdventureTime"

config.keys = {
	-- (A) Shift+PgUp/PgDn : WezTerm 스크롤백(기본) 해제 → 앱(Zellij)로 전달
	{ key = "PageUp", mods = "SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "PageDown", mods = "SHIFT", action = wezterm.action.DisableDefaultAssignment },
}

return config
