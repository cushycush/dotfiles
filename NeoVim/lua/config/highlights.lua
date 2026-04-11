local M = {}

local function get_palette()
  if vim.g.colors_name == "nordic" then
    local C = require("nordic.colors")
    return {
      bg = C.bg,
      bg_dark = C.black0,
      bg_float = C.black2 or C.black0,
      fg = C.fg,
      border = C.black0,
      muted = C.gray4,
      subtle = C.gray2,
      blue = C.blue1,
      cyan = C.cyan.base,
      magenta = C.magenta.base,
      green = C.green.base,
      yellow = C.yellow.base,
      red = C.red.base,
      orange = C.orange.base,
    }
  end
  return nil
end

local function set(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

function M.apply()
  local p = get_palette()
  if not p then
    return
  end

  set("FloatBorder", { fg = p.border })

  -- noice
  set("NoiceCmdlinePopupBorder", { fg = p.border })
  set("NoiceCmdlinePopupTitle", { fg = p.blue })
  set("NoiceCmdlineIcon", { fg = p.yellow })
  set("NoiceConfirmBorder", { fg = p.border })
  set("NoicePopupBorder", { fg = p.border })
  set("NoicePopupmenuBorder", { fg = p.border })

  -- snacks.notifier
  set("SnacksNotifierBorderInfo", { fg = p.border })
  set("SnacksNotifierBorderWarn", { fg = p.border })
  set("SnacksNotifierBorderError", { fg = p.border })
  set("SnacksNotifierBorderDebug", { fg = p.border })
  set("SnacksNotifierBorderTrace", { fg = p.border })

  -- blink.cmp
  set("BlinkCmpScrollBarThumb", { fg = p.magenta, bg = p.subtle })
  set("BlinkCmpSource", { fg = p.cyan, italic = true })
  set("BlinkCmpMenu", { fg = p.fg, bg = p.bg_float })
  set("BlinkCmpMenuBorder", { fg = p.border, bg = p.bg_float })
  set("BlinkCmpDoc", { fg = p.fg, bg = p.bg_float })
  set("BlinkCmpDocBorder", { fg = p.border, bg = p.bg_float })

  -- blink.pairs
  set("BlinkPairsOrange", { fg = p.cyan })
  set("BlinkPairsPurple", { fg = p.magenta })
  set("BlinkPairsBlue", { fg = p.blue })
  set("BlinkPairsUnmatched", { fg = p.muted })
  set("BlinkPairsMatchParen", { fg = p.cyan, bold = true })

  -- snacks.nvim
  set("SnacksPickerBorder", { fg = p.border })
  set("SnacksPickerTitle", { fg = p.blue, bold = true })
  set("SnacksPickerPrompt", { fg = p.cyan })
  set("SnacksExplorerDir", { fg = p.blue })
  set("SnacksExplorerFile", { fg = p.fg })

  -- lspsaga
  set("SagaBorder", { fg = p.border })
  set("SagaNormal", { fg = p.fg, bg = p.bg })
  set("SagaTitle", { fg = p.blue, bold = true })

  -- mini.indentscope
  set("MiniIndentscopeSymbol", { fg = p.cyan })
end

function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      M.apply()
    end,
  })
end

return M
