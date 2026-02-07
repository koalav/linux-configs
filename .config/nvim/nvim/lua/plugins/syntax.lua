return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, config = pcall(require, "nvim-treesitter.config")
      if not ok then
        vim.notify("nvim-treesitter not found. Run :Lazy sync to install.", vim.log.levels.WARN)
        return
      end
      config.setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "lua",
          "vim",
          "bash",
          "python",
          "javascript",
          "typescript",
          "json",
          "yaml",
          "toml",
          "markdown",
          "regex",
          "rust",
          "java",
          "kotlin",
          "groovy",
          "xml",
        },
      })

      -- Backward-compat shim: some plugins still call parsers.has_parser().
      local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
      if ok_parsers and type(parsers.has_parser) ~= "function" then
        parsers.has_parser = function(lang)
          local installed = config.get_installed("parsers")
          return vim.list_contains(installed, lang)
        end
      end
    end,
  },
}
