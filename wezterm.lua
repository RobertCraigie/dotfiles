local wezterm = require("wezterm")
local utils = require("wezterm_utils")

local config = wezterm.config_builder()

-- contenders
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("Cascadia Mono", { weight = "Regular", stretch = "Expanded" })

-- other font options
-- config.font = wezterm.font("JetBrains Mono")
-- config.font = wezterm.font("Berkeley Mono Trial", { stretch = "Expanded" })
-- config.font = wezterm.font("Monaco")
-- config.font = wezterm.font("Iosevka Term", { stretch = "UltraExpanded" })
-- config.font = wezterm.font("IBM Plex Mono", { stretch = "Expanded" })

-- Tabs
config.enable_tab_bar = false
-- config.use_fancy_tab_bar = false
-- config.hide_tab_bar_if_only_one_tab = true

-- Panes
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.6,
}

-- Hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Custom rule for opening file paths in neovim
wezterm.on("open-uri", utils.on_uri_open)
table.insert(config.hyperlink_rules, {
  regex = "(/)?[A-Za-z0-9_-]+/[/.A-Za-z0-9_-]*\\.[A-Za-z0-9]+(:\\d+)*(?=\\s*|$)",
  format = "$EDITOR:$0",
})

-- Make `user/project` paths clickable, assuming they map to github URLs e.g.
-- ( "nvim-treesitter/nvim-treesitter" | wez/wezterm | "wez/wezterm.git" )
table.insert(config.hyperlink_rules, {
  -- regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  regex = [[(?<!│\s)["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = "https://www.github.com/$1/$3",
})

-- https://wezfurlong.org/wezterm/config/lua/config/window_padding.html
config.window_padding = {
  -- left = 2,
  -- right = 2,
  -- top = 0,
  bottom = 0,
}

-- keys
-- https://wezfurlong.org/wezterm/config/keys.html
config.leader = { key = "Space", mods = "CMD", timeout_milliseconds = 1000 }

config.keys = {
  {
    key = "p",
    mods = "CMD",
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    key = "p",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    key = "b",
    mods = "LEADER",
    action = wezterm.action.ShowTabNavigator,
  },
  {
    key = "Enter",
    mods = "CMD|SHIFT",
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = "q",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({ confirm = false }),
  },
  {
    key = "]",
    mods = "CMD",
    action = wezterm.action_callback(function(window)
      utils.cycle_panes(window, "Right")
    end),
  },
  {
    key = "[",
    mods = "CMD",
    action = wezterm.action_callback(function(window)
      utils.cycle_panes(window, "Left")
    end),
  },

  -- tables
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action.ActivateKeyTable({
      name = "resize_pane",
      one_shot = false,
    }),
  },
  {
    key = "s",
    mods = "LEADER",
    action = wezterm.action.ActivateKeyTable({
      name = "split_pane",
      one_shot = true,
    }),
  },
}

config.key_tables = {
  resize_pane = {
    { key = "LeftArrow", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
    { key = "h", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },

    { key = "RightArrow", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
    { key = "l", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },

    { key = "UpArrow", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
    { key = "k", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },

    { key = "DownArrow", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
    { key = "j", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },

    -- Cancel the mode by pressing escape
    { key = "Escape", action = "PopKeyTable" },
  },

  split_pane = {
    { key = "LeftArrow", action = wezterm.action.SplitPane({ direction = "Left" }) },
    { key = "h", action = wezterm.action.SplitPane({ direction = "Left" }) },

    { key = "RightArrow", action = wezterm.action.SplitPane({ direction = "Right" }) },
    { key = "l", action = wezterm.action.SplitPane({ direction = "Right" }) },

    { key = "UpArrow", action = wezterm.action.SplitPane({ direction = "Up" }) },
    { key = "k", action = wezterm.action.SplitPane({ direction = "Up" }) },

    { key = "DownArrow", action = wezterm.action.SplitPane({ direction = "Down" }) },
    { key = "j", action = wezterm.action.SplitPane({ direction = "Down" }) },

    -- Cancel the mode by pressing escape
    { key = "Escape", action = "PopKeyTable" },
  },
}

return config
