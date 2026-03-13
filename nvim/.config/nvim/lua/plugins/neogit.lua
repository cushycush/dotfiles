return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"esmuellert/codediff.nvim",
		"ibhagwan/fzf-lua",
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
