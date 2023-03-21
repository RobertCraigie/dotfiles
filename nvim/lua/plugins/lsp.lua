-- table of lsp client name to a boolean indicating whether or not autoformatting is enabled
local formatting_clients = {}

local on_formatter_attach = function(client, bufnr)
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  -- Create a command `:LspFormat` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })

  -- Create a command and keymap to disable formatting using the current client
  function toggle_format()
    formatting_clients[client.name] = not formatting_clients[client.name]
  end

  vim.api.nvim_buf_create_user_command(bufnr, "ToggleLspFormat", function(_)
    toggle_format()
  end, { desc = "LSP: Toggle formatting on save for the current client" })

  vim.keymap.set("n", "<leader>tf", function()
    toggle_format()
  end, { buffer = bufnr, desc = "Toggle formatting on save" })

  -- default to formatting on
  if formatting_clients[client.name] == nil then
    formatting_clients[client.name] = true
  end

  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      local should_format = formatting_clients[client.name]

      if should_format == true then
        vim.lsp.buf.format({
          -- stop Neovim from asking which server to use
          filter = function(f_client)
            return f_client.name == "null-ls"
          end,
          timeout_ms = 5000,
        })
      end
    end,
  })
end

local on_attach = function(client, bufnr)
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

  -- See `:help K` for why this keymap
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")

  -- Disable diagnostics for Jinja2 files as they won't be useful
  local filetype = vim.bo.filetype
  if string.match(filetype, ".jinja") then
    vim.diagnostic.disable(bufnr)
  end

  -- add support for formatting on save etc
  if client.supports_method("textDocument/formatting") and client.name ~= "tsserver" then
    on_formatter_attach(client, bufnr)
  end
end

local servers = {
  pyright = {},
  prismals = {},
  gopls = {},
  eslint = {},
  rust_analyzer = {},
  tsserver = {
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "non-relative",
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        diagnostics = {
          globals = { "vim" },
        },
      },
    },
  },
}

-- TODO: don't do this
vim.cmd([[ autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll ]])

return {
  -- Tools
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Useful status updates for LSP
      "j-hui/fidget.nvim",
    },
  },

  -- Additional lua configuration, makes nvim stuff amazing
  {
    "folke/neodev.nvim",
    ft = "lua",
  },

  {
    "williamboman/mason.nvim",
    -- TODO: add ensure_installed here for formatters?
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = vim.tbl_keys(servers),
    },
    config = function(_, opts)
      require("mason").setup()

      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup(opts)
      mason_lspconfig.setup_handlers({
        function(server_name)
          -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
          capabilities.textDocument.foldingRange = {
            dynamigRegistration = false,
            lineFoldingOnly = true,
          }

          local default_config = {
            capabilities = capabilities,
            on_attach = on_attach,
            before_init = function(_, config)
              local Util = require("config.util.lsp")

              if server_name == "pyright" then
                -- tell Pyright to use the right python binary
                config.settings.python.pythonPath = Util.get_python_path(config.root_dir)
              end
            end,
          }

          local merged = vim.tbl_deep_extend("force", {}, default_config, servers[server_name])

          require("lspconfig")[server_name].setup(merged)
        end,
      })
    end,
  },

  -- LSP Diagnostics
  {
    "folke/trouble.nvim",
    dependencies = {
      -- "kyazdani42/nvim-web-devicons",
    },
    opts = {
      mode = "quickfix",
    },
  },

  -- Improved LSP diagnostics
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    keys = {
      {
        "<leader>tl",
        function()
          local enable_lines = not vim.diagnostic.config().virtual_lines
          if enable_lines == true then
            vim.diagnostic.config({
              virtual_text = false,
              virtual_lines = true,
            })
          else
            vim.diagnostic.config({
              virtual_text = true,
              virtual_lines = false,
            })
          end
        end,
        desc = "Toggle LSP Lines",
      },
    },
    config = function(_, opts)
      require("lsp_lines").setup(opts)

      -- Disable lsp_lines by default.
      -- Can be re-enabled using <leader>tl
      vim.diagnostic.config({
        virtual_text = true,
        virtual_lines = false,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },

  -- Custom LSP shenanigans + formatting
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    enabled = true,
    config = function()
      local null_ls = require("null-ls")

      if vim.fn.executable("blue") == 1 then
        null_ls.register(null_ls.builtins.formatting.blue)
      elseif vim.fn.executable("black") == 1 then
        null_ls.register(null_ls.builtins.formatting.black)
      end

      null_ls.setup({
        on_attach = on_attach,
        sources = {
          null_ls.builtins.formatting.stylua,
        },
      })
    end,
  },
}
