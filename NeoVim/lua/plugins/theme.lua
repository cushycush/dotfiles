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
	{
		"sainnhe/everforest",
		lazy = false,
		priority = 1000,
		config = function()
			require("config.highlights").setup()
			require("config.highlights").apply()
		end,
	},
	{
		"catppuccin/nvim",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha",
			transparent_background = true,
			float = {
				transparent = true,
				solid = false,
			},
		},
		config = function(_, opts)
			require("config.highlights").setup()
			require("config.highlights").apply()
			require("catppuccin").setup(opts)
		end,
	},
	{
		"AlexvZyl/nordic.nvim",
		lazy = false,
		priority = 1000,
		config = function(_, opts)
			require("nordic").load({
				cursorline = {
					theme = "dark",
				},
				telescope = {
					style = "classic",
				},
			})
		end,
	},
}
