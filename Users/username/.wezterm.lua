local wezterm = require("wezterm")
local config = {}

config.default_domain = "WSL:Ubuntu-24.04"

config.hide_tab_bar_if_only_one_tab = true

config.animation_fps = 1
config.cursor_blink_rate = 0
config.default_cursor_style = "BlinkingBlock"

config.front_end = "WebGpu"
config.max_fps = 120
config.scrollback_lines = 3500

config.window_background_opacity = 0.90
config.text_background_opacity = 0.90 -- 중요: 텍스트 셀 배경도 같이 맞춤

config.keys = {
	{ key = "PageUp", mods = "SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "PageDown", mods = "SHIFT", action = wezterm.action.DisableDefaultAssignment },
}

return config
