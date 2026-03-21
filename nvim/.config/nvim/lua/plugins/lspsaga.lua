return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		ui = {
			border = "rounded",
		},
		symbol_in_winbar = {
			enable = false,
		},
	},
	keys = {
		{ "<leader>K", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover doc" },
		{ "<leader>gD", "<cmd>Lspsaga goto_definition<cr>", desc = "Goto definition" },
		{ "<leader>gP", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition" },
		{ "<leader>gr", "<cmd>Lspsaga finder<cr>", desc = "References/defs" },
		{ "<leader>ca", "<cmd>Lspsaga code_action<cr>", desc = "Code action" },
		{ "<leader>rn", "<cmd>Lspsaga rename<cr>", desc = "Rename" },
		{ "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Line diagnostics" },
	},
}
