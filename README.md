# dotfiles

Overengineered mac/ghostty/zsh config

## Setup

```sh
git clone <repo> ~/dotfiles && cd ~/dotfiles
./bootstrap.sh     # Homebrew and Brewfile
./install.sh       # symlink configs, then realise mise tools
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

**`mise`** owns language runtimes and version-sensitive tools, pinned
per-repo in a project's `mise.toml`. It does *not* handle env vars (that's
`direnv`), Homebrew casks, or system libraries. The global config
(`mise/config.toml`) is deliberately thin — a fallback `opentofu` and a few
settings. Per-host tool additions go in `~/.config/mise/conf.d/*.toml`,
which mise reads automatically and this repo does not manage — the mise
equivalent of `zsh-private`.

## Terraform / OpenTofu

OpenTofu is the default. `tf` is a wrapper: it runs `tofu`, or `terraform`
where a host exports `TF_BINARY=terraform` — for a codebase not yet migrated,
or a provider/backend OpenTofu doesn't support (see the override note below).
The oh-my-zsh alias set (`tfp`, `tfa`, `tfi`, …) routes through it. `tofu`
comes from mise; `terraform` from wherever that host gets it (Homebrew,
`tfenv`, mise).

Both binaries share one provider plugin cache
(`~/.terraform.d/plugin-cache`, via `terraform/config.tfrc`) so a given
provider+version downloads once, not once per project. **When you add or bump
a provider**, regenerate the lock file for every platform your CI runs on or
linux CI will reject it:

```sh
tofu providers lock -platform=linux_amd64 -platform=darwin_arm64
```

`.tf` files are formatted on save in Zed (via `terraform-ls`).

## Claude / agents

`claude/AGENTS.md` holds the global agent instructions — kept to two rules
(git and terraform safety). `claude/CLAUDE.md` is a one-line `@AGENTS.md`
shim so Claude Code picks it up; the same pattern (`AGENTS.md` + a `CLAUDE.md`
shim) works in project repos, and `templates/AGENTS.md` is a skeleton to copy
in.

`~/.claude/settings.json` is **merged**, not symlinked — Claude Code writes
to that file itself. `install.sh` layers the repo's portable keys over the
live file (backing it up first). So **change those settings in
`claude/settings.json` and re-run `./install.sh`**, not via `/config` — a
`/config` change to a managed key gets reverted on the next install.

No global MCP servers, by design — they cost context every session. Add them
at project scope when a project needs one.

## Caps Lock

Tap it for `Esc`, hold it for `Ctrl`;
`Ctrl` + `I` / `J` / `K` / `L` are arrow keys.

---

## Layout

| Path | |
|------|--|
| `Brewfile` | CLI tools and apps |
| `zsh/config/` | shell config, one topic per numbered file |
| `mise/` | global `mise` config (thin) |
| `terraform/` | shared CLI config + provider plugin cache |
| `claude/` | global agent instructions + merged `settings.json` |
| `templates/` | skeletons to copy into project repos |
| `ghostty/` | terminal ([Ghostty](https://ghostty.org)) |
| `ohmyposh/` | prompt theme |
| `karabiner/` | the Caps Lock remap |
| `zed/` | editor config |
| `install.sh` / `backup.sh` / `restore.sh` | link, snapshot, roll back |

Anything host-specific or private — extra aliases, tokens, per-host paths —
goes in `~/.config/zsh-private/*.zsh`. It's sourced if present and never
committed. Host-specific `mise` tools go in `~/.config/mise/conf.d/*.toml` the
same way.

### A host that needs Terraform

```sh
echo 'export TF_BINARY=terraform' > ~/.config/zsh-private/terraform.zsh
```

Install `terraform` however that host standardises — Homebrew, or `tfenv` if
a `.terraform-version` file drives the version. If a version manager owns
`terraform`, keep it out of `mise` so there aren't two shims on `PATH`.
