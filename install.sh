#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES/lib/ui.sh"
source "$DOTFILES/lib/paths.sh"

DRY_RUN=0
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --yes|-y)     ASSUME_YES=1 ;;
    *)            err "usage: install.sh [--dry-run|-n] [--yes|-y]"; exit 2 ;;
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

  # A real file or directory: back it up with a timestamp so repeated runs
  # never clobber an earlier backup.
  if [ -e "$dest" ]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    tag "$C_YELLOW" BACKUP "$dest ${C_DIM}->${C_RESET} $backup"
    run mv "$dest" "$backup"
  fi

  tag "$C_CYAN" LINK "$dest -> $src"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
}

# When real (non-symlink) config files are present, link() will move each one
# to <path>.bak.<timestamp>. Those per-file backups work but are scattered and
# have no manifest, so undoing the whole install later is fiddly. backup.sh
# writes a single snapshot that restore.sh can replay in one command. If such a
# snapshot already exists, just proceed; otherwise, on a real run, stop and ask
# so one can be taken first. --yes and --dry-run skip the prompt.
needs_backup=0
for pair in "${PAIRS[@]}"; do
  dest="${pair##*::}"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    needs_backup=1
    break
  fi
done

if [ "$needs_backup" -eq 1 ]; then
  snapshot=""
  if [ -d "$HOME/.dotfiles-backup" ]; then
    snapshot="$(find "$HOME/.dotfiles-backup" -mindepth 2 -maxdepth 2 -name manifest.json 2>/dev/null | sort | tail -1)"
  fi

  if [ -n "$snapshot" ]; then
    step "Real config files present; snapshot exists ($(basename "$(dirname "$snapshot")")) -- proceeding."
  else
    warn "Real config files are present. link() will back each up to <path>.bak.<timestamp>,"
    warn "but for a single restorable snapshot, run ./backup.sh first."
    if [ "$DRY_RUN" -eq 0 ] && [ "$ASSUME_YES" -eq 0 ]; then
      printf 'Continue without a snapshot? [y/N] '
      read -r reply || reply=""
      case "$reply" in
        [yY] | [yY][eE][sS]) ;;
        *) err "Aborted."; exit 1 ;;
      esac
    fi
  fi
  echo
fi

for pair in "${PAIRS[@]}"; do
  link "${pair%%::*}" "${pair##*::}"
done

step "Done."
if [ "$DRY_RUN" -eq 0 ]; then
  printf '    Start a new shell, or run: %sexec zsh%s\n' "$C_BOLD" "$C_RESET"
fi
