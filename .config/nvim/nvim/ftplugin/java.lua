-- ~/.config/nvim/ftplugin/java.lua
local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local ok_setup, jdtls_setup = pcall(require, "jdtls.setup")
if not ok_setup then
  return
end

local util = require("lspconfig.util")

local root_markers = { "gradlew", "mvnw", "build.gradle", "build.gradle.kts", "pom.xml", ".git" }
local root_dir = util.root_pattern(unpack(root_markers))(vim.fn.getcwd())
if not root_dir then
  root_dir = vim.fn.getcwd()
end

local project_name = vim.fn.fnamemodify(root_dir, ":p:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

local mason = vim.fn.stdpath("data") .. "/mason"
local jdtls_path = mason .. "/packages/jdtls"
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if launcher_jar == "" then
  vim.notify("jdtls launcher jar not found. Run :Mason and install jdtls.", vim.log.levels.WARN)
  return
end

local config_dir
if vim.fn.has("mac") == 1 then
  config_dir = jdtls_path .. "/config_mac"
elseif vim.fn.has("unix") == 1 then
  config_dir = jdtls_path .. "/config_linux"
else
  config_dir = jdtls_path .. "/config_win"
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

local on_attach = function(_, bufnr)
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

  map("n", "<leader>jo", jdtls.organize_imports, "Java: organize imports")
  map("n", "<leader>jt", jdtls.test_class, "Java: test class")
  map("n", "<leader>jn", jdtls.test_nearest_method, "Java: test nearest method")
end

local cmd = {
  "java",
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.protocol=true",
  "-Dlog.level=ALL",
  "-Xms1g",
  "--add-modules=ALL-SYSTEM",
  "--add-opens", "java.base/java.util=ALL-UNNAMED",
  "--add-opens", "java.base/java.lang=ALL-UNNAMED",
  "-jar", launcher_jar,
  "-configuration", config_dir,
  "-data", workspace_dir,
}

local config = {
  cmd = cmd,
  root_dir = root_dir,
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      configuration = {
        updateBuildConfiguration = "interactive",
      },
    },
  },
  init_options = {
    bundles = {},
  },
}

jdtls.start_or_attach(config)

jdtls_setup.add_commands()
