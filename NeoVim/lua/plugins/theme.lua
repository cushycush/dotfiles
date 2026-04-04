-- ================================================================================================
-- TITLE : Theme
-- ABOUT : variety of themes
-- ================================================================================================

return {
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("config.highlights").setup()
			require("config.highlights").apply()
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function(_, opts)
			vim.cmd("colorscheme gruvbox")
			require("config.highlights").setup()
			require("config.highlights").apply()
			require("gruvbox").setup(opts)
		end,
	},
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			require("config.highlights").setup()
			require("config.highlights").apply()
		end,
	},
}
