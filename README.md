# dotfiles

shell config the dumb way

## Setup

```sh
git clone https://github.com/rorycaraher/dotfiles ~/dotfiles && cd ~/dotfiles
./bootstrap.sh     # Homebrew and Brewfile
./install.sh       # symlink configs, then realise mise tools
./macos.sh         # optional: macOS defaults
exec zsh
```

Each script re-runs cleanly and only adds what's missing. Add `-n` to any
to preview exactly what it will do. Any config file already in place is kept
next to its replacement as `<name>.bak.<timestamp>`.

---

## Useful state in your prompt

`git status` summary in your prompt, refreshed every command.
`❯` turns red after a non-zero exit code.

## `ls` shows file state, not just names

`ls` replaced by `eza` shows permissions, size, mtime, and per-file
git status, coloured by type. `lt` draws a tree, `la` includes dotfiles.

## Syntax highlighting everywhere

Highlighting applied everywhere, implicit paging diabled everywhere.
`cat` is aliased to `bat --paging=never`, adds syntax
highlighting and line numbers without dropping into a pager.
Explicit calls to `$PAGER` still works.

## Colorful command suggestion

Mistakes and repeats stand out before you hit enter:

- A command name that won't resolve is red as you type it
  (`zsh-syntax-highlighting`).
- The rest of a command you've run before shows ahead of the cursor in grey
  (`zsh-autosuggestions`); `→` accepts it.

## Lazy navigation

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
live file (keeping the previous copy as `settings.json.bak`). So **change those settings in
`claude/settings.json` and re-run `./install.sh`**, not via `/config` — a
`/config` change to a managed key gets reverted on the next install.

No global MCP servers, by design — they cost context every session. Add them
at project scope when a project needs one.

## macOS defaults

`./macos.sh` is opt-in; `install.sh` never runs it. It only writes settings
that differ, `-n` previews the changes, and it restarts the Dock, Finder or
`SystemUIServer` so they apply without a log out. Among them, screenshots go
to `~/Screenshots` (created if missing) as PNG, without the window drop
shadow, instead of the Desktop.

## Caps Lock

Tap it for `Esc`, hold it for `Ctrl`;
hold + `I` / `J` / `K` / `L` are arrow keys. Held, it sends *right* `Ctrl`,
so the physical left `Ctrl` + `H` / `J` / `K` / `L` still reach nvim's
window navigation.

---

## Layout

| Path | |
|------|--|
| `Brewfile` | CLI tools and apps |
| `zsh/config/` | shell config, one topic per numbered file |
| `nvim/` | Neovim config (lazy.nvim, native LSP) |
| `git/` | global git ignore |
| `mise/` | global `mise` config (thin) |
| `terraform/` | shared CLI config + provider plugin cache |
| `claude/` | global agent instructions + merged `settings.json` |
| `templates/` | skeletons to copy into project repos |
| `ghostty/` | terminal ([Ghostty](https://ghostty.org)) |
| `ohmyposh/` | prompt theme |
| `karabiner/` | the Caps Lock remap, merged into `karabiner.json` |
| `zed/` | editor config |
| `bootstrap.sh` / `install.sh` | Homebrew bundle, symlinks |
| `macos.sh` | macOS `defaults` |

Standalone scripts aren't config and live in their own repo; `~/tools/bin` is
on `PATH` if it exists.

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
