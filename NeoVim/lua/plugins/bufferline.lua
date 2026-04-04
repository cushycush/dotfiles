return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	---@module "bufferline"
	---@type bufferline.UserConfig
	opts = {
		options = {
			diagnostics = "nvim_lsp",
      numbers = "buffer_id",
			indicator = {
				style = "underline",
			},
		offsets = {
			{
				filetype = "snacks_layout_box",
				text = "󰙅  File Explorer",
				separator = true,
			},
		},
			separator_style = "thick",
			enforce_regular_tabs = true,
		},
	},
}
