local chars = require("utils.chars")
local neovim = require("utils.neovim")

-- Custom mode names.
-- I want all of them to be the same length so that lualine stays constant.
local function fmt_mode(s)
	local mode_map = {
		["COMMAND"] = "COMMND",
		["V-BLOCK"] = "V-BLCK",
		["TERMINAL"] = "TERMNL",
		["V-REPLACE"] = "V-RPLC",
		["O-PENDING"] = "0PNDNG",
	}
	return mode_map[s] or s
end

-- Theme dependant custom colors.
local text_hl
local icon_hl
local green
local red
if neovim.is_default() then
	local C = require("native.themes.default").palette
	red = C.red
	green = C.green
	icon_hl = { fg = C.gray2 }
	text_hl = { fg = C.gray2 }
elseif chars.is_nordic() then
	local C = require("nordic.colors")
	text_hl = { fg = C.gray3 }
	icon_hl = { fg = C.gray4 }
	green = C.green.base
	red = C.red.base
elseif chars.is_tokyonight() then
	local C = require("tokyonight.colors.moon")
	text_hl = { fg = C.fg_gutter }
	icon_hl = { fg = C.dark3 }
	green = C.green1
	red = C.red1
end

local function get_virtual_text_color()
	local enabled = require("native.lsp").virtual_diagnostics
	if enabled then
		return { fg = green }
	end
	return icon_hl
end

local function get_format_enabled_color()
	local enabled = require("native.lsp").format_enabled
	if enabled then
		return { fg = green }
	end
	return icon_hl
end

local function get_recording_color()
	if chars.is_recording() then
		return { fg = red }
	else
		return { fg = text_hl }
	end
end

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end

local default_z = {
	{
		"location",
		icon = { "", align = "left" },
		fmt = function(str)
			local fixed_width = 7
			return string.format("%" .. fixed_width .. "s", str)
		end,
	},
	{
		"progress",
		icon = { "", align = "left" },
		separator = { right = "", left = "" },
	},
}

local tree = {
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = fmt_mode,
				icon = { "" },
				separator = { right = " ", left = "" },
			},
		},
		lualine_b = {},
		lualine_c = {
			{
				neovim.get_short_cwd,
				padding = 0,
				icon = { "   ", color = icon_hl },
				color = text_hl,
			},
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = default_z,
	},
	filetypes = { "NvimTree" },
}

local telescope = {
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = fmt_mode,
				icon = { "" },
				separator = { right = " ", left = "" },
			},
		},
		lualine_b = {},
		lualine_c = {
			{
				function()
					return "Telescope"
				end,
				color = text_hl,
				icon = { "  ", color = icon_hl },
			},
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = default_z,
	},
	filetypes = { "TelescopePrompt" },
}

if neovim.is_default() then
	require("native.themes.default").setup_lualine()
end

return {
	"nvim-lualine/lualine.nvim",
	config = function(_, opts)
		require("lualine").setup({
			options = { theme = "nordic" },
		})
	end,
}
