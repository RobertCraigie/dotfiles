local M = {
  ---@type snacks.win
  claude_terminal = nil,

  ---@type snacks.win
  lazygit_terminal = nil,
}

local terminal_opts = {}

return {
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    opts = {},
    keys = {
      {
        "ff",
        function()
          require("fff").find_files()
        end,
        desc = "Open file picker",
      },
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      styles = {
        float = {
          border = "rounded",
          width = 0.8, -- percentage of screen
          height = 0.8,
        },
      },
      lazygit = {
        win = {
          border = "none",
        }
      },
      terminal = {
        enabled = true,
        win = {
          position = "float",
        }
      },
    },
    keys = {
      -- manage terminals
      {
        "<c-;>",
        function()
          -- if the claude or lazygit terminals are active, close them first
          --
          -- invariant is that only one can be active at any time
          if M.claude_terminal ~= nil and not M.claude_terminal.closed then
            M.claude_terminal:toggle()
          elseif M.lazygit_terminal ~= nil and not M.lazygit_terminal.closed then
            M.lazygit_terminal:toggle()
          else
            Snacks.terminal.toggle(vim.o.shell, terminal_opts)
          end
        end,
        desc = "Toggle Terminal",
        mode = { 't', 'n' }
      },

      -- lazygit
      {
        "<leader>gg",
        function()
          M.lazygit_terminal, _ = Snacks.lazygit(terminal_opts)
        end,
        desc = "Lazygit"
      },

      -- claude
      {
        "<leader>cc",
        function()
          M.claude_terminal, _ = Snacks.terminal({ "claude" }, terminal_opts)
        end,
        desc = "Claude"
      },
      {
        "<leader>ca",
        function()
          M.claude_terminal, _ = Snacks.terminal({ "claude", "--dangerously-skip-permissions" }, terminal_opts)
        end,
        desc = "Claude with all the permissions"
      },
    }
  },

  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require 'nvim-web-devicons'.setup {
        override = {
          -- for some reason this was broken
          css = {
            icon = "",
            color = "#563d7c",
            name = "Css"
          }
        }
      }
    end
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

  {
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    config = function()
      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })

      require("dropbar").setup({
        sources = {
          path = {
            max_depth = 1,
          },
        },
      })
    end,
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
          lualine_a = { "mode" },
          lualine_b = { "diagnostics" },
          lualine_c = { "%f" },
          lualine_x = { terminal_status },
        },
        inactive_sections = {
          lualine_c = { "%f" },
        },
      }
    end,
  },

  {
    "folke/noice.nvim",
    enabled = false,
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
        bottom_search = false,        -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
    },
  },
}
