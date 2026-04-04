-- ================================================================================================
-- TITLE : mini.nvim
-- ABOUT : library of 40+ independent lua modules
-- ================================================================================================

return {
	{ "echasnovski/mini.ai", version = "*", opts = {} },
	{ "echasnovski/mini.comment", version = "*", opts = {} },
	{ "echasnovski/mini.move", version = "*", opts = {} },
	{ "echasnovski/mini.surround", version = "*", opts = {} },
	{ "echasnovski/mini.cursorword", version = "*", opts = {} },
	{
		"echasnovski/mini.indentscope",
		version = "*",
		lazy = true,
		enabled = true,
		config = function()
			local indentscope = require("mini.indentscope")
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
			require("mini.indentscope").setup({
				symbol = "⎸",
				options = {
					try_as_border = false,
				},
				draw = {
					delay = 100,
					animation = indentscope.gen_animation.quadratic({
						easing = "out",
						duration = 200,
						unit = "total",
					}),
				},
			})
		end,
	},
	{ "echasnovski/mini.pairs", version = "*", opts = {} },
	{ "echasnovski/mini.trailspace", version = "*", opts = {} },
	{ "echasnovski/mini.bufremove", version = "*", opts = {} },
}
