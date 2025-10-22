local Util = require("config.util.lsp")

vim.lsp.config('dprint', {
  cmd = { "pnpm", "dprint", "lsp" },
  on_attach = Util.on_attach,
})
vim.lsp.enable('dprint')

vim.lsp.enable('prettier', false)
vim.lsp.enable('prettierd', false)

require('conform').setup({
  log_level = vim.log.levels.DEBUG,
  formatters_by_ft = {
    lua = { "stylua" },
    zsh = { "shfmt" },
    php = { "php_cs_fixer" },
    python = { "ruff" },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    ocaml = { "ocamlformat" },
    javascript = { "dprint" },
    typescript = { "dprint" },
    css = { "dprint" },
    markdown = { "dprint" },
    jsonc = { "dprint" },
    html = { "dprint" },
  },
})
