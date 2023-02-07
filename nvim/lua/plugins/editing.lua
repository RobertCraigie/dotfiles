return {
  {
    "kylechui/nvim-surround",
    version = "*",
    config = function(_, opts)
      require("nvim-surround").setup(opts)
    end,
  },

  {
    "ggandor/leap.nvim",
    dependencies = {
      "tpope/vim-repeat",
    },
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- Add blank lines to scrolloff at the end of the file
  {
    "Aasim-A/scrollEOF.nvim",
    opts = {
      pattern = "*",
    },
    config = function(_, opts)
      vim.o.scrolloff = 20
      require("scrollEOF").setup(opts)
    end,
  },

  -- Improve working with comments
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup()
    end,
  },

  -- Support for multiple cursors
  {
    "mg979/vim-visual-multi",
  },

  -- Detect tabstop and shiftwidth automatically
  {
    "tpope/vim-sleuth",
  },

  -- Add indentation guides even on blank lines
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = "┊",
      show_trailing_blankline_indent = false,
    },
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    config = function(_, opts)
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local ufo = require("ufo")
      vim.keymap.set("n", "zR", ufo.openAllFolds)
      vim.keymap.set("n", "zM", ufo.closeAllFolds)

      ufo.setup()
    end,
  },
}
