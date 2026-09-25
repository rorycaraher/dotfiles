return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- not lazy: oil must be loaded to take over directory buffers like `nvim .`
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
  },
  opts = {},
}
