return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			{ path = "luvit-meta/library", words = { "vim%.uv" } },
			{ path = "blink.cmp", words = { "blink" } },
			{ path = "snacks.nvim", words = { "snacks" } },
		},
	},
}
