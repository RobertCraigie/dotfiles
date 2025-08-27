-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.swapfile = false

-- Enable mouse mode
vim.o.mouse = "a"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Improve colours
vim.o.termguicolors = true

-- Make line numbers default
vim.wo.number = true
vim.o.relativenumber = true

-- project local config
vim.opt.exrc = true

-- reduce scrollback count for improved perf
vim.o.scrollback = 1000

-- rounded border for every floating window
vim.o.winborder = "rounded"
