#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES/lib/ui.sh"

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    *)            err "usage: macos.sh [--dry-run|-n]"; exit 2 ;;
  esac
done

CHANGED=0

# pref <domain> <key> <bool|int|float|string> <value>; writes only on drift.
pref() {
  local domain="$1" key="$2" type="$3" val="$4" want cur
  want="$val"
  if [ "$type" = bool ]; then
    if [ "$val" = true ]; then want=1; else want=0; fi
  fi
  cur="$(defaults read "$domain" "$key" 2>/dev/null || true)"

  if [ "$cur" = "$want" ]; then
    tag "$C_GREEN" OK "$domain $key ${C_DIM}= $val${C_RESET}"
    return
  fi

  CHANGED=1
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "defaults write $domain $key -$type $val${cur:+ ${C_DIM}(now: $cur)${C_RESET}}"
    return
  fi
  tag "$C_YELLOW" SET "$domain $key ${C_DIM}${cur:-unset} ->${C_RESET} $val"
  defaults write "$domain" "$key" "-$type" "$val"
}

step "Keyboard and text..."
pref NSGlobalDomain NSAutomaticCapitalizationEnabled bool false
pref NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled bool false

step "Trackpad..."
pref com.apple.AppleMultitouchTrackpad Clicking bool true
pref com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag bool true
pref NSGlobalDomain com.apple.swipescrolldirection bool true

step "Dock..."
pref com.apple.dock autohide bool true

step "Finder..."
pref com.apple.finder FXPreferredViewStyle string Nlsv
pref com.apple.finder NewWindowTarget string PfAF

step "Screenshots..."
pref com.apple.screencapture location string "$HOME/Screenshots"
pref com.apple.screencapture type string png
pref com.apple.screencapture disable-shadow bool true
if [ "$DRY_RUN" -eq 1 ]; then
  dry "mkdir -p $HOME/Screenshots"
else
  mkdir -p "$HOME/Screenshots"
fi

if [ "$CHANGED" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
  step "Restarting Dock, Finder, SystemUIServer..."
  killall Dock Finder SystemUIServer >/dev/null 2>&1 || true
  warn "Some changes need a log out to take effect."
fi

step "Done."
