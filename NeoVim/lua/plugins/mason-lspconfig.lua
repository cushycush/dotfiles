return {
	"mason-org/mason-lspconfig.nvim",
	dependencies = {
		"mason-org/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	opts = {
		ensure_installed = vim.tbl_keys(require("config.lsp.tools").servers),
		automatic_installation = false,
		-- We configure servers ourselves via `nvim-lspconfig`.
		-- Disable mason-lspconfig auto-enabling to avoid duplicate/builtin clients (e.g. docker_language_server).
		automatic_enable = false,
	},
}
