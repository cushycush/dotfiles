return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = {
    select = {
      enable = true,
      lookahead = true,
      selection_modes = {
        ["@parameter.outer"] = "v",
        ["@function.outer"] = "v",
        ["@class.outer"] = "<C-v>",
      },
      include_surrounding_whitespace = true,
    },
  },
  config = function(_, opts)
    require("nvim-treesitter-textobjects").setup(opts)

    local select = require("nvim-treesitter-textobjects.select").select_textobject
    vim.keymap.set({ "x", "o" }, "af", function()
      select("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "if", function()
      select("@function.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ac", function()
      select("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ic", function()
      select("@class.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "as", function()
      select("@local.scope", "locals")
    end)
  end,
}
