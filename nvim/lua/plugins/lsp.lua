local Util = require("config.util.lsp")

local servers = {
  pyright = {
    before_init = function(_, config)
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = Util.get_python_path(config.root_dir)
    end,

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

      -- Override the default rename handler to remove the `annotationId` from edits.
      --
      -- Pyright is being non-compliant here by returning `annotationId` in the edits, but not
      -- populating the `changeAnnotations` field in the `WorkspaceEdit`. This causes Neovim to
      -- throw an error when applying the workspace edit.
      --
      -- See:
      -- - https://github.com/neovim/neovim/issues/34731
      -- - https://github.com/microsoft/pyright/issues/10671
      [vim.lsp.protocol.Methods.textDocument_rename] = function(err, result, ctx)
        if err then
          vim.notify('Pyright rename failed: ' .. err.message, vim.log.levels.ERROR)
          return
        end

        ---@cast result lsp.WorkspaceEdit
        for _, change in ipairs(result.documentChanges or {}) do
          for _, edit in ipairs(change.edits or {}) do
            if edit.annotationId then
              edit.annotationId = nil
            end
          end
        end

        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
      end,
    },
  },
  ruff = {},
  clangd = {
    cmd = { vim.fn.expand("~/.mozbuild/clang/bin/clangd") },
  },
  jsonls = {
    settings = {
      doValidation = false,
    }
  },
  gopls = {},
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
  ts_ls = {},
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

if vim.env.DEBUG_LSP then
  vim.lsp.set_log_level(vim.log.levels.DEBUG)
end

local function create_html_snippets()
  local luasnip = require("luasnip")
  local s = luasnip.snippet
  local t = luasnip.text_node
  local i = luasnip.insert_node

  local html_elements = {
    -- Structure
    "html", "head", "body", "div", "span", "header", "footer", "main", "nav",
    "section", "article", "aside", "details", "summary", "dialog",

    -- Text content
    "h1", "h2", "h3", "h4", "h5", "h6", "p", "blockquote", "pre", "code",
    "em", "strong", "small", "mark", "del", "ins", "sub", "sup", "cite",
    "q", "abbr", "time", "var", "samp", "kbd", "bdi", "bdo", "ruby", "rt", "rp",

    -- Lists
    "ul", "ol", "li", "dl", "dt", "dd", "menu",

    -- Tables
    "table", "thead", "tbody", "tfoot", "tr", "th", "td", "caption", "colgroup", "col",

    -- Forms
    "form", "input", "textarea", "button", "select", "option", "optgroup",
    "label", "fieldset", "legend", "datalist", "output", "progress", "meter",

    -- Media
    "img", "audio", "video", "source", "track", "picture", "figure", "figcaption",
    "canvas", "svg", "math",

    -- Embedded content
    "iframe", "embed", "object", "param",

    -- Interactive
    "a", "button", "details", "summary",

    -- Semantic
    "address", "main", "search",

    -- Head
    "script", "meta", "link", "title",

    -- Other
    "br", "hr", "wbr", "data", "template", "slot",

    -- custom
    "highlight",
  }

  local snippets = {}

  local self_closing = {
    br = true,
    hr = true,
    img = true,
    input = true,
    col = true,
    wbr = true,
    meta = true,
    link = true,
    source = true,
    track = true,
    embed = true,
    param = true
  }

  for _, element in ipairs(html_elements) do
    if self_closing[element] then
      table.insert(snippets, s("<" .. element, {
        t("<" .. element .. " "),
        i(1),
        t("/>"),
      }))
    else
      table.insert(snippets, s("<" .. element, {
        t("<" .. element .. ">"),
        i(1),
        t("</" .. element .. ">"),
      }))
    end
  end

  return snippets
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
      ensure_installed = vim.tbl_filter(function(name)
        return true
        -- return name ~= "tsserver"
      end, vim.tbl_keys(servers)),
    },
    config = function(_, opts)
      require("mason").setup()

      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup(opts)

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      capabilities.textDocument.foldingRange = {
        dynamigRegistration = false,
        lineFoldingOnly = true,
      }

      local defaults = {
        capabilities = capabilities,
        on_attach = Util.on_attach,
      }

      for name, conf in pairs(servers) do
        vim.lsp.config(name, vim.tbl_deep_extend("force", {}, defaults, conf))
      end
    end,
  },

  -- fix the terrible errors
  {
    "youyoumu/pretty-ts-errors.nvim",
    lazy = false,
    dir = "~/github.com/youyoumu/pretty-ts-errors.nvim",
    opts = {
      auto_open = false,
    },
    config = function(_, opts)
      require('pretty-ts-errors').setup(opts)

      local win_opts = {
        lazy_window = true,
      }

      vim.keymap.set('n', '<leader>te',
        function() require('pretty-ts-errors').show_formatted_error(win_opts) end,
        { desc = "Show TS error" })

      vim.keymap.set('n', '<leader>tE', function() require('pretty-ts-errors').open_all_errors() end,
        { desc = "Show all TS errors" })

      vim.keymap.set('n', '<leader>tt', function() require('pretty-ts-errors').toggle_auto_open() end,
        { desc = "Toggle TS error auto-display" })


      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.ts", "*.tsx", "*.mts", "*.cts", "*.js", "*.jsx", "*.mjs", "*.cjs" },
        callback = function()
          local pretty = require('pretty-ts-errors')
          vim.keymap.set('n', '<leader>e', function() pretty.show_formatted_error(win_opts) end,
            { buffer = true, desc = "Show TS error" })

          -- overrides of the go-to-diagnostic keymaps that use the prettier view
          --
          vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = false })
            vim.schedule(function()
              require('pretty-ts-errors').show_formatted_error(win_opts)
            end)
          end, { buffer = true })

          vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = false })
            vim.schedule(function()
              require('pretty-ts-errors').show_formatted_error(win_opts)
            end)
          end, { buffer = true })
        end,
      })
    end
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {}
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
      luasnip.add_snippets('html', create_html_snippets())

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
          { name = "render-markdown" },
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
        local ignore_filetypes = { "sql", "java", "json" }
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

        local no_lsp = { "css", "json", "javascript", "typescript" }
        if vim.tbl_contains(no_lsp, vim.bo[bufnr].filetype) then
          return { timeout_ms = 500, lsp_format = "never" }
        end

        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        zsh = { "shfmt" },
        php = { "php_cs_fixer" },
        python = { "ruff" },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
      },
    },
    keys = {
      { "<leader>ff", "<cmd>FormatBuf<cr>", desc = "Conform - Format buf" },
    },
    lazy = false,
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
