local U = require("utils.neovim")

local M = {}

-- Single chars.
M.bottom_thin = "▁"
M.top_thin = "▔"
M.left_thin = "▏"
M.right_thin = "▕"
M.left_thick = "▎"
M.right_thick = "🮇"
M.full_block = "█"
M.top_right_thin = "🭾"
M.top_left_thin = "🭽"
M.bottom_left_thin = "🭼"
M.bottom_right_thin = "🭿"
M.top_left_round = "╭"
M.top_right_round = "╮"
M.bottom_right_round = "╯"
M.bottom_left_round = "╰"
M.vertical_default = "│"
M.horizontal_default = "─"

-- Border chars.
M.border_chars_round = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
M.border_chars_none = { "", "", "", "", "", "", "", "" }
M.border_chars_empty = { " ", " ", " ", " ", " ", " ", " ", " " }
M.border_chars_inner_thick = { " ", "▄", " ", "▌", " ", "▀", " ", "▐" }
M.border_chars_outer_thick = { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" }
M.border_chars_cmp_items = { "▛", "▀", "▀", " ", "▄", "▄", "▙", "▌" }
M.border_chars_cmp_doc = { "▀", "▀", "▀", " ", "▄", "▄", "▄", "▏" }
M.border_chars_outer_thin = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
M.border_chars_inner_thin = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" }
M.border_chars_top_only_thin = { " ", M.top_thin, " ", " ", " ", " ", " ", " " }
M.border_chars_top_only_normal = { "", M.horizontal_default, "", "", "", " ", "", "" }

-- Default border style (change here to update all plugins).
M.border = M.border_chars_outer_thin

-- Telescope chars.
M.border_helix_telescope = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
M.border_chars_outer_thick_telescope = { "▀", "▐", "▄", "▌", "▛", "▜", "▟", "▙" }
M.border_chars_outer_thin_telescope = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" }
M.border_chars_telescope_default = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
M.border_chars_telescope_prompt_thin = { "▔", "▕", " ", "▏", "🭽", "🭾", "▕", "▏" }
M.border_chars_telescope_vert_preview_thin = { " ", "▕", "▁", "▏", "▏", "▕", "🭿", "🭼" }

-- Icons.
M.diagnostic_signs = {
  error = " ",
  warning = " ",
  warn = " ",
  info = " ",
  information = " ",
  hint = " ",
  other = " ",
}
M.kind_icons = {
  Text = " ",
  Method = " ",
  Function = "󰊕 ",
  Constructor = " ",
  Field = " ",
  Variable = " ",
  Class = "󰠱 ",
  Interface = " ",
  Module = "󰏓 ",
  Property = " ",
  Unit = " ",
  Value = " ",
  Enum = " ",
  EnumMember = " ",
  Keyword = "󰌋 ",
  Snippet = "󰲋 ",
  Color = " ",
  File = " ",
  Reference = " ",
  Folder = " ",
  Constant = "󰏿 ",
  Struct = "󰠱 ",
  Event = " ",
  Operator = " ",
  TypeParameter = "󰘦 ",
  TabNine = "󰚩 ",
  Copilot = " ",
  Unknown = " ",
  Recording = " ",
  None = "  ",
}

function M.get_border_chars(desc)
  if U.is_default() then
    if desc == "telescope" then
      return M.border_chars_telescope_default
    end
    return M.border_chars_round
  end

  if vim.g.neovide then
    if desc == "telescope" then
      return M.border_chars_telescope_default
    end
    return M.border_chars_round
  end

  if U.is_nordic() then
    if desc == "telescope" then
      return M.border_chars_outer_thin_telescope
    end
    return M.border_chars_outer_thin
  end

  if desc == "telescope" then
    return M.border_chars_telescope_default
  end
  return M.border_chars_round
end

function M.get_recording_state_icon()
  if U.is_recording() then
    return M.kind_icons.Recording
  else
    return M.kind_icons.None
  end
end

return M
