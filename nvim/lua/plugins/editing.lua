return {
  {
    "kylechui/nvim-surround",
    version = "*",
    config = function(_, opts)
      require("nvim-surround").setup(opts)
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    branch = "main",
    lazy = false,
    enabled = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        debounce = 100,
        modes = { "n", "no", "c" },
        hybrid_modes = { "n" },
        callbacks = {
          on_enable = function(_, win)
            vim.wo[win].conceallevel = 2
            vim.wo[win].conecalcursor = "c"
          end,
        },
      },
    },
  },

  {
    "MagicDuck/grug-far.nvim",
    config = function(_, opts)
      require("grug-far").setup(opts)
    end,
    keys = {
      {
        "<leader>gf",
        "<cmd>:horizontal GrugFar<cr>",
        desc = "[G]rug [F]ar (search/replace)",
        mode = { "n", "v" },
      },
    },
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
      vim.o.scrolloff = 10
      require("scrollEOF").setup(opts)
    end,
  },

  -- Improve working with comments
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup()

      local ft = require("Comment.ft")
      ft.set("typespec", { "//%s", "/*%s*/" })
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  {
    "tpope/vim-sleuth",
  },

  -- Add indentation guides even on blank lines
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "┊",
      },
      scope = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("ibl").setup(opts)
      vim.api.nvim_set_hl(0, "IblScope", { fg = "#E06C75", bold = false, underdotted = true })
    end,
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

      ufo.setup(opts)
    end,
  },

  {
    "folke/zen-mode.nvim",
  },
}
