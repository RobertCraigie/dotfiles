return {
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
      "<leader>sf",
      function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
      desc = "[S]earch [F]iles",
    },
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
