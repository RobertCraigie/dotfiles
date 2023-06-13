return {
  -- File tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    config = function()
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
      require("neo-tree").setup()
      require("nvim-web-devicons").setup({
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true,
      })
    end,
  },

  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>fo", "<cmd>Oil<cr>", desc = "Oil - File explorer as a buffer" },
    },
    opts = {
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,

        -- This function defines what is considered a "hidden" file
        is_hidden_file = function(name, bufnr)
          return vim.startswith(name, ".")
        end,

        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          return false
        end,
      },
    },
  },

  -- Improved quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  },

  -- Fancier statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "f-person/git-blame.nvim",
    },
    opts = function()
      local git_blame = require("gitblame")

      -- This disables showing of the blame text next to the cursor
      vim.g.gitblame_display_virtual_text = 0

      return {
        options = {
          icons_enabled = false,
          theme = "tokyonight",
          component_separators = "|",
          section_separators = "",
        },
        sections = {
          lualine_c = { "%f", { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } },
        },
        inactive_sections = {
          lualine_c = { "%f" },
        },
      }
    end,
  },

  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },

  -- Duck!
  {
    "tamton-aquib/duck.nvim",
    keys = {
      {
        "<leader>dd",
        function()
          require("duck").hatch()
        end,
        desc = "Hatch",
      },
      {
        "<leader>dk",
        function()
          require("duck").cook()
        end,
        desc = "Cook",
      },
    },
  },

  -- Regex explainer
  {
    "bennypowers/nvim-regexplainer",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      mappings = {
        toggle = "gR",
      },
    },
  },
}
