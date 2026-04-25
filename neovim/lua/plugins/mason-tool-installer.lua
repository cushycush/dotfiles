return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "mason-org/mason.nvim",
  },
  opts = {
    ensure_installed = require("config.lsp.tools").get_all_binaries(),
    auto_update = true,
    run_on_start = true,
  },
}
