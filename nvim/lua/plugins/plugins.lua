local M = {
  ---@type snacks.win
  claude_terminal = nil,

  ---@type snacks.win
  lazygit_terminal = nil,
}

local terminal_opts = {}

local plugins = {
  { 'glacambre/firenvim', build = ":call firenvim#install(0)" },

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
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end)

        -- Actions
        -- undo_stage_hunk
        map('n', '<leader>hs', gitsigns.stage_hunk)
        map('n', '<leader>hu', gitsigns.undo_stage_hunk)
        map('n', '<leader>hr', gitsigns.reset_hunk)

        map('v', '<leader>hs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('v', '<leader>hr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('n', '<leader>hS', gitsigns.stage_buffer)
        map('n', '<leader>hR', gitsigns.reset_buffer)
        map('n', '<leader>hp', gitsigns.preview_hunk)
        map('n', '<leader>hi', gitsigns.preview_hunk_inline)

        map('n', '<leader>hb', function()
          gitsigns.blame_line({ full = true })
        end)

        -- todo how to exit?
        map('n', '<leader>hd', gitsigns.diffthis)

        map('n', '<leader>hD', function()
          gitsigns.diffthis('~')
        end)

        map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
        map('n', '<leader>hq', gitsigns.setqflist)

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
        map('n', '<leader>tw', gitsigns.toggle_word_diff)

        -- Text object
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
      end
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
    "https://codeberg.org/andyg/leap.nvim",
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
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "c", "cpp", "kdl", "go", "lua", "vim", "python", "rust", "bash",
        "regex", "markdown", "markdown_inline", "typescript", "javascript",
        "graphql", "prisma", "kotlin", "yaml", "query",
      }

      require("nvim-treesitter").install(parsers)

      local filetypes = {}
      for _, p in ipairs(parsers) do
        local fts = vim.treesitter.language.get_filetypes(p)
        vim.list_extend(filetypes, fts)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function(args)
          if args.match == "terminal" then return end
          pcall(vim.treesitter.start, args.buf)

          if args.match ~= "python" then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end

          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
        end,
      })

      -- Incremental selection (main branch dropped the built-in module).
      -- <CR> starts/expands, <TAB> jumps to enclosing scope, <S-TAB> shrinks.
      local sel_stack = {}

      local function select_node(node)
        local srow, scol, erow, ecol = node:range()
        vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
        vim.cmd("normal! v")
        vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
      end

      vim.keymap.set("n", "<CR>", function()
        local node = vim.treesitter.get_node()
        if not node then return end
        sel_stack = { node }
        select_node(node)
      end, { desc = "TS: init selection" })

      vim.keymap.set("x", "<CR>", function()
        local node = sel_stack[#sel_stack]
        if not node then return end
        local parent = node:parent()
        if not parent then return end
        sel_stack[#sel_stack + 1] = parent
        select_node(parent)
      end, { desc = "TS: expand to parent" })

      vim.keymap.set("x", "<S-Tab>", function()
        if #sel_stack <= 1 then return end
        sel_stack[#sel_stack] = nil
        select_node(sel_stack[#sel_stack])
      end, { desc = "TS: shrink selection" })

      vim.keymap.set("x", "<Tab>", function()
        local node = sel_stack[#sel_stack]
        if not node then return end
        local n = node:parent()
        while n and n:named_child_count() == 1 do
          n = n:parent()
        end
        if not n then return end
        sel_stack[#sel_stack + 1] = n
        select_node(n)
      end, { desc = "TS: expand to scope" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local function s(obj) return function() select.select_textobject(obj, "textobjects") end end
      local function gns(obj) return function() move.goto_next_start(obj, "textobjects") end end
      local function gne(obj) return function() move.goto_next_end(obj, "textobjects") end end
      local function gps(obj) return function() move.goto_previous_start(obj, "textobjects") end end
      local function gpe(obj) return function() move.goto_previous_end(obj, "textobjects") end end

      local map = vim.keymap.set
      local xo = { "x", "o" }
      local nxo = { "n", "x", "o" }

      map(xo, "aa", s("@parameter.outer"))
      map(xo, "ia", s("@parameter.inner"))
      map(xo, "af", s("@function.outer"))
      map(xo, "if", s("@function.inner"))
      map(xo, "ac", s("@class.outer"))
      map(xo, "ic", s("@class.inner"))

      map(nxo, "]m", gns("@function.outer"))
      map(nxo, "]]", gns("@class.outer"))
      map(nxo, "]M", gne("@function.outer"))
      map(nxo, "][", gne("@class.outer"))
      map(nxo, "[m", gps("@function.outer"))
      map(nxo, "[[", gps("@class.outer"))
      map(nxo, "[M", gpe("@function.outer"))
      map(nxo, "[]", gpe("@class.outer"))

      map("n", "<leader>a", function() swap.swap_next("@parameter.inner") end)
      map("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end)
    end,
  },

  ------------------- editing -------------------
  -- Improve working with comments
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup({
        -- Comment.nvim's treesitter-based detection crashes when no parser is installed,
        -- so skip it unless a parser actually exists.
        pre_hook = function()
          local ok, parser = pcall(vim.treesitter.get_parser, 0)
          if not ok or not parser then
            return vim.bo.commentstring
          end
        end,
      })

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
    opts = {
      engines = {
        ripgrep = {
          extraArgs = "--hidden",
        },
      },
    },
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
      if vim.env.NVIM_NOTES == "1" then
        vim.o.scrolloff = 2
      else
        vim.o.scrolloff = 10
      end
      require("scrollEOF").setup(opts)
    end,
  },

  {
    "echasnovski/mini.nvim",
    config = function()
    end,
  },

  {
    'dmtrKovalenko/fff.nvim',
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    opts = {
      debug = {
        enabled = true,
        show_scores = false,
      },
    },
    lazy = false,
    keys = {
      {
        "ff",
        function() require('fff').find_files() end,
        desc = 'FFFind files',
      },
      {
        "fg",
        function() require('fff').live_grep() end,
        desc = 'LiFFFe grep',
      },
      {
        "fz",
        function()
          require('fff').live_grep({
            grep = {
              modes = { 'fuzzy', 'plain' }
            }
          })
        end,
        desc = 'Live fffuzy grep',
      }
    }
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
          elseif M.codex_terminal ~= nil and not M.codex_terminal.closed then
            M.codex_terminal:toggle()
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
      {
        "<leader>CC",
        function()
          M.codex_terminal, _ = Snacks.terminal({ "codex" }, terminal_opts)
        end,
        desc = "Codex"
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
      keymaps = {
        ["gd"] = {
          callback = function()
            local oil = require("oil")
            local config = require("oil.config")
            if #config.columns == 1 then
              oil.set_columns({ "icon", { "size", highlight = "Comment" }, { "mtime", highlight = "Comment" }, { "permissions", highlight = "Comment" } })
            else
              oil.set_columns({ "icon" })
            end
          end,
          desc = "Toggle detailed view",
        },
      },
    },
  },

  {
    "Bekaboo/dropbar.nvim",
    enabled = function() return vim.env.NVIM_NOTES ~= "1" end,
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
    enabled = function() return vim.env.NVIM_NOTES ~= "1" end,
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

  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" }
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
        build = function(plugin)
          vim.system({
            "bash",
            "-c",
            "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
          }, { cwd = plugin.dir }):wait()
        end,
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
