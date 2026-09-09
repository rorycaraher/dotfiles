# dotfiles

Overengineered mac/ghostty/zsh config

## Setup

```sh
git clone <repo> ~/dotfiles && cd ~/dotfiles
./bootstrap.sh     # Homebrew and Brewfile
./install.sh       # symlink the configs into place
exec zsh
```

`bootstrap.sh` re-runs cleanly and only adds what's missing.

## Backing out

`backup.sh` creates restorable backups, `install.sh` checks if they exist.

```sh
./backup.sh                # snapshot current state of live dotfiles
./restore.sh latest        # roll back to the latest backup
```

---

## Useful state in your prompt

<!--
> **TODO — screenshot.** A real terminal prompt in this config: a couple of
> lines showing the path segment, the git branch with ahead/behind and
> dirty/staged markers, and a command that exited non-zero so the `❯` is red.
-->

`git status` summary in your prompt, refreshed every command.
`❯` turns red after a non-zero exit code.

## `ls` shows file state, not just names

<!--
> **TODO — screenshot.** `ll` in a git repo with a mix of tracked, modified,
> and untracked files, so the colour and the git-status column are both
> visible. A second frame with `lt` showing the tree view.
-->

`ls` replaced by `eza` shows permissions, size, mtime, and per-file
git status, coloured by type. `lt` draws a tree, `la` includes dotfiles.

## Syntax highlighting everywhere

Highlighting applied everywhere, implicit paging diabled everywhere.
`cat` is aliased to `bat --paging=never`, adds syntax
highlighting and line numbers without dropping into a pager.
Explicit calls to `$PAGER` still works.

## Colorful command suggestion

<!--
> **TODO — screenshot (or short gif).** Mid-typing: a mistyped command name in
> red from the syntax highlighter, and a grey autosuggestion completing a
> previous command ahead of the cursor.
-->

Mistakes and repeats stand out before you hit enter:

- A command name that won't resolve is red as you type it
  (`zsh-syntax-highlighting`).
- The rest of a command you've run before shows ahead of the cursor in grey
  (`zsh-autosuggestions`); `→` accepts it.

## Lazy navigation

<!--
> **TODO — screenshot (or short gif).** `z <partial>` jumping to a deep
> project directory; then `Ctrl-R` open with a fuzzy history search narrowing
> as you type.
-->

Get anywhere with less keystrokes:

- `z api` — cd to the directory you visit most that matches `api` (`zoxide`).
- Tab completion matches by substring and case-insensitively, not just
  prefix: `bat<TAB>` can complete to `20-bat.zsh`, `zs<TAB>` to
  `zsh`/`zsh-private`.
- `Ctrl-T` — fuzzy-pick a file or dir into the current command line (`fzf`).
- `Ctrl-R` — fuzzy search the full shell history (`fzf`).
- Type a prefix and press `↑` to walk only the history lines that start with
  it — `git ` then `↑` cycles your past git commands, not everything.

## Project environment without the ceremony

`direnv` and `mise` included by default.

## Caps Lock

Tap it for `Esc`, hold it for `Ctrl`;
`Ctrl` + `I` / `J` / `K` / `L` are arrow keys.

---

## Layout

| Path | |
|------|--|
| `Brewfile` | CLI tools and apps |
| `zsh/config/` | shell config, one topic per numbered file |
| `ghostty/` | terminal ([Ghostty](https://ghostty.org)) |
| `ohmyposh/` | prompt theme |
| `karabiner/` | the Caps Lock remap |
| `install.sh` / `backup.sh` / `restore.sh` | link, snapshot, roll back |

Anything machine-specific or private — work aliases, tokens, per-host paths —
goes in `~/.config/zsh-private/*.zsh`. It's sourced if present and never
committed.
