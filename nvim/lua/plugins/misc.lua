return {
  {
    "anuvyklack/hydra.nvim",
  },

  {
    "ruifm/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.api.nvim_set_keymap(
        "n",
        "<leader>gb",
        '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
        { silent = true }
      )
      vim.api.nvim_set_keymap(
        "v",
        "<leader>gb",
        '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
        {}
      )
      require("gitlinker").setup()
    end,
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
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require("dbee").install()
    end,
    config = function(config)
      require("dbee").setup(config)
    end,
    keys = {
      {
        "<leader>td",
        function()
          require("dbee").toggle()
        end,
        desc = "Toggle DBee UI",
      },
    },
  },
}
