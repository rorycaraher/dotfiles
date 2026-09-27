# Install

```sh
./bootstrap.sh     # Homebrew (if missing), then brew bundle the Brewfile
./install.sh       # symlinks, settings merges, runtime dirs, mise install
./macos.sh         # optional: macOS defaults, see macos.md
exec zsh
```

Every script is idempotent and takes `-n` / `--dry-run` to preview.

## Symlinks

`install.sh` links every entry in `lib/paths.sh` `PAIRS`:

<!-- BEGIN generated: symlinks -->
| Repo | Destination |
|---|---|
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/config` | `~/.config/zsh` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `terraform/config.tfrc` | `~/.config/terraform/config.tfrc` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/AGENTS.md` | `~/.claude/AGENTS.md` |
| `ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` |
| `ghostty/theme.ghostty` | `~/.config/ghostty/theme.ghostty` |
| `ghostty/keybinds.ghostty` | `~/.config/ghostty/keybinds.ghostty` |
| `ohmyposh/config.omp.json` | `~/.config/ohmyposh/config.omp.json` |
| `git/ignore` | `~/.config/git/ignore` |
| `zed/settings.json` | `~/.config/zed/settings.json` |
| `zed/keymap.json` | `~/.config/zed/keymap.json` |
| `nvim` | `~/.config/nvim` |
<!-- END generated: symlinks -->

If the destination is a real file or directory it is renamed to
`<name>.bak.<timestamp>` first. A wrong symlink is silently relinked.

## Merged, not linked

Two files are written by their apps, so `install.sh` merges into them with `jq`
and keeps one rolling `.bak`:

- `~/.claude/settings.json` — see [claude-code.md](claude-code.md)
- `~/.config/karabiner/karabiner.json` — see [keyboard.md](keyboard.md)

## Brewfile

Add tools to `Brewfile` and run `./bootstrap.sh` (not bare `brew bundle`).
Language runtimes and version-sensitive tools go in `mise` instead. `jq` is
not in the Brewfile; macOS ships it.

## Host-specific config

Neither location is managed or committed.

| Path | For |
|---|---|
| `~/.config/zsh-private/*.zsh` | aliases, tokens, paths; sourced after `zsh/config/` |
| `~/.config/mise/conf.d/*.toml` | extra mise tools |
| `~/tools/bin` | standalone scripts (separate repo, on `PATH` if present) |
