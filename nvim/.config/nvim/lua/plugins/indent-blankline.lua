-- ================================================================================================
-- TITLE : indent-blankline.nvim
-- ABOUT : scope underline visualization (vertical line animation handled by mini.indentscope)
-- ================================================================================================

return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		exclude = {
			filetypes = {
				"help",
				"startify",
				"dashboard",
				"packer",
				"neogitstatus",
				"NvimTree",
				"Trouble",
				"alpha",
				"neo-tree",
			},
			buftypes = {
				"terminal",
				"nofile",
			},
		},
		indent = {
			char = "▏",
		},
		scope = {
			enabled = true,
			char = "▏",
			show_start = true,
			show_end = false,
			show_exact_scope = false,
		},
	},
}
