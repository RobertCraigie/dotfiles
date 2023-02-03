return {
  {
    "glepnir/dashboard-nvim",
    event = "VimEnter",
    opts = {
      -- config
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    -- config = function(_, opts)
    --   require("dashboard-nvim").setup({
    --     theme = "hyper",
    --     config = {
    --       week_header = {
    --         enable = true,
    --       },
    --       shortcut = {
    --         { desc = " Update", group = "@property", action = "Lazy update", key = "u" },
    --         {
    --           desc = " Files",
    --           group = "Label",
    --           action = "Telescope find_files",
    --           key = "f",
    --         },
    --         {
    --           desc = " Apps",
    --           group = "DiagnosticHint",
    --           action = "Telescope app",
    --           key = "a",
    --         },
    --         {
    --           desc = " dotfiles",
    --           group = "Number",
    --           action = "Telescope dotfiles",
    --           key = "d",
    --         },
    --       },
    --     },
    --   })
    -- end,
  },
}
