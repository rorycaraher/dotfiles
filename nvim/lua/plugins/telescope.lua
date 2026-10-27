return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fF", "<cmd>Telescope find_files no_ignore=true<CR>", desc = "Find files (incl. gitignored)" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
    { "<leader>fG", function() require("telescope.builtin").live_grep({ additional_args = { "--hidden", "--no-ignore" } }) end, desc = "Live grep (incl. gitignored)" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
  end,
  opts = {
    defaults = {
      file_ignore_patterns = { "^%.git/" },
    },
    pickers = {
      find_files = { hidden = true },
      live_grep = { additional_args = { "--hidden" } },
    },
  },
}
