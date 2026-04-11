return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	version = "1.*",
	build = "cargo build --release",

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
			per_filetype = {
				qml = {
					"quickshell",
					"lsp",
					"path",
					"snippets",
					"buffer",
				},
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				quickshell = {
					name = "Quickshell",
					module = "quickshell-completions.blink",
					score_offset = 90,
				},
				snippets = {
					opts = {
						-- search_paths set in config function below
					},
				},
			},
		},
		appearance = {
			nerd_font_variant = "mono",
			kind_icons = {
				Color = "󱓡",
				Column = "󰃭",
				Constant = "󰏿",
				Constructor = "",
				Enum = "",
				EnumMember = "",
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
				Snippet = "",
				Struct = "󰙅",
				Text = "󰉿",
				TypeParameter = "󰊄",
				Unit = "󰑭",
				Value = "󰎠",
				Variable = "󰀫",
			},
		},
	},
	opts_extend = { "sources.default" },
	config = function(_, opts)
		local C = require("utils.chars")
		opts.completion = {
			menu = {
				border = C.border,
				winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
			},
			documentation = {
				auto_show = true,
				window = {
					border = C.border,
					winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
				},
			},
		}
		local qs_ok, qs = pcall(require, "quickshell-completions")
		if qs_ok then
			opts.sources = opts.sources or {}
			opts.sources.providers = opts.sources.providers or {}
			opts.sources.providers.snippets = opts.sources.providers.snippets or {}
			opts.sources.providers.snippets.opts = opts.sources.providers.snippets.opts or {}
			opts.sources.providers.snippets.opts.search_paths = { qs.get_snippet_path() }
		end
		require("blink.cmp").setup(opts)
	end,
}
