# tmux

Config: `tmux/tmux.conf` → `~/.config/tmux/tmux.conf`. Prefix is `C-'` (Caps Lock + `'`).
Mouse on, windows and panes numbered from 1.

| Key | Action |
|---|---|
| `prefix r` | reload config |
| `prefix \|` / `prefix -` | split right / below in the current directory |
| `prefix h/j/k/l` | move between panes |

## `tm dev [session]`

`tm <layout>` in `zsh/config/20-tmux.zsh` launches a layout; `dev` is the only one so far.
It creates (or reattaches to) a session named after the current directory, or
the optional `session` argument:

- left 33%: top 70% runs `${SANDBOX:-rsbx}`, bottom 30% is a shell
- right 66%: `nvim .` (oil on the directory)

Focus starts in nvim.

A host that uses a different sandbox tool sets it in `zsh-private/`:

```sh
echo 'export SANDBOX=<tool>' > ~/.config/zsh-private/sandbox.zsh
```
