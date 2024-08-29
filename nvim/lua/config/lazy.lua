-- TODO:
-- - [ ] Support custom prettier
-- - [ ] Support "workspaces" & showing the full relative file path
-- - [ ] Try out the git plugins
-- - [ ] Use treesitter context plugin
-- - [ ] Auto formatting
-- - [ ] Lazy load more plugins

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.keymaps")
require("config.groups")
require("config.files")

-- TODO: move local plugins to proper structure so this isn't needed
require("config.local")

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})

require("oil").setup()
