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
| `<leader>e` | n | show diagnostics for the line in a float |
| `<D-c>` | v | copy to system clipboard |

## Plugins

lazy.nvim, one spec per file in `lua/plugins/`; `lazy-lock.json` is committed.
Currently: colorscheme, git-conflict, lualine, markdown, oil, telescope, which-key.

## LSP

Native `vim.lsp.enable()`, enabled in `config/lsp.lua`, config in
`lsp/<server>.lua`: `terraformls`, `marksman`, `gopls`. Servers come from the
Brewfile, not Mason. To add one: brew it, add `lsp/<server>.lua`, add the name
to `config/lsp.lua`.

## Filetype options

`after/ftplugin/<ft>.lua` (`go`, `markdown`).

## Merge conflicts

git-conflict.nvim highlights conflict markers in the buffer. Git itself uses
`merge.conflictStyle = zdiff3` (`git/config`), so markers include the base.

| Key | Action |
|---|---|
| `co` / `ct` / `cb` / `c0` | choose ours / theirs / both / none |
| `]x` / `[x` | next / previous conflict |

`:GitConflictListQf` loads every conflict into the quickfix list.

## Reloading changed files

`autoread` plus a `FocusGained`/`BufEnter` autocmd (`config/options.lua`)
reload buffers changed on disk, e.g. after `git checkout` in another pane.
Buffers with unsaved edits are not overwritten. Ghostty must forward focus
events for `FocusGained` to fire; `BufEnter` covers the rest.
