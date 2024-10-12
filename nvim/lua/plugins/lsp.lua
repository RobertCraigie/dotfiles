local servers = {
  pyright = {
    handlers = {
      ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
        result.diagnostics = vim.tbl_filter(function(diagnostic)
          -- ignore diagnostics for method arguments that aren't accessed
          -- as this is reported for stub methods that don't have an implementation
          --
          -- ruff will also report if an argument isn't used correctly anyway so this
          -- is redundant
          if diagnostic.severity == 4 and string.match(diagnostic.message, "is not accessed$") then
            return false
          end

          return true
        end, result.diagnostics)

        return vim.lsp.handlers["textDocument/publishDiagnostics"](nil, result, ctx, config)
      end,
    },
  },
  ruff_lsp = {},
  prismals = {},
  gopls = {},
  ocamllsp = {},
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["./legacy-dir-root/lib/config.schema.json"] = "*.stainless.yml",
        },
      },
    },
  },
  rust_analyzer = {},
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
end

if vim.env.DEBUG_LSP then
  vim.lsp.set_log_level(vim.log.levels.DEBUG)
end

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
    "folke/lazydev.nvim",
    -- ft = "lua",
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

          local merged = vim.tbl_deep_extend("force", {}, default_config, servers[server_name] or {})

          require("lspconfig")[server_name].setup(merged)
        end,
      })
    end,
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      on_attach = on_attach,
      settings = {
        tsserver_file_preferences = {
          importModuleSpecifierPreference = "non-relative",
        },
      },
      handlers = {
        ["textDocument/definition"] = function(_, result, ctx, config)
          -- If there are 2 results that are defined next to each other then use the first one
          local line_diff_limit = 20
          if #result == 2 then
            local line1 = result[1].targetSelectionRange.start.line
            local line2 = result[2].targetSelectionRange.start.line
            if line2 - line1 < line_diff_limit and result[1].targetUri == result[2].targetUri then
              result = result[1]
            end
          end

          return vim.lsp.handlers["textDocument/definition"](nil, result, ctx, config)
        end,
      },
    },
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

      luasnip.add_snippets("ocaml", {
        luasnip.snippet(">>*", {
          luasnip.text_node(">>= fun () ->"),
        }),
      })

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
        sorting = {
          priority_weight = 2,
          comparators = {
            function(entry1, entry2)
              if not entry1 or not entry2 then
                return nil
              end

              local item1 = entry1.completion_item
              local item2 = entry2.completion_item

              if not item1 or not item2 then
                return nil
              end

              -- Define the criteria for sorting
              local function sort_criteria(label)
                if label:sub(1, 1) ~= "_" then
                  return 1 -- Non-underscored items first
                elseif label:sub(1, 2) == "__" and label:sub(-2) == "__" then
                  return 3 -- Items starting and ending with __ afterward
                elseif label:sub(1, 1) == "_" then
                  return 2 -- Items starting with a single underscore _ next
                else
                  return 4 -- Everything else
                end
              end

              local criteria1 = sort_criteria(item1.label)
              local criteria2 = sort_criteria(item2.label)

              if criteria1 ~= criteria2 then
                return criteria1 < criteria2
              end

              -- Fallback to the default comparator if the custom criteria are the same
              return nil
            end,
            -- Default comparators are usually fine, but you can customize order here
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      })
    end,
  },

  -- auto formatting
  {
    "stevearc/conform.nvim",
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      format_on_save = function(bufnr)
        -- Disable autoformat on certain filetypes
        local ignore_filetypes = { "sql", "java" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
        end

        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end

        -- Disable autoformat for files in a certain path
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("/node_modules/") then
          return
        end

        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        zsh = { "shfmt" },
        php = { "php_cs_fixer" },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      vim.api.nvim_create_user_command("FormatBuf", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_format = "fallback", range = range })
      end, { range = true })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
  },
}
