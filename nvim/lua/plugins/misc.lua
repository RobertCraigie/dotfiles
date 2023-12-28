return {
  -- In-browser editing
  {
    "subnut/nvim-ghost.nvim",
  },

  {
    "anuvyklack/hydra.nvim",
  },

  -- For learning Vim
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },

  {
    "folke/which-key.nvim",
    config = function(_, opts)
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup(opts)
    end,
  },

  -- JSON Path helpers
  {
    "mogelbrod/vim-jsonpath",
    ft = "json",
    config = function()
      vim.g.jsonpath_register = ""
    end,
    keys = {
      { "<leader>jp", "<cmd>JsonPath<cr>", desc = "Yank the current JSON path" },
    },
  },

  {
    "folke/neoconf.nvim",
    config = function ()
      require("neoconf").setup(require("config.conf"))
    end
  },
}
