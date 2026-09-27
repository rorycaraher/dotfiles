# Dotfiles review: open points

From the size/sanity review. Ruby config is removed and screenshots are
documented, so what's left is below, roughly by how much a decision is needed.
Verdict so far: still small (~570 lines of shell, ~60 files) and sane.

## 1. Exceptions to "`PAIRS` is the single source of truth"

`AGENTS.md` says `lib/paths.sh` `PAIRS` is the one place managed things live.
Three things now sit outside it:

- `~/.claude/settings.json`, merged with `jq` (documented as an exception)
- Karabiner rules, drift-checked and pasted by hand (not documented as one)
- `macos.sh`, a standalone script that isn't run by `install.sh` (not documented)

Questions:
- Does `AGENTS.md` list all of them, or is the rule going to drift?
- Should `macos.sh` stay opt-in and separate, or be called from `install.sh`?
- Should `AGENTS.md`'s `macos.sh` row list screenshots and scrolling? It
  currently says "(text, trackpad, Dock, Finder)".

## 2. The Karabiner block in `install.sh`

About 50 of the 173 lines: an interactive flow that copies one rule to the
clipboard, opens Karabiner-Elements and waits for a paste. It exists because
Karabiner copies a rule into `karabiner.json` on enable, so edits to the
symlinked asset never reach the live config.

Questions:
- Is the drift check worth its size for one rule?
- Would a simpler check (warn on drift, print the manual steps) do?
- Could the rule live in `karabiner.json` directly instead, as a merged file
  like `settings.json`?

## 3. `zsh/config/20-ffmpeg.zsh`

76 lines of helper functions, more than any other fragment. It's a function
library rather than config, and it breaks the "one topic, small fragment"
shape.

Questions:
- Leave it, or split functions out of the fragment (autoloaded function dir)?
- Does the length matter, or only if a second one appears?

## 4. Unmanaged git config

`~/.gitconfig` isn't in `PAIRS`. `20-git.zsh` is 4 lines, so identity,
aliases, pager and global ignore live only on this machine.

Questions:
- Manage `~/.config/git/config` and `~/.config/git/ignore`?
- How to handle identity per host (an include from a private file)?

## 5. README gaps

- TODO screenshot placeholders (HTML comments) remain in several sections.
- Covers the shell only. No mention of nvim, Ghostty, Zed or Karabiner
  behaviour beyond the Caps Lock section and the layout table.
- The Layout table has no row for `macos.sh`, `nvim/` or `ghostty/`'s
  keybinds.
- The file ends with a stray line, `y # modified marker`, after the last
  code block. It looks accidental.

Questions:
- Fill in the screenshots or delete the placeholders?
- How much of nvim and macOS config belongs in the README?

## Not decided

- Whether `cask "tflint"` in the `Brewfile` is right. I didn't verify it; tflint
  may be a formula rather than a cask.
