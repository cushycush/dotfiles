-- ================================================================================================
-- TITLE : Theme
-- ABOUT : variety of themes
-- ================================================================================================

return {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme oxocarbon')
    end
}
