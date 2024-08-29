local wezterm = require("wezterm")

local M = {}

function M.cycle_panes(window, direction)
  local pane = window:active_pane()
  local tab = pane:tab()
  local panes = tab:panes()
  local num_panes = #panes
  local current_index = 0

  for i, p in ipairs(panes) do
    if p:pane_id() == pane:pane_id() then
      current_index = i
      break
    end
  end

  local new_index
  if direction == "Right" then
    new_index = (current_index % num_panes) + 1
  else
    new_index = ((current_index - 2 + num_panes) % num_panes) + 1
  end

  panes[new_index]:activate()
end

-- File hyperlinks
local function extract_filename(uri)
  local start, match_end = uri:find("$EDITOR:")
  if start == 1 then
    -- skip past the colon
    return uri:sub(match_end + 1)
  end

  -- `file://hostname/path/to/file`
  start, match_end = uri:find("file:")
  if start == 1 then
    -- skip "file://", -> `hostname/path/to/file`
    local host_and_path = uri:sub(match_end + 3)
    start, match_end = host_and_path:find("/")
    if start then
      -- -> `/path/to/file`
      return host_and_path:sub(match_end)
    end
  end

  return nil
end

local function extract_line_and_name(uri)
  local name = extract_filename(uri)

  if name then
    local line = 1
    -- check if name has a line number (e.g. `file:.../file.txt:123 or file:.../file.txt:123:456`)
    local start, match_end = name:find(":[0-9]+")
    if start then
      -- line number is 123
      line = name:sub(start + 1, match_end)
      -- remove the line number from the filename
      name = name:sub(1, start - 1)
    end

    return line, name
  end

  return nil, nil
end

local function get_pwd(pane)
  local pwd = pane:get_current_working_dir()
  return pwd.file_path
end

local function open_in_nvim(window, pane, full_path, line)
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab({
      args = { "/Users/robert/.local/share/bob/nvim-bin/nvim", "+" .. line, full_path },
    }),
    pane
  )
end

local function join_paths(...)
  local parts = { ... }
  local result = parts[1]
  for i = 2, #parts do
    local part = parts[i]
    if part:sub(1, 1) == "/" then
      -- If part is an absolute path, it overrides the previous result
      result = part
    else
      -- If part is relative, append it to the result
      result = result .. "/" .. part
    end
  end

  -- Normalize the path by removing any double slashes and resolving '..' and '.'
  result = result:gsub("//+", "/")
  local stack = {}
  for dir in result:gmatch("[^/]+") do
    if dir == ".." then
      if #stack > 0 and stack[#stack] ~= ".." then
        table.remove(stack)
      else
        table.insert(stack, dir)
      end
    elseif dir ~= "." then
      table.insert(stack, dir)
    end
  end

  result = "/" .. table.concat(stack, "/")
  return result
end

function M.on_uri_open(window, pane, uri)
  local line, name = extract_line_and_name(uri)

  if name then
    local pwd = get_pwd(pane)
    local full_path = join_paths(pwd, name)
    print("pwd", pwd)
    print("name", name)
    print("full_path", full_path)
    open_in_nvim(window, pane, full_path, line)

    -- prevent the default action from opening
    return false
  end

  if uri:find("mailto:") == 1 then
    return false -- disable opening email
  end
end
-- end file hyperlinks

-- function M.

return M
