return {
	"folke/snacks.nvim",

	--- @type snacks.Config
	opts = {
		explorer = {},
		picker = {
			debug = {
				-- scores = true,
			},
			layout = {
				preset = "ivy",
			},
			matcher = {
				frecency = true,
			},
			win = {
				input = {
					keys = {
						["J"] = { "preview_scroll_down", mode = { "i", "n" } },
						["K"] = { "preview_scroll_up", mode = { "i", "n" } },
						["H"] = { "preview_scroll_left", mode = { "i", "n" } },
						["L"] = { "preview_scroll_right", mode = { "i", "n" } },
					},
				},
			},
			sources = {
				explorer = {},
			},
		},
	},
	keys = {
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log({
					finder = "git_log",
					format = "git_log",
					preview = "git_show",
					confirm = "git_checkout",
					layout = "vertical",
				})
			end,
			desc = "Git Log",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer.open()
			end,
			desc = "Open explorer",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep({
					prompt = "> ",
					regex = true,
					dirs = { vim.fn.getcwd() },
					finder = "grep",
					format = "file",
					show_empty = true,
					layout = "ivy",
				})
			end,
			desc = "Live grep",
		},
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches({
					layout = "select",
				})
			end,
			desc = "Git branches",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps({
					layout = "vertical",
				})
			end,
			desc = "Find keymaps",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files({
					finder = "files",
					format = "file",
					show_empty = true,
					supports_live = true,
				})
			end,
			desc = "Find files",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers({
					finder = "buffers",
					format = "buffer",
					hidden = false,
					unloaded = true,
					current = true,
					sort_lastused = true,
					win = {
						input = {
							keys = {
								["d"] = "bufdelete",
							},
						},
						list = { keys = { ["d"] = "bufdelete" } },
					},
				})
			end,
			desc = "Find buffers",
		},
	},
}
