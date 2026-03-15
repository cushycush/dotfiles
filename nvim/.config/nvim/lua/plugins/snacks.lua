return {
	"folke/snacks.nvim",
	lazy = false,

	---@type snacks.Config
	opts = {
		explorer = {
			enabled = true,
		},
		input = {
			enabled = true,
		},
		scroll = {
			enabled = true,
		},
		notifier = {
			enabled = true,
		},
		dashboard = {
			enabled = true,
		},
		bigfile = {
			enabled = true,
		},
		quickfile = {
			enabled = true,
		},
		scope = {
			enabled = true,
		},
		statuscolumn = {
			enabled = true,
		},
		words = {
			enabled = true,
		},
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
      "<leader>gg",
      function()
        Snacks.lazygit.open()
      end,
      desc = "LazyGit",
    },
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git Branches",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log({
					layout = "vertical",
				})
			end,
			desc = "Git Log",
		},
		{
			"<leader>gL",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git Log Line",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>gS",
			function()
				Snacks.picker.git_stash()
			end,
			desc = "Git Stash",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>gf",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git Log File",
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
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete buffer",
		},
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
		{
			"gai",
			function()
				Snacks.picker.lsp_incoming_calls()
			end,
			desc = "C[a]lls Incoming",
		},
		{
			"gao",
			function()
				Snacks.picker.lsp_outgoing_calls()
			end,
			desc = "C[a]lls Outgoing",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>sS",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},
	},
}
