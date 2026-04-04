return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-mini/mini.nvim",
	},
	ft = {
		"markdown",
		"codecompanion",
	},
	lazy = false,
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
}
