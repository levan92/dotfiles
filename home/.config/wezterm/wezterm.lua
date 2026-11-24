local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 12.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- No title bar to double-click, so Cmd+Enter fills the screen instead.
config.keys = {
  {
    key = "Enter",
    mods = "CMD",
    action = wezterm.action_callback(function(window)
      window:maximize()
    end),
  },
}

return config
