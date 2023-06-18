-- setup for local plugins
require("injections").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"typescript"},
  callback = function()
    require("injections").on()
  end,
})
