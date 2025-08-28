return {
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
