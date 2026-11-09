# tmux

Config: `tmux/tmux.conf` → `~/.config/tmux/tmux.conf`. Prefix is `C-'` (Caps Lock + `'`).
Mouse on, windows and panes numbered from 1.

| Key | Action |
|---|---|
| `prefix r` | reload config |
| `prefix \|` / `prefix -` | split right / below in the current directory |
| `prefix h/j/k/l` | move between panes |
| `prefix s` / `t` / `e` | jump to pane 1 / 2 / 3: sandbox, shell, nvim in the `dev` layout |
| `prefix Tab` | toggle back to the previous pane |
| `prefix q` | flash pane numbers; press one to jump |
| `prefix 1-9` / `prefix w` | jump to a window by number / pick from a tree |

Each pane's border shows its number and role (`sandbox`, `shell`, `nvim`), or the running command outside `tm dev`.

## `tm dev [session]`

`tm <layout>` in `zsh/config/20-tmux.zsh` launches a layout; `dev` is the only one so far.
It creates (or reattaches to) a session named after the current directory, or
the optional `session` argument:

- left 33%: top 85% runs `${SANDBOX:-rsbx}`, bottom 15% is a shell
- right 67%: `nvim .` (oil on the directory)

Focus starts in the sandbox pane.

A host that uses a different sandbox tool sets it in `zsh-private/`:

```sh
echo 'export SANDBOX=<tool>' > ~/.config/zsh-private/sandbox.zsh
```
