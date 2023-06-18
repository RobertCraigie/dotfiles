-- setup for local plugins
require("injections").setup({
  highlight_languages = { "python", "go", "typescript", "kotlin", "java" },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript" },
  callback = function()
    require("injections").on()
  end,
})
