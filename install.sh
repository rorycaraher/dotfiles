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

# Karabiner copies a rule into karabiner.json when it's enabled, so edits to the
# symlinked asset never reach the live config. Detect drift and hand the rule
# over via the clipboard for a manual paste.
check_karabiner_rules() {
  local src="$DOTFILES/karabiner/capslock-ijkl.json"
  local live="$HOME/.config/karabiner/karabiner.json"

  if [ ! -f "$live" ]; then
    tag "$C_DIM" SKIP "karabiner.json not found ${C_DIM}(Karabiner-Elements not set up yet)${C_RESET}"
    return
  fi

  # Rules missing from the selected profile; jq object equality ignores key order.
  local missing
  missing="$(jq -c --slurpfile a "$src" '
    (.profiles[] | select(.selected) | .complex_modifications.rules // []) as $live
    | $a[0].rules[] | select(. as $r | $live | any(. == $r) | not)
  ' "$live")"

  if [ -z "$missing" ]; then
    tag "$C_GREEN" OK "Karabiner rules ${C_DIM}(in sync)${C_RESET}"
    return
  fi

  local count; count="$(printf '%s\n' "$missing" | wc -l | tr -d ' ')"
  tag "$C_YELLOW" DRIFT "$count Karabiner rule(s) differ from the live config"

  if [ "$DRY_RUN" -eq 1 ]; then
    dry "jq '<rule>' | pbcopy, open Karabiner-Elements, then prompt to paste into Karabiner"
    return
  fi
  if [ ! -t 0 ]; then
    warn "Re-run ./install.sh interactively to copy the rule(s) to the clipboard."
    return
  fi

  local rule desc
  while IFS= read -r rule; do
    desc="$(printf '%s' "$rule" | jq -r .description)"
    printf '%s' "$rule" | jq . | pbcopy
    printf '    Copied to clipboard: %s%s%s\n' "$C_BOLD" "$desc" "$C_RESET"
    printf '    In Karabiner-Elements > Complex Modifications:\n'
    printf '      1. Remove the old version of this rule, if present\n'
    printf '      2. Add your own rule, paste (Cmd+V), and save\n'
    local n
    for n in 3 2 1; do
      printf '\r    Opening Karabiner-Elements in %s... ' "$n"
      sleep 1
    done
    printf '\r%*s\r' 45 ''
    open -a "Karabiner-Elements" || true
    printf '    Press Enter when done (or Ctrl+C to skip) '
    read -r _ || true
  done <<< "$missing"
}

step "Checking Karabiner rules..."
check_karabiner_rules

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
