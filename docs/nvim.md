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
| `<leader>.` | n | toggle scratch buffer (per cwd + filetype, persisted) |
| `<leader>S` | n | pick from existing scratch buffers |
| `<D-c>` | v | copy to system clipboard |
| `-` | n | oil: open parent directory |
| `<leader>/` | n | which-key: buffer-local keymaps |
| `<leader>ff` / `<leader>fF` | n | telescope: find files / incl. gitignored |
| `<leader>fg` / `<leader>fG` | n | telescope: live grep / incl. gitignored |
| `<leader>fb` / `<leader>fh` | n | telescope: buffers / help tags |

Telescope searches hidden files (but never `.git/`). oil shows hidden files
too, except `.git`.

## Plugins

lazy.nvim, one spec per file in `lua/plugins/`; `lazy-lock.json` is committed.
Currently: colorscheme (tokyonight), git-conflict, lualine, markdown
(render-markdown), oil, snacks (scratch buffers), sops (transparent
decrypt/re-encrypt, see [sops.md](sops.md)), telescope (with fzf-native),
which-key.

## LSP

Native `vim.lsp.enable()`, enabled in `config/lsp.lua`, config in
`lsp/<server>.lua`: `terraformls`, `marksman`, `gopls`, `bashls`
(sh, bash and zsh; `shellcheck` diagnostics don't cover zsh), `rust_analyzer`.
Servers come from the Brewfile, not Mason. To add one: brew it, add
`lsp/<server>.lua`, add the name to `config/lsp.lua`.

The exception is `rust_analyzer`, which comes from rustup so it matches the
toolchain: `rustup component add rust-analyzer rust-src`.

## Filetype options

`after/ftplugin/<ft>.lua` (`go`, `markdown`). Defaults (`config/options.lua`):
2-space indent, relative numbers, smartcase search, persistent undo. `go` uses
tabs (width 4) and organizes imports plus formats on save; `markdown` wraps
at word boundaries with `conceallevel=2`.

AppleScript has no upstream support, so `ftdetect/` maps `*.applescript` and
`syntax/applescript.vim` provides basic highlighting.

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
