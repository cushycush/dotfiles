return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local N = require("nordic.colors")
    local neovim = require("utils.neovim")
    local chars = require("utils.chars")

    local icon_hl = { fg = N.gray4 }
    local text_hl = { fg = N.gray3 }

    local function fmt_mode(s)
      local mode_map = {
        ["COMMAND"] = "COMMND",
        ["V-BLOCK"] = "V-BLCK",
        ["TERMINAL"] = "TERMNL",
        ["V-REPLACE"] = "V-RPLC",
        ["O-PENDING"] = "O-PNDG",
      }
      return mode_map[s] or s
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

    local function recording()
      if neovim.is_recording() then
        return chars.kind_icons.Recording
      end
      return ""
    end

    require("lualine").setup({
      options = {
        theme = "nordic",
        component_separators = { left = "", right = "" },
        section_separators = { left = " ", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = fmt_mode,
            icon = { "" },
            separator = { right = " ", left = "" },
          },
        },
        lualine_b = {
          {
            "filename",
            path = 1,
            icon = { "", color = icon_hl },
            color = text_hl,
          },
        },
        lualine_c = {
          {
            "branch",
            icon = { "", color = icon_hl },
            color = text_hl,
          },
          {
            "diff",
            source = diff_source,
            colored = true,
          },
        },
        lualine_x = {
          {
            recording,
            color = { fg = N.red.base },
          },
          {
            "diagnostics",
            symbols = {
              error = chars.diagnostic_signs.error,
              warn = chars.diagnostic_signs.warn,
              info = chars.diagnostic_signs.info,
              hint = chars.diagnostic_signs.hint,
            },
          },
        },
        lualine_y = {
          {
            "location",
            icon = { "", align = "left" },
            fmt = function(str)
              return string.format("%7s", str)
            end,
          },
        },
        lualine_z = {
          {
            "progress",
            icon = { "", align = "left" },
          },
        },
      },
    })
  end,
}
