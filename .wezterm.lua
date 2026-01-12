local wezterm = require('wezterm')
local config = {}
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ============================================================================
-- APPEARANCE
-- ============================================================================

-- Color scheme - choose your favorite
config.color_scheme = 'Tokyo Night'

-- Font configuration
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'FiraCode Nerd Font',
  'Menlo',
})
config.font_size = 13.0

-- Window appearance
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 5,
}

-- Disable native tab bar (tabline plugin handles tabs)
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- Tab bar font size
config.window_frame = {
  font = wezterm.font({ family = 'JetBrains Mono', weight = 'Bold' }),
  font_size = 14.0,
}

-- ============================================================================
-- TABLINE SETUP
-- ============================================================================

tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'Tokyo Night',
    tabs_enabled = true,
    section_separators = {
      left = '',
      right = '',
    },
    component_separators = {
      left = '|',
      right = '|',
    },
    tab_separators = {
      left = '',
      right = '',
    },
    theme_overrides = {
      tab_active = {
        bg_color = '#7aa2f7',
        fg_color = '#1a1b26',
      },
      tab_inactive = {
        bg_color = '#292e42',
        fg_color = '#545c7e',
      },
    },
  },
  sections = {
    tabline_a = {},
    tabline_b = { 'workspace' },
    tabline_c = { ' ' },
    tab_active = {
      'index',
      { 'cwd', padding = { left = 2, right = 2, top = 1, bottom = 1 } },
      { 'zoomed', padding = 0 },
    },
    tab_inactive = {
      'index',
      { 'process', padding = { left = 2, right = 2, top = 1, bottom = 1 } }
    },
    tabline_x = { 'ram', 'cpu' },
    tabline_y = { 'datetime', 'battery' },
    tabline_z = {},
  },
  extensions = {},
})

-- ============================================================================
-- KEY BINDINGS
-- ============================================================================

config.keys = {
  -- Split panes
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
  },

  -- Navigate panes
  {
    key = 'LeftArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection('Left'),
  },
  {
    key = 'RightArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection('Right'),
  },
  {
    key = 'UpArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection('Up'),
  },
  {
    key = 'DownArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection('Down'),
  },

  -- Close pane
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },

  -- Rename tab
  {
    key = 'r',
    mods = 'CMD|SHIFT',
    action = wezterm.action.PromptInputLine({
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

-- ============================================================================
-- PERFORMANCE
-- ============================================================================

config.scrollback_lines = 10000
config.enable_scroll_bar = false

return config
