return {
  {
    "kylechui/nvim-surround",
    version = "*",
    config = function(_, opts)
      require("nvim-surround").setup(opts)
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
}
