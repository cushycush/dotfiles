return {
	"stevearc/conform.nvim",
	enabled = false,
	opts = {
		formatters_by_ft = require("config.lsp.tools").formatters,
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
