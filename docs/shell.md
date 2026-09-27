# Shell

`zsh/zshrc` sources `~/.config/zsh/*.zsh` in lexical order, then
`~/.config/zsh-private/*.zsh`. Prefix meaning: `00` PATH, `10` shell core,
`20` per-tool, `40` hooks needing tools on `PATH`, `90+` prompt and plugins.

## PATH

`~/tools/bin` and `~/.local/bin` are prepended (`00-path.zsh`).

## Aliases

<!-- BEGIN generated: aliases -->
| Alias | Expands to | File |
|---|---|---|
| `...` | `../..` | `10-navigation` |
| `....` | `../../..` | `10-navigation` |
| `.....` | `../../../..` | `10-navigation` |
| `cat` | `bat --paging=never` | `20-bat` |
| `ls` | `eza` | `20-eza` |
| `ll` | `eza -l --git` | `20-eza` |
| `la` | `eza -la --git` | `20-eza` |
| `lt` | `eza --tree` | `20-eza` |
| `gs` | `git status` | `20-git` |
| `gaa` | `git add --all` | `20-git` |
| `gapa` | `git add --patch` | `20-git` |
| `gcmsg` | `git commit --message` | `20-git` |
| `tfi` | `tf init` | `20-terraform` |
| `tfp` | `tf plan` | `20-terraform` |
| `tfa` | `tf apply` | `20-terraform` |
| `tff` | `tf fmt` | `20-terraform` |
| `tfv` | `tf validate` | `20-terraform` |
| `tfo` | `tf output` | `20-terraform` |
| `tfs` | `tf state` | `20-terraform` |
| `tfw` | `tf workspace` | `20-terraform` |
| `tfc` | `tf console` | `20-terraform` |
<!-- END generated: aliases -->

## Environment

- `EDITOR` / `VISUAL`: `nvim`
- `PAGER`: `bat --paging=always`; `MANPAGER`: bat with the `man` syntax;
  `GIT_PAGER`: `less -R`

## Navigation

- `AUTO_CD`: typing a directory name changes into it.
- `AUTO_PUSHD` + `PUSHD_IGNORE_DUPS` + `PUSHDMINUS`: `cd` builds a directory
  stack; `cd -N` counts from the other end.
- `z <query>`: jump to the best frecency match (`zoxide`).
- `Ctrl-T`: fuzzy-insert a path. `Ctrl-R`: fuzzy history search (`fzf`).

## History

50,000 lines in `~/.zsh_history`, shared live across sessions, timestamps
recorded. Duplicates are dropped everywhere (recording, saving, searching).
Commands starting with a space are not recorded. `!!`-style expansions are
shown before running (`HIST_VERIFY`).

## Completion

`compinit` with case-insensitive, substring, partial-word matching (`zs<TAB>`
→ `zsh`, `zsh-private`), an arrow-navigable menu, and coloured
group/no-match headers.

## Key bindings

Emacs keymap base (`95-keybindings.zsh`).

| Key | Action |
|---|---|
| `↑` / `↓` | history search filtered by what's already typed |
| `Delete` | forward delete |
| `Option-←` / `Option-→` | back / forward word |
| `Home` / `End` | line start / end |

`WORDCHARS='_'`, so word motions stop at punctuation like nvim does. The
Option and Home/End sequences are what Ghostty sends and what the
[Caps Lock rules](keyboard.md) emit.

## Tools

- `mise activate` and `direnv hook` (`40-*`): `mise` owns runtimes and
  version-sensitive tools (pinned per repo in `mise.toml`), `direnv` owns env
  vars.
- `zsh-autosuggestions` (grey inline suggestion, `→` accepts) and
  `zsh-syntax-highlighting` (unresolvable command names go red) are sourced
  from `/opt/homebrew/share/`.
- Prompt: `oh-my-posh` with `ohmyposh/config.omp.json`; git summary, and the
  `❯` turns red after a non-zero exit.
