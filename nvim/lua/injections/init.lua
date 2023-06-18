local to_set = require('config.util').to_set

local M = {}

M.options = {
  -- TODO
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})

  -- convert to a `set` for more performant lookups later
  if M.options.highlight_languages then
    M.options.highlight_languages = to_set(M.options.highlight_languages)
  end

  vim.api.nvim_create_user_command("Injection", require("injections").toggle, {})
  vim.api.nvim_create_user_command("InjectionOn", require("injections").on, {})
  vim.api.nvim_create_user_command("InjectionOff", require("injections").off, {})
end

return setmetatable(M, {
  __index = function(_, k)
    return require("injections.injections")[k]
  end,
})
