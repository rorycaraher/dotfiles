#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES/lib/ui.sh"
source "$DOTFILES/lib/paths.sh"

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    *)            err "usage: install.sh [--dry-run|-n]"; exit 2 ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "$*"
  else
    "$@"
  fi
}

link() {
  local src="$DOTFILES/$1"
  local dest="$2"

  # Already the correct symlink: nothing to do.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    tag "$C_GREEN" OK "$dest ${C_DIM}(already linked)${C_RESET}"
    return
  fi

  # Any other symlink (wrong target or dangling): replace it, no backup.
  if [ -L "$dest" ]; then
    tag "$C_YELLOW" RELINK "$dest -> $src"
    run ln -sfn "$src" "$dest"
    return
  fi

  # A real file/dir: timestamped .bak so repeat runs don't clobber an earlier one.
  if [ -e "$dest" ]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    tag "$C_YELLOW" KEPT "$dest ${C_DIM}->${C_RESET} $backup"
    run mv "$dest" "$backup"
  fi

  tag "$C_CYAN" LINK "$dest -> $src"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
}

for pair in "${PAIRS[@]}"; do
  link "${pair%%::*}" "${pair##*::}"
done

# Not a symlink: Claude Code writes settings.json itself. Merge the repo's
# portable keys over the live file, keeping host-only keys like autoMode.
merge_claude_settings() {
  local src="$DOTFILES/claude/settings.json"
  local dest="$HOME/.claude/settings.json"

  if [ -L "$dest" ]; then
    warn "$dest is a symlink -- skipping. settings.json must be a real file Claude can write."
    return
  fi

  if [ ! -e "$dest" ]; then
    tag "$C_CYAN" COPY "$dest ${C_DIM}(new)${C_RESET}"
    run mkdir -p "$(dirname "$dest")"
    run cp "$src" "$dest"
    return
  fi

  # jq is assumed present (macOS ships it).

  # Applying repo keys over the live file changes nothing => already in sync.
  if jq -e --slurpfile r "$src" '. as $live | ($live * $r[0]) == $live' "$dest" >/dev/null 2>&1; then
    tag "$C_GREEN" OK "$dest ${C_DIM}(settings in sync)${C_RESET}"
    return
  fi

  local backup="$dest.bak"
  tag "$C_YELLOW" MERGE "$dest ${C_DIM}(repo keys over local; previous copy ->${C_RESET} $backup${C_DIM})${C_RESET}"
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "jq -s '.[0] * .[1]' $dest $src > $dest"
    return
  fi
  cp "$dest" "$backup"
  local tmp; tmp="$(mktemp)"
  if jq -s '.[0] * .[1]' "$backup" "$src" > "$tmp" && jq -e . "$tmp" >/dev/null 2>&1; then
    mv "$tmp" "$dest"
  else
    rm -f "$tmp"
    err "settings.json merge failed -- left $dest untouched (previous copy at $backup)."
  fi
}

step "Merging ~/.claude/settings.json..."
merge_claude_settings

# Not a symlink: Karabiner writes karabiner.json itself and hot-reloads it on
# change. Upsert the repo's rules, matched by description, into the selected profile.
merge_karabiner_rules() {
  local src="$DOTFILES/karabiner/capslock-ijkl.json"
  local dest="$HOME/.config/karabiner/karabiner.json"

  if [ -L "$dest" ]; then
    warn "$dest is a symlink -- skipping. karabiner.json must be a real file Karabiner can write."
    return
  fi

  if [ ! -f "$dest" ]; then
    tag "$C_DIM" SKIP "karabiner.json not found ${C_DIM}(Karabiner-Elements not set up yet)${C_RESET}"
    return
  fi

  local tmp; tmp="$(mktemp)"
  if ! jq --slurpfile r "$src" '
    $r[0].rules as $new
    | (.profiles[] | select(.selected) | .complex_modifications.rules) |= (
        (. // []) as $live
        | ($live | map(. as $l | ($new | map(select(.description == $l.description)) | .[0]) // $l))
          + ($new | map(select(.description as $d | $live | any(.description == $d) | not)))
      )
  ' "$dest" > "$tmp"; then
    rm -f "$tmp"
    err "karabiner.json merge failed -- left $dest untouched."
    return
  fi

  if jq -e --slurpfile m "$tmp" '. == $m[0]' "$dest" >/dev/null; then
    rm -f "$tmp"
    tag "$C_GREEN" OK "$dest ${C_DIM}(rules in sync)${C_RESET}"
    return
  fi

  local backup="$dest.bak"
  tag "$C_YELLOW" MERGE "$dest ${C_DIM}(repo rules into selected profile; previous copy ->${C_RESET} $backup${C_DIM})${C_RESET}"
  if [ "$DRY_RUN" -eq 1 ]; then
    rm -f "$tmp"
    dry "jq <upsert rules by description> $dest > $dest"
    return
  fi
  cp "$dest" "$backup"
  mv "$tmp" "$dest"
}

step "Merging Karabiner rules..."
merge_karabiner_rules

step "Creating runtime directories..."
run mkdir -p "$HOME/.terraform.d/plugin-cache" "$HOME/.tflint.d/plugins"

# Realise the pinned tools from the config we just linked. Non-fatal.
if command -v mise >/dev/null 2>&1; then
  step "Installing mise tools..."
  run mise install || warn "mise install failed -- run 'mise install' by hand later."
fi

step "Done."
if [ "$DRY_RUN" -eq 0 ]; then
  printf '    Start a new shell, or run: %sexec zsh%s\n' "$C_BOLD" "$C_RESET"
fi
