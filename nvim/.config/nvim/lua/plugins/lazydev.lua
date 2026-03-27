return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "blink.cmp", words = { "blink" } },
			{ path = "snacks.nvim", words = { "snacks" } },
			{ path = "bufferline.nvim", words = { "bufferline" } },
			{ path = "indent-blankline.nvim", words = { "ibl" } },
		},
		enabled = true,
	},
}
