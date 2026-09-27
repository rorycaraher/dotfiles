#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES/lib/ui.sh"
source "$DOTFILES/lib/paths.sh"

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    *)            err "usage: docs.sh [--dry-run|-n]"; exit 2 ;;
  esac
done

# escape table-cell pipes, show $HOME as ~
cell() { local s="${1//|/\\|}" tilde='~'; printf '%s' "${s//$HOME/$tilde}"; }

gen_aliases() {
  local f line name val
  echo "| Alias | Expands to | File |"
  echo "|---|---|---|"
  for f in "$DOTFILES"/zsh/config/*.zsh; do
    while IFS= read -r line; do
      line="${line#alias }"; line="${line#-g }"
      name="${line%%=*}"; val="${line#*=}"
      val="${val#\'}"; val="${val%\'}"
      echo "| \`$name\` | \`$(cell "$val")\` | \`$(basename "$f" .zsh)\` |"
    done < <(grep -E '^alias ' "$f" || true)
  done
}

gen_symlinks() {
  local pair
  echo "| Repo | Destination |"
  echo "|---|---|"
  for pair in "${PAIRS[@]}"; do
    echo "| \`${pair%%::*}\` | \`$(cell "${pair##*::}")\` |"
  done
}

gen_macos() {
  echo "| Area | Domain | Key | Value |"
  echo "|---|---|---|---|"
  awk '
    /^step "/ { area = $0; sub(/^step "/, "", area); sub(/\.\.\."$/, "", area) }
    /^pref [A-Za-z]/ {
      val = $0; sub(/^pref [^ ]+ [^ ]+ [^ ]+ /, "", val); gsub(/"/, "", val)
      gsub(/\$HOME/, "~", val)
      printf "| %s | `%s` | `%s` | `%s` |\n", area, $2, $3, val
    }
  ' "$DOTFILES/macos.sh"
}

# splice <file> <block> <generator>: rewrite between the block's markers, only on drift.
splice() {
  local file="$DOTFILES/$1" name="$2" gen="$3" new out
  local begin="<!-- BEGIN generated: $name -->" end="<!-- END generated: $name -->"

  if ! grep -qF "$begin" "$file" || ! grep -qF "$end" "$file"; then
    err "$1: missing markers for '$name'"; exit 1
  fi

  new="$(mktemp)"; out="$(mktemp)"
  "$gen" > "$new"
  awk -v begin="$begin" -v end="$end" -v new="$new" '
    $0 == begin { print; while ((getline l < new) > 0) print l; skip = 1; next }
    $0 == end   { skip = 0 }
    !skip       { print }
  ' "$file" > "$out"

  if cmp -s "$file" "$out"; then
    tag "$C_GREEN" OK "$1 ${C_DIM}$name${C_RESET}"
  elif [ "$DRY_RUN" -eq 1 ]; then
    dry "would update $1 ($name)"
  else
    tag "$C_YELLOW" UPDATE "$1 ${C_DIM}$name${C_RESET}"
    cat "$out" > "$file"
  fi
  rm -f "$new" "$out"
}

step "Regenerating doc tables..."
splice docs/shell.md   aliases  gen_aliases
splice docs/install.md symlinks gen_symlinks
splice docs/macos.md   defaults gen_macos
