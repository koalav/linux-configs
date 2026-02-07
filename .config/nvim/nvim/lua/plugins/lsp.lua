return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({})
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "lua-language-server",
          "pyright",
          "typescript-language-server",
          "rust-analyzer",
          "jdtls",
          "kotlin-language-server",
          "lemminx",
          "eslint-lsp",
          "stylua",
          "black",
          "ruff",
          "prettier",
          "prettierd",
          "google-java-format",
          "ktlint",
          "eslint_d",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
  { "neovim/nvim-lspconfig", lazy = true },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local mlsp = require("mason-lspconfig")
      mlsp.setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "ts_ls",
          "rust_analyzer",
          "jdtls",
          "kotlin_language_server",
          "lemminx",
          "eslint",
        },
        automatic_enable = false,
      })

      local function root_pattern(...)
        local patterns = { ... }
        return function(fname)
          local match = vim.fs.find(patterns, { path = fname, upward = true })[1]
          return match and vim.fs.dirname(match) or nil
        end
      end

      local on_attach = function(client, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "LSP: go to definition")
        map("n", "gr", vim.lsp.buf.references, "LSP: references")
        map("n", "K", vim.lsp.buf.hover, "LSP: hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
        map("n", "<leader>ds", vim.diagnostic.open_float, "Diagnostics: float")
        map("n", "[d", vim.diagnostic.goto_prev, "Diagnostics: prev")
        map("n", "]d", vim.diagnostic.goto_next, "Diagnostics: next")

        if client.name == "ts_ls" or client.name == "eslint" then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      vim.lsp.config("pyright", { on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config("ts_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      })
      vim.lsp.config("eslint", {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      })

      vim.lsp.config("rust_analyzer", {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      })

      local kotlin_root = root_pattern(
        "settings.gradle.kts",
        "settings.gradle",
        "build.gradle.kts",
        "build.gradle",
        "gradlew",
        ".git"
      )

      local function kotlin_should_attach(root_dir)
        if not root_dir then
          return false
        end
        if vim.env.KOTLIN_LSP_DISABLE == "1" then
          return false
        end
        if vim.fn.filereadable(root_dir .. "/.kotlin-lsp-disable") == 1 then
          return false
        end
        if vim.fn.filereadable(root_dir .. "/.kotlin-lsp-enable") == 1 then
          return true
        end
        return true
      end

      vim.lsp.config("kotlin_language_server", {
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          local root_dir = kotlin_root(fname)
          if not kotlin_should_attach(root_dir) then
            return nil
          end
          return root_dir
        end,
        single_file_support = false,
        flags = { debounce_text_changes = 150 },
      })

      vim.lsp.config("lemminx", { on_attach = on_attach, capabilities = capabilities })

      vim.lsp.enable("lua_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("eslint")
      vim.lsp.enable("rust_analyzer")
      vim.lsp.enable("kotlin_language_server")
      vim.lsp.enable("lemminx")
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
  },
}
