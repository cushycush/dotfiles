return {
  "nvimdev/guard.nvim",
  enabled = true,
  dependencies = {
    "nvimdev/guard-collection",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local ft = require("guard.filetype")
    local tools = require("config.lsp.tools")

    local function normalize_formatter(name)
      if name == "fixjson" then
        return "jq"
      end
      return name
    end

    local function safe_fmt(filetype, name)
      pcall(function()
        ft(filetype):fmt(normalize_formatter(name))
      end)
    end

    local function safe_lint(filetype, name)
      pcall(function()
        ft(filetype):lint(name)
      end)
    end

    for filetype, formatters in pairs(tools.formatters or {}) do
      for _, formatter in ipairs(formatters or {}) do
        safe_fmt(filetype, formatter)
      end
    end

    for filetype, linters in pairs(tools.linters or {}) do
      for _, linter in ipairs(linters or {}) do
        safe_lint(filetype, linter)
      end
    end

    vim.g.guard_config = {
      fmt_on_save = true,
      lsp_as_default_formatter = false,
      auto_lint = true,
    }
  end,
}
