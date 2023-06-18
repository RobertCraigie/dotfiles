local M = {}

M.options = {
  -- TODO
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})

  vim.api.nvim_create_user_command("Injection", require("injections").toggle, {})
  vim.api.nvim_create_user_command("InjectionOn", require("injections").on, {})
  vim.api.nvim_create_user_command("InjectionOff", require("injections").off, {})
end

return setmetatable(M, {
  __index = function(_, k)
    return require("injections.injections")[k]
  end,
})
