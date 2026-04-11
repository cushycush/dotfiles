return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    display = {
      mode = "virtualtext",
      virtualtext = { position = "after" },
    },
  },
}
