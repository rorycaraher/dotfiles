# zellij

Config: `zellij/` → `~/.config/zellij` (`config.kdl`, `layouts/`). The tmux-style
prefix is `C-'` (Caps Lock + `'`), which enters zellij's Tmux mode. Mouse on.

| Key | Action |
|---|---|
| `prefix \|` / `prefix -` | split right / below |
| `prefix h/j/k/l` | move between panes |
| `Shift+←/↓/↑/→` | move between panes, no prefix (Caps+Shift+H/J/K/L) |
| `prefix s` / `t` / `e` | jump to sandbox / terminal / nvim in the `dev` layout (chained `MoveFocus` toward its corner, so only meaningful there) |
| `prefix Tab` | focus the next pane |
| `prefix 1-9` | jump to a tab by number |
| `prefix w` | session manager |

Zellij has no jump-to-pane-by-name or index, no last-pane toggle and no config reload
key (config reloads itself). The `dev` layout adds zellij's compact bar (tabs and current mode). Pane frames show the pane name (`sandbox`,
`shell`, `nvim`) or the running command.

## `zj <layout> [session]`

`zj` in `zsh/config/20-zellij.zsh` launches a layout. It creates (or
reattaches to) a session named `<layout>-<current directory>` (`dev-myrepo`), or
the optional `session` argument.

| Layout | Panes |
|---|---|
| `dev` | top 60%: sandbox (40%) beside `nvim .` (60%); bottom 40%: terminal |

The sandbox pane runs `${SANDBOX:-rsbx}`. Focus starts there. `prefix s/t/e`
assumes the `dev` layout.

## Host-specific layouts

A host can add layouts without committing them:

- `~/.config/zellij-private/layouts/<name>.kdl` is found by `zj <name>`, ahead of the managed layouts.
- If a function `zj_setup_<name>` exists (put it in `~/.config/zsh-private/`), `zj` calls it with the extra arguments. It sets `reply=(<directory to start in> <session name>)` and returns non-zero to abort.

A pane's command starts before the shell's direnv hook fires. For a layout that
depends on `.envrc`, run the pane under `direnv exec .`.

## Host-specific tools and sandbox

`bootstrap.sh` also runs `brew bundle` on `Brewfile.local` if present (gitignored).

Every layout runs `${SANDBOX:-rsbx}` as its sandbox. A host that uses a
different tool sets it in `zsh-private/`:

```sh
echo 'export SANDBOX=<tool>' > ~/.config/zsh-private/sandbox.zsh
```
