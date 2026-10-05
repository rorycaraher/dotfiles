local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

opt.signcolumn = "yes"
opt.undofile = true
opt.termguicolors = true
opt.mouse = "a"
opt.autoread = true

-- autoread only fires on :checktime; terminals don't check on their own
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})
