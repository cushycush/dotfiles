local tools = require("config.lsp.tools")
local mason_servers = {}

for name, cfg in pairs(tools.servers) do
	if cfg.mason ~= false then
		table.insert(mason_servers, name)
	end
end

return {
	"mason-org/mason-lspconfig.nvim",
	dependencies = {
		"mason-org/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	opts = {
		ensure_installed = mason_servers,
		automatic_installation = false,
		-- Disable mason-lspconfig auto-enabling to avoid duplicate/builtin clients.
		automatic_enable = false,
	},
}
