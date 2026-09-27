# Neovim

`nvim/` is symlinked whole to `~/.config/nvim`. `init.lua` sets the leader,
then loads `lua/config/{options,keymaps,lsp,lazy}`.

## Keymaps

| Key | Mode | Action |
|---|---|---|
| `<Esc>` | n | clear search highlight |
| `<C-h/j/k/l>` | n | move between windows |
| `<leader>w` | n | write |
| `<leader>q` | n | quit |
| `<D-c>` | v | copy to system clipboard |

## Plugins

lazy.nvim, one spec per file in `lua/plugins/`; `lazy-lock.json` is committed.
Currently: colorscheme, lualine, markdown, oil, telescope, which-key.

## LSP

Native `vim.lsp.enable()`, enabled in `config/lsp.lua`, config in
`lsp/<server>.lua`: `terraformls`, `marksman`, `gopls`. Servers come from the
Brewfile, not Mason. To add one: brew it, add `lsp/<server>.lua`, add the name
to `config/lsp.lua`.

## Filetype options

`after/ftplugin/<ft>.lua` (`go`, `markdown`).
