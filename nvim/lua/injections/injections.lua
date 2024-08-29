-- TODOs:
-- [ ] Configurable background colour
-- [ ] Configurable source languages
-- [ ] Configurable injection languages

local M = {}
local api = vim.api
local ts = vim.treesitter
local contains = require("config.util").contains
local lines = require("config.util").lines

local opts = require("injections").options

local extensions = {
  python = "py",
  r = "R",
  julia = "jl",
  lua = "lua",
  haskell = "hs",
  bash = "sh",
  html = "html",
  css = "css",
  javascript = "js",
  typescript = "ts",
  yaml = "yml",
  sql = "sql",
}

local injectable_languages = {}
for key, _ in pairs(extensions) do
  table.insert(injectable_languages, key)
end

local buffers = {}

-- Returns a table of languages to found code blocks
local function extract_code_chunks(main_nr)
  main_nr = main_nr or api.nvim_get_current_buf()
  local row, col = unpack(api.nvim_win_get_cursor(0))
  row = row - 1
  col = col

  local buf = buffers[main_nr]
  if buf == nil then
    return nil
  end

  local parser = buf.parser
  local parsername = parser:lang()
  local query = ts.query.get(parsername, "injections")

  local tree = parser:parse()
  local root = tree[1]:root()

  local code_chunks = {}
  local found_chunk = false
  local lang_capture

  for id, node, metadata in query:iter_captures(root, main_nr) do
    local name = query.captures[id]
    local text

    -- chunks where the name of the injected language is dynamic
    -- e.g. markdown code chunks
    if name == "_lang" or name == "language" or name == "injection.language" then
      text = ts.get_node_text(node, main_nr, metadata)
      lang_capture = text
      found_chunk = true
    elseif
      (name == "content" or name == "injection.content")
      and found_chunk
      and (opts.highlight_languages == nil or opts.highlight_languages[lang_capture])
    then
      text = ts.get_node_text(node, main_nr, metadata)

      local row1, col1, row2, col2 = node:range()
      local result = {
        range = { from = { row1, col1 }, to = { row2, col2 } },
        lang = lang_capture,
        node = node,
        text = lines(text),
      }
      if code_chunks[lang_capture] == nil then
        code_chunks[lang_capture] = {}
      end

      table.insert(code_chunks[lang_capture], result)
      found_chunk = false
    elseif contains(injectable_languages, name) then
      -- chunks where the name of the language is the name of the capture
      if opts.highlight_languages == nil or opts.highlight_languages[name] then
        text = ts.get_node_text(node, main_nr, metadata)
        local row1, col1, row2, col2 = node:range()
        local result = {
          range = { from = { row1, col1 }, to = { row2, col2 } },
          lang = name,
          node = node,
          text = lines(text),
        }
        if code_chunks[name] == nil then
          code_chunks[name] = {}
        end
        table.insert(code_chunks[name], result)
      end
    end
  end

  return code_chunks
end

local ns = api.nvim_create_namespace("InjectionsHighlight")
api.nvim_command("highlight InjectionsHighlight guibg=#212436")

local function update_buf(bufnr)
  local chunks = extract_code_chunks()
  if chunks == nil then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for _, results in pairs(chunks) do
    for _, injection in pairs(results) do
      local max_line_length = 0
      for _, line in pairs(injection.text) do
        if #line > max_line_length then
          max_line_length = #line
        end
      end

      local start_row, start_col = injection.range.from[1], injection.range.from[2]

      local pad = 5
      for i, line in pairs(injection.text) do
        local length = #line
        local curr_row = start_row + i - 1
        local full_line = api.nvim_buf_get_lines(0, curr_row, curr_row + 1, false)[1]

        local curr_col
        if i == 1 then
          curr_col = start_col
        else
          curr_col = 0
        end

        -- Set background colour
        api.nvim_buf_set_extmark(bufnr, ns, curr_row, curr_col, {
          virt_text_hide = true,
          end_col = length,
          hl_group = "InjectionsHighlight",
        })

        -- Add padding if necessary
        if length == #full_line then
          api.nvim_buf_set_extmark(bufnr, ns, curr_row, curr_col + length, {
            virt_text = {
              {
                string.rep(" ", max_line_length - length + pad),
                "InjectionsHighlight",
              },
            },
            virt_text_win_col = length,
            virt_text_hide = true,
            hl_group = "InjectionsHighlight",
            priority = 100,
          })
        end
      end
    end
  end
end

-- Highlight injections for the given buffer and register it so that
-- injection highlights can be updated as the buffer is edited
local function add_buf(bufnr)
  local ft = api.nvim_buf_get_option(bufnr, "filetype")
  local parsername = vim.treesitter.language.get_lang(ft)
  if not parsername then
    vim.notify("[injections] no treesitter parser for " .. ft, vim.log.levels.ERROR)
    return false
  end

  local success, parser = pcall(ts.get_parser, bufnr)
  if not success then
    vim.notify("[injections] could not resolve treesitter parser for " .. ft, vim.log.levels.ERROR)
    return false
  end

  buffers[bufnr] = { parser = parser }

  update_buf(bufnr)

  buffers[bufnr].parser:register_cbs({
    on_changedtree = function()
      -- defer updating the buf until the next available tick
      -- as updating immediately can cause severe lag
      vim.defer_fn(function()
        update_buf(bufnr)
      end, 0)
    end,
  })

  return true
end

function M.on()
  local bufnr = api.nvim_get_current_buf()
  if not buffers[bufnr] then
    add_buf(bufnr)
  end
end

function M.off()
  local bufnr = api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  if buffers[bufnr] then
    -- Register an empty function to remove the previous callback
    buffers[bufnr].parser:register_cbs({ on_changedtree = function() end })
    buffers[bufnr] = nil
  end
end

function M.toggle()
  local bufnr = api.nvim_get_current_buf()
  if buffers[bufnr] then
    M.off()
  else
    M.on()
  end
end

return M
