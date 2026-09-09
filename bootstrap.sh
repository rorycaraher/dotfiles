#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES/lib/ui.sh"

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ] || [ "${1:-}" = "-n" ]; then
  DRY_RUN=1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  dry "would ensure Homebrew is installed (curl | bash from Homebrew/install)"
  dry "would run: brew bundle --file=$DOTFILES/Brewfile"
  exit 0
fi

step "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # The installer does not add brew to the current shell's PATH; do it so the
  # brew bundle below works on a fresh machine.
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  step "Homebrew already installed, skipping."
fi

step "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

step "Done."
