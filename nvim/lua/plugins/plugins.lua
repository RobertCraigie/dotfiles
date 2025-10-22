local M = {
  ---@type snacks.win
  claude_terminal = nil,

  ---@type snacks.win
  lazygit_terminal = nil,
}

local terminal_opts = {}

local plugins = {
  ---------------- theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]])
    end,
    opts = function()
      return {
        style = "storm",
        sidebars = {
          "qf",
          "vista_kind",
          "terminal",
          "spectre_panel",
          "startuptime",
          "Outline",
        },
        on_highlights = function(hl, c)
          hl.CursorLineNr = { fg = c.orange, bold = true }
          hl.LineNr = { fg = c.orange, bold = true }
          hl.LineNrAbove = { fg = c.fg_gutter }
          hl.LineNrBelow = { fg = c.fg_gutter }
          local prompt = "#2d3149"
          hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
          hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
          hl.TelescopePromptNormal = { bg = prompt }
          hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
          hl.TelescopePromptTitle = { bg = c.fg_gutter, fg = c.orange }
          hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.bg_dark }
          hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
          hl["@variable.kdl"] = { fg = c.cyan }
        end,
      }
    end,
  },

  ---------------- git
  { "tpope/vim-fugitive" },
  { "tpope/vim-rhubarb" },
  {
    "lewis6991/gitsigns.nvim",
    enabled = true,
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  ------------------- motions -------------------
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

  ------------------- tree-sitter -------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      pcall(require("nvim-treesitter.install").update({ with_sync = true }))
    end,
    dependencies = {
      --  Additional text objects via treesitter
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "kdl",
        "go",
        "lua",
        "vim",
        "python",
        "rust",
        "bash",
        "regex",
        "markdown",
        "markdown_inline",
        "typescript",
        "javascript",
        "graphql",
        "prisma",
        "kotlin",
        "yaml",
        "query",
      },

      -- TODO: vet & understand these options
      highlight = { enable = true },
      indent = { enable = true, disable = { "python" } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<TAB>",
          node_decremental = "<S-TAB>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-treesitter/playground",
    opts = {
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  ------------------- editing -------------------
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

  ------------------- misc -------------------
  {
    "folke/zen-mode.nvim",
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    config = function(_, opts)
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local ufo = require("ufo")
      vim.keymap.set("n", "zR", ufo.openAllFolds)
      vim.keymap.set("n", "zM", ufo.closeAllFolds)

      ufo.setup(opts)
    end,
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

  -- Add blank lines to scrolloff at the end of the file
  {
    "Aasim-A/scrollEOF.nvim",
    opts = {
      pattern = "*",
      disabled_filetypes = { "terminal" },
      disabled_modes = { "t", "nt", "vt" },
    },
    config = function(_, opts)
      vim.o.scrolloff = 10
      require("scrollEOF").setup(opts)
    end,
  },

  {
    "echasnovski/mini.nvim",
    config = function()
    end,
  },

  {
    "dmtrKovalenko/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
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
    'danobi/prr',
    lazy = false,
    init = function(plugin)
      vim.opt.rtp:append(plugin.dir .. '/vim')

      local function set_prr_highlights()
        local set = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

        set('prrAdded', { link = 'DiffAdd' })
        set('prrRemoved', { link = 'DiffDelete' })
        set('prrFile', { link = 'Special' })
        set('prrHeader', { link = 'Directory' })
        set('prrIndex', { link = 'Special' })
        set('prrChunk', { link = 'Special' })
        set('prrChunkH', { link = 'Special' })
        set('prrTagName', { link = 'Special' })
        set('prrResult', { link = 'Special' })
      end

      -- 2) apply them for .prr buffers and re-apply on colorscheme change
      local grp = vim.api.nvim_create_augroup('Prr', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        group = grp,
        pattern = '*.prr',
        callback = function()
          vim.cmd('syntax on')
          set_prr_highlights()
        end,
      })
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = grp,
        callback = set_prr_highlights,
      })
    end,
  },

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
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({ preset = "helix" })
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
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        version = "^1.0.0",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
      },
    },
    cmd = "Telescope",
    keys = {
      {
        "<leader>sh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "[S]earch [H]elp",
      },
      {
        "<leader>sg",
        function()
          require("telescope.builtin").live_grep({
            additional_args = function()
              return { "--hidden" }
            end,
          })
        end,
        desc = "[S]earch by [G]rep",
      },
      {
        "<leader>sd",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "[S]earch [D]iagnostics",
      },
      {
        "<leader>?",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "[?] Find recently opened files",
      },
      {
        "<leader><space>",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "[ ] Find existing buffers",
      },
      {
        "<leader>/",
        function()
          -- You can pass additional configuration to telescope to change theme, layout, etc.
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = "[/] Fuzzily search in current buffer",
      },
      {
        "<leader>sw",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "[S]earch current [W]ord",
      },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          file_ignore_patterns = {
            "js/",
            "node_modules/",
            ".git/",
            "packages/stainless-monaco/public/yml.worker.js",
            "services/app/public/src/worker/yml.worker.js",
            "glide/bundled/",
            "output.log",
          },
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
              ["<C-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
              ["<C-h>"] = "which_key",
            },
          },
        },
        pickers = {
          buffers = {
            -- show all buffers
            file_ignore_patterns = {},
            layout_config = {
              width = 0.8, -- 80% of screen width
            },
            sort_lastused = true,
            sort_mru = true,
            ignore_current_buffer = true,
            theme = "dropdown",
            previewer = false,
            mappings = {
              i = { ["<C-d>"] = require("telescope.actions").delete_buffer },
              n = { ["<C-d>"] = require("telescope.actions").delete_buffer },
            },
          },
        },
        extensions = {
          fzf = {},
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
    end,
  }
}

return plugins
