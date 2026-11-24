local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 12.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Turn the current pane into an agent workspace: agents stack top to bottom
-- on the left, yazi (file explorer) takes the right 30%. Commands are typed
-- into shells (not spawned directly) so panes stay open after you quit them.
-- Same layouts as herdr's prefix+o/i/u (home/.config/herdr/layout.sh).
local function agent_layout(top, bottom)
  return wezterm.action_callback(function(_, pane)
    pane:split({ direction = "Right", size = 0.3 }):send_text("yazi\n")
    if bottom then
      pane:split({ direction = "Bottom", size = 0.5 }):send_text(bottom .. "\n")
    end
    pane:send_text(top .. "\n")
  end)
end

config.keys = {
  -- No title bar to double-click, so Cmd+Enter fills the screen instead.
  {
    key = "Enter",
    mods = "CMD",
    action = wezterm.action_callback(function(window)
      window:maximize()
    end),
  },
  { key = "o", mods = "CMD|SHIFT", action = agent_layout("codex") },
  { key = "i", mods = "CMD|SHIFT", action = agent_layout("claude") },
  { key = "u", mods = "CMD|SHIFT", action = agent_layout("claude", "codex") },
}

return config
