# tmux

Config: `tmux/tmux.conf` → `~/.config/tmux/tmux.conf`. Prefix is `C-'` (Caps Lock + `'`).
Mouse on, windows and panes numbered from 1.

| Key | Action |
|---|---|
| `prefix r` | reload config |
| `prefix \|` / `prefix -` | split right / below in the current directory |
| `prefix h/j/k/l` | move between panes |

## `dev [name]`

Defined in `zsh/config/20-tmux.zsh`. Creates (or reattaches to) a session
named after the current directory:

- left 33%: top 70% runs `gbox`, bottom 30% is a shell
- right 66%: `nvim`

Focus starts in nvim.
