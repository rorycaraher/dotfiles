return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    scratch = {},
  },
  keys = {
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle scratch buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select scratch buffer" },
  },
}
