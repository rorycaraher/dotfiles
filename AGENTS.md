# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) and other agents
when working with code in this repository. `CLAUDE.md` is a one-line
`@AGENTS.md` shim so Claude Code reads it too.

A macOS dotfiles repo: Homebrew bundle and symlinked configs. No build, no
test suite, no linter, no CI.

## Commands

| | |
|---|---|
| `./bootstrap.sh [-n]` | install Homebrew if missing, then `brew bundle` the `Brewfile` |
| `./install.sh [-n]` | symlink managed paths, merge `~/.claude/settings.json`, make runtime dirs, `mise install` |
| `brew bundle check` | verify Brewfile deps are satisfied |

- Every script takes `--dry-run`/`-n`. **Dry-run first** whenever you change
  script logic — it's the only safety net.
- The only pre-handoff check that exists: `bash -n *.sh lib/*.sh` and
  `zsh -n zsh/config/*.zsh`.

## Architecture

**`lib/paths.sh` `PAIRS` is the single source of truth for managed
symlinks.** Each entry is `"<repo-relative source>::<absolute dest>"`.
`install.sh` iterates it — adding a managed dotfile means adding one line
here, nothing else.

**`~/.claude/settings.json` is the one deliberate exception** — not in
`PAIRS`. `install.sh`'s `merge_claude_settings()` deep-merges the repo's
`claude/settings.json` (portable keys only) *over* the live file with `jq`,
because Claude Code writes to that file itself (the `autoMode` block, `/config`
changes). Repo wins on shared keys; host-only keys are preserved. Consequence:
change those settings in `claude/settings.json` and re-run `install.sh`, never
via `/config`.

**`install.sh` is idempotent.** `link()` handles three cases: already-correct
symlink (noop), any other symlink (silent relink), real file/dir (timestamped
`.bak.<stamp>` then link). That `.bak` is the whole safety net — no prompts,
no snapshots, no restore script. The `settings.json` merge keeps one rolling
`settings.json.bak`.

**zsh config is numbered fragments.** `zsh/zshrc` sources
`~/.config/zsh/*.zsh` in lexical order, then `~/.config/zsh-private/*.zsh`
(host-specific, never committed, loaded if present). `zsh/config/` is
symlinked as a whole directory. Numbering: `00` PATH, `10` shell core, `20`
per-tool config, `40` shell hooks that must run after tools exist
(`mise activate`, `direnv hook`), `90+` prompt and plugins last. New topic =
new numbered file.

**Two host-specific escape hatches, same shape:**
`~/.config/zsh-private/*.zsh` (shell) and `~/.config/mise/conf.d/*.toml`
(mise tools) — both auto-loaded by their tool, both unmanaged, both gitignored.

**`nvim/` is symlinked whole to `~/.config/nvim`.** `init.lua` sets the
leader, then loads `lua/config/{options,keymaps,lsp,lazy}`. lazy.nvim loads
one plugin spec per file in `lua/plugins/`; `lazy-lock.json` is committed.
LSP uses native `vim.lsp.enable()` — one `lsp/<server>.lua` per server,
enabled in `config/lsp.lua`. Language servers come from the `Brewfile`, not
Mason. Per-filetype options go in `after/ftplugin/<ft>.lua`.

**Tool ownership boundaries:** `mise` = language runtimes + version-sensitive
tools (pinned per-repo in `mise.toml`; global `mise/config.toml` stays thin).
`direnv` = env vars. Homebrew = leaf CLI tools + all casks. `tf` (in
`zsh/config/20-terraform.zsh`) runs `${TF_BINARY:-tofu}`; a host needing
Terraform sets `TF_BINARY=terraform` in `zsh-private/`.

**`claude/` and `templates/` are deployed payloads, not repo meta.**
`claude/AGENTS.md` + `claude/CLAUDE.md` are the *global* `~/.claude/`
instructions this repo installs on the machine — unrelated to this file.
`templates/AGENTS.md` is a skeleton to copy into *other* projects.

## Comments

Default to none. Comment only what the code can't say: a non-obvious *why*,
a gotcha, a constraint, a reference.

- Never restate the next line.
- No banner/divider comments.
- One line. A paragraph belongs in the commit message or a doc.
- File-top line only if the filename doesn't already say it.

e.g. `# syntax-highlighting cat, no pager`
not  `# cat replacement — syntax highlighting, no line numbers or paging by
default, so it behaves like plain cat unless you ask for more`

## Conventions

- Every script: `set -euo pipefail`, then
  `DOTFILES="$(cd "$(dirname "$0")" && pwd)"`, then source `lib/ui.sh`
  (+ `lib/paths.sh` where needed). Output only through `lib/ui.sh` helpers
  (`step`, `tag`, `dry`, `warn`, `err`) — they handle `NO_COLOR` / non-TTY.
- Host-neutral language only. Never "personal" / "work" machine — say "a host
  that …".
- Don't add `jq` to the `Brewfile`; macOS ships `/usr/bin/jq` and the scripts
  rely on it.
