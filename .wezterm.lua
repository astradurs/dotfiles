local wezterm = require('wezterm')
local config = {}

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
config.window_decorations = 'TITLE | RESIZE'
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 5,
}

-- Tab bar appearance
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 60

-- ============================================================================
-- STATUS BAR / DASHBOARD
-- ============================================================================

-- Helper function to get git branch and status
local function get_git_info(cwd)
  if not cwd then return nil end

  local success, stdout, stderr = wezterm.run_child_process({
    'git',
    '-C',
    cwd,
    'rev-parse',
    '--abbrev-ref',
    'HEAD'
  })

  if not success then return nil end

  local branch = stdout:gsub('%s+', '')

  -- Check if repo is dirty
  local status_success, status_stdout = wezterm.run_child_process({
    'git',
    '-C',
    cwd,
    'status',
    '--porcelain'
  })

  local is_dirty = status_success and status_stdout ~= ''

  return {
    branch = branch,
    is_dirty = is_dirty
  }
end

-- Helper function to shorten directory path
local function shorten_path(path)
  local home = os.getenv('HOME')
  if path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end

  -- Shorten intermediate directories
  local parts = {}
  for part in path:gmatch('[^/]+') do
    table.insert(parts, part)
  end

  if #parts > 3 then
    local shortened = {}
    table.insert(shortened, parts[1])
    table.insert(shortened, '...')
    table.insert(shortened, parts[#parts - 1])
    table.insert(shortened, parts[#parts])
    return table.concat(shortened, '/')
  end

  return path
end

-- Format tab title with directory and git info
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local cwd = pane.current_working_dir
  local cwd_path = ''

  if cwd then
    if type(cwd) == 'table' and cwd.file_path then
      cwd_path = cwd.file_path
    elseif type(cwd) == 'string' then
      cwd_path = cwd:gsub('file://[^/]*', '')
    end
  end

  local title = tab.tab_index + 1 .. ': '

  -- Add process name
  local process_name = pane.foreground_process_name
  if process_name then
    process_name = process_name:match('([^/]+)$') or process_name
    title = title .. process_name .. ' '
  end

  -- Add directory
  if cwd_path ~= '' then
    local short_path = shorten_path(cwd_path)
    title = title .. '(' .. short_path .. ')'
  end

  -- Add git info
  if cwd_path ~= '' then
    local git_info = get_git_info(cwd_path)
    if git_info then
      local git_status = git_info.is_dirty and '●' or '✓'
      title = title .. ' [' .. git_info.branch .. ' ' .. git_status .. ']'
    end
  end

  -- Truncate if too long
  if #title > max_width - 2 then
    title = title:sub(1, max_width - 5) .. '...'
  end

  return {
    { Text = ' ' .. title .. ' ' },
  }
end)

-- Right status - shows time, battery, and hostname
wezterm.on('update-right-status', function(window, pane)
  local cells = {}

  -- Current time
  local time = wezterm.strftime('%H:%M')
  table.insert(cells, wezterm.format({
    { Foreground = { Color = '#8be9fd' } },
    { Text = '🕐 ' .. time },
  }))

  -- Battery status
  for _, b in ipairs(wezterm.battery_info()) do
    local battery_icon = '🔋'
    if b.state == 'Charging' then
      battery_icon = '⚡'
    elseif b.state_of_charge < 0.2 then
      battery_icon = '🪫'
    end

    table.insert(cells, wezterm.format({
      { Foreground = { Color = '#50fa7b' } },
      { Text = ' ' .. battery_icon .. string.format('%.0f%%', b.state_of_charge * 100) },
    }))
  end

  -- Hostname
  local hostname = wezterm.hostname()
  table.insert(cells, wezterm.format({
    { Foreground = { Color = '#ff79c6' } },
    { Text = ' 💻 ' .. hostname },
  }))

  window:set_right_status(table.concat(cells, ' | '))
end)

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
