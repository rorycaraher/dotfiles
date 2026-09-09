#!/usr/bin/env bash
set -euo pipefail

# Restore a snapshot taken by backup.sh. Manifest-driven and all-or-nothing:
# every path in the manifest is put back to exactly what it was, including
# paths that were absent (their symlink, if any, is removed).
#
# Usage: restore.sh [--dry-run] [--force] <timestamp|latest>

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES/lib/ui.sh"

DRY_RUN=0
FORCE=0
SNAPSHOT=""
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --force|-f)   FORCE=1 ;;
    -*)           err "unknown option: $arg"; exit 2 ;;
    *)            SNAPSHOT="$arg" ;;
  esac
done

if [ -z "$SNAPSHOT" ]; then
  err "usage: restore.sh [--dry-run] [--force] <timestamp|latest>"
  exit 2
fi

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "$*"
  else
    "$@"
  fi
}

BACKUP_ROOT="$HOME/.dotfiles-backup"
if [ "$SNAPSHOT" = latest ]; then
  SNAP="$(ls -1dt "$BACKUP_ROOT"/*/ 2>/dev/null | head -1)"
  SNAP="${SNAP%/}"
  [ -n "$SNAP" ] || { err "no snapshots in $BACKUP_ROOT"; exit 1; }
else
  SNAP="$BACKUP_ROOT/$SNAPSHOT"
fi

MANIFEST="$SNAP/manifest.json"
[ -f "$MANIFEST" ] || { err "no manifest at $MANIFEST"; exit 1; }

step "Restoring from $SNAP"

# Guard: refuse if a managed path currently holds real (non-symlink) data.
# That means local edits that were never synced into the repo and would be
# lost. --force overrides.
if [ "$FORCE" -ne 1 ]; then
  blocked=0
  while IFS= read -r original; do
    if [ -e "$original" ] && [ ! -L "$original" ]; then
      tag "$C_RED" BLOCKED "$original is real data, not a symlink (unsynced edits?)" >&2
      blocked=1
    fi
  done < <(jq -r '.entries[].original' "$MANIFEST")
  if [ "$blocked" -ne 0 ]; then
    err "refusing to overwrite; re-run with --force to override"
    exit 1
  fi
fi

jq -r '.entries[] | [.type, .original, (.saved_as // ""), (.link_target // "")] | @tsv' "$MANIFEST" \
| while IFS=$'\t' read -r type original saved_as link_target; do
  case "$type" in
    file|dir)
      tag "$C_CYAN" RESTORE "$original ${C_DIM}($type)${C_RESET}"
      run rm -rf "$original"
      run mkdir -p "$(dirname "$original")"
      run cp -Rp "$SNAP/$saved_as" "$original"
      ;;
    symlink)
      tag "$C_CYAN" SYMLINK "$original -> $link_target"
      run rm -rf "$original"
      run mkdir -p "$(dirname "$original")"
      run ln -sfn "$link_target" "$original"
      ;;
    absent)
      tag "$C_YELLOW" REMOVE "$original ${C_DIM}(was absent at backup)${C_RESET}"
      run rm -rf "$original"
      ;;
    *)
      tag "$C_RED" SKIP "$original (unknown type '$type')" >&2
      ;;
  esac
done

step "Done."
