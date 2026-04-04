-- ================================================================================================
-- TITLE : treesitter.nvim
-- ABOUT : treesitter configurations and abstraction layer for neovim
-- ================================================================================================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		lazy = false,
	},
}
