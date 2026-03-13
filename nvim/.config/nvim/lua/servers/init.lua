local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("servers.lua_ls")(capabilities)
require("servers.pyright")(capabilities)
require("servers.ts_ls")(capabilities)
require("servers.gopls")(capabilities)
require("servers.bashls")(capabilities)
require("servers.dockerls")(capabilities)
require("servers.clangd")(capabilities)
require("servers.emmet_ls")(capabilities)
require("servers.jsonls")(capabilities)
require("servers.tailwindcss")(capabilities)
require("servers.yamlls")(capabilities)

require("servers.efm")(capabilities)

vim.lsp.enable({
  "lua_ls",
  "pyright",
  "gopls",
  "jsonls",
  "ts_ls",
  "bashls",
  "clangd",
  "dockerls",
  "emmet_ls",
  "yamlls",
  "tailwindcss",
  "efm",
})
