local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<leader>w", "<cmd>write<CR>")
map("n", "<leader>q", "<cmd>quit<CR>")

-- mouse-drag selection + Cmd+C copies to system clipboard; without this,
-- terminals forward it as a bare "c" and visual mode reads it as change/cut
map("v", "<D-c>", '"+y')
