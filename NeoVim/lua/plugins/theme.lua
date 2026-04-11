return {
  "AlexvZyl/nordic.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nordic").load({
      cursorline = {
        theme = "dark",
      },
      telescope = {
        style = "classic",
      },
      on_highlight = function(highlights, palette)
        highlights.FloatBorder = { fg = palette.border }
      end,
    })
    require("config.highlights").setup()
    require("config.highlights").apply()
  end,
}
