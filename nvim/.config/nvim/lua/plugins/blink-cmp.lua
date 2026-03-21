return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	version = "1.*",
	build = "cargo build --release",

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "enter",
		},
		sources = {
			default = {
				"lazydev",
				"lsp",
				"path",
				"snippets",
				"buffer",
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		appearance = {
			nerd_font_variant = "mono",
			kind_icons = {
				Color = "󱓡",
				Column = "󰃭",
				Constant = "󰏿",
				Constructor = "",
				Enum = "",
				EnumMember = "",
				Field = "󰜢",
				File = "󰈙",
				Folder = "󰉋",
				Function = "󰊕",
				Interface = "󰭦",
				Keyword = "󰌋",
				Method = "󰆧",
				Module = "󰏗",
				Property = "󰜢",
				Reference = "󰈇",
				Snippet = "",
				Struct = "󰙅",
				Text = "󰉿",
				TypeParameter = "󰊄",
				Unit = "󰑭",
				Value = "󰎠",
				Variable = "󰀫",
			},
		},
		completion = {
			menu = {
				-- Add rounded borders to the completion menu
				border = "rounded",
				winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpSelection,Search:None",
				-- Customize the columns: icons, label, and the "source" (LSP, Path, etc.)
				draw = {
					columns = {
						{ "kind_icon", "label", gap = 2 },
						{ "source_name" },
					},
					components = {
						scrollbar = {
							text = function()
								return "|"
							end,
							highlight = "BlinkCmpScrollBarThumb",
						},
						source_name = {
							text = function(ctx)
								return "[" .. ctx.source_name .. "]"
							end,
							highlight = "BlinkCmpSource",
						},
					},
				},
			},
			documentation = {
				-- Add rounded borders to the documentation window
				window = {
					border = "rounded",
					winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
					max_width = 60,
					max_height = 20,
					scrollbar = true,
				},
				auto_show = true,
			},
		},
	},
	opts_extend = { "sources.default" },
	config = function(_, opts)
		require("blink.cmp").setup(opts)
		require("config.lsp.diagnostics").setup()

		-- Keep blink menu consistent with the active colorscheme.
		vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Pmenu" })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "FloatBorder" })
		vim.api.nvim_set_hl(0, "BlinkCmpDoc", { link = "NormalFloat" })
		vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "FloatBorder" })
		vim.api.nvim_set_hl(0, "BlinkCmpSelection", { link = "PmenuSel" })
	end,
}
