# Keyboard

Karabiner rules in `karabiner/capslock-ijkl.json`. `install.sh` upserts them
into the selected profile of `~/.config/karabiner/karabiner.json`, matched by
rule `description`; other rules are untouched and Karabiner hot-reloads. Renaming a
rule's `description` orphans the old one, so delete it by hand.

## Caps Lock

Tap: `Esc`. Held: **right** `Ctrl`.

Right `Ctrl` is deliberate: the physical left `Ctrl` + `H/J/K/L` still reaches
nvim's window navigation.

| Caps Lock + | Sends | Used for |
|---|---|---|
| `I` `J` `K` `L` | `↑ ← ↓ →` | arrows |
| `W` / `B` | `Option-→` / `Option-←` | word jumps |
| `0` / `4` | `Home` / `End` | line start / end |

The shell side of these is in `zsh/config/95-keybindings.zsh`.
