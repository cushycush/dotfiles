local M = {}

local palette = {
	bg = "#161616",
	fg = "#dde1e6",
	subtle = "#393939",
	muted = "#525252",
	blue = "#33b1ff",
	cyan = "#3ddbd9",
	magenta = "#ee5396",
	green = "#42be65",
	yellow = "#82cfff",
}

local function set(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

function M.apply()
	-- blink.cmp
	set("BlinkCmpScrollBarThumb", { fg = palette.magenta, bg = palette.subtle })
	set("BlinkCmpSource", { fg = palette.cyan, italic = true })
	set("BlinkCmpMenuBorder", { fg = palette.muted, bg = "NONE" })
	set("BlinkCmpDocBorder", { fg = palette.muted, bg = "NONE" })

	-- snacks.nvim (best-effort: groups are safe to define even if unused)
	set("SnacksPickerBorder", { fg = palette.muted, bg = "NONE" })
	set("SnacksPickerTitle", { fg = palette.blue, bold = true })
	set("SnacksPickerPrompt", { fg = palette.cyan })
	set("SnacksExplorerDir", { fg = palette.blue })
	set("SnacksExplorerFile", { fg = palette.fg })

	-- lspsaga (best-effort)
	set("SagaBorder", { fg = palette.muted, bg = "NONE" })
	set("SagaNormal", { fg = palette.fg, bg = palette.bg })
	set("SagaTitle", { fg = palette.blue, bold = true })
end

function M.setup()
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			M.apply()
		end,
	})
end

return M
