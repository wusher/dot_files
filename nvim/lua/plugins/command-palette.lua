return {
  dir = "/Users/wusher/src/cybersyn",
  main = "command-palette",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>p", function() require("command-palette").open() end, desc = "Command Palette" },
  },
  opts = {},
}
