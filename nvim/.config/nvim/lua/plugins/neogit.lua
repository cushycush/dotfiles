return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"esmuellert/codediff.nvim",
		"folke/snacks.nvim",
	},
	cmd = "Neogit",
	keys = {
		{
			"<leader>gg",
			"<cmd>Neogit<cr>",
			desc = "Neogit",
		},
	},
}
