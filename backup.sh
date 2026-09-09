#!/usr/bin/env bash
set -euo pipefail

# Snapshot the current state of every dotfile install.sh manages, so the
# pre-install machine state can be restored as a set. Writes to
# ~/.dotfiles-backup/<timestamp>/ with a JSON manifest that restore.sh reads.

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES/lib/ui.sh"
source "$DOTFILES/lib/paths.sh"

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ] || [ "${1:-}" = "-n" ]; then
  DRY_RUN=1
fi

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    dry "$*"
  else
    "$@"
  fi
}

STAMP="$(date +%Y%m%d-%H%M%S)"
SNAP="$HOME/.dotfiles-backup/$STAMP"
# Never reuse an existing dir -- a second run in the same second would make
# cp -Rp nest the directory copies.
n=2
while [ -e "$SNAP" ]; do
  SNAP="$HOME/.dotfiles-backup/$STAMP-$n"
  n=$((n + 1))
done

COMMIT="$(git -C "$DOTFILES" rev-parse HEAD 2>/dev/null || echo unknown)"
DIRTY=false
if [ "$COMMIT" != unknown ]; then
  if ! git -C "$DOTFILES" diff --quiet || ! git -C "$DOTFILES" diff --cached --quiet; then
    DIRTY=true
  fi
fi

step "Backup -> $SNAP"
run mkdir -p "$SNAP"

# Build the manifest's entry array incrementally.
ENTRIES="[]"
add_entry() {
  # type, original, saved_as (or ""), link_target (or "")
  ENTRIES="$(jq \
    --arg type "$1" --arg original "$2" --arg saved_as "$3" --arg link_target "$4" \
    '. += [{
       type: $type,
       original: $original,
       saved_as:    (if $saved_as    == "" then null else $saved_as    end),
       link_target: (if $link_target == "" then null else $link_target end)
     }]' <<<"$ENTRIES")"
}

for pair in "${PAIRS[@]}"; do
  dest="${pair##*::}"
  rel="${dest#"$HOME"/}"

  if [ -L "$dest" ]; then
    target="$(readlink "$dest")"
    tag "$C_CYAN" SYMLINK "$dest -> $target"
    add_entry symlink "$dest" "" "$target"
  elif [ -d "$dest" ]; then
    tag "$C_GREEN" DIR "$dest"
    run mkdir -p "$SNAP/$(dirname "$rel")"
    run cp -Rp "$dest" "$SNAP/$rel"
    add_entry dir "$dest" "$rel" ""
  elif [ -e "$dest" ]; then
    tag "$C_GREEN" FILE "$dest"
    run mkdir -p "$SNAP/$(dirname "$rel")"
    run cp -p "$dest" "$SNAP/$rel"
    add_entry file "$dest" "$rel" ""
  else
    tag "$C_DIM" ABSENT "$dest"
    add_entry absent "$dest" "" ""
  fi
done

MANIFEST_JSON="$(jq -n \
  --arg timestamp "$STAMP" \
  --arg hostname "$(hostname)" \
  --arg commit "$COMMIT" \
  --argjson dirty "$DIRTY" \
  --argjson entries "$ENTRIES" \
  '{
     timestamp: $timestamp,
     hostname: $hostname,
     dotfiles_commit: $commit,
     dotfiles_dirty: $dirty,
     entries: $entries
   }')"

if [ "$DRY_RUN" -eq 1 ]; then
  dry "would write $SNAP/manifest.json:"
  echo "$MANIFEST_JSON"
else
  echo "$MANIFEST_JSON" >"$SNAP/manifest.json"
  step "Wrote $SNAP/manifest.json"
fi

step "Done."
