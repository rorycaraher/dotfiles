# Shared list of managed dotfiles: "<repo-relative source>::<absolute dest>".
#
# Sourced by install.sh, backup.sh and restore.sh so the set of managed paths
# lives in exactly one place. Consumers prepend "$DOTFILES/" to the source side.

PAIRS=(
  "zsh/zshrc::$HOME/.zshrc"
  "zsh/config::$HOME/.config/zsh"
  "ghostty/config.ghostty::$HOME/.config/ghostty/config.ghostty"
  "ghostty/theme.ghostty::$HOME/.config/ghostty/theme.ghostty"
  "ghostty/keybinds.ghostty::$HOME/.config/ghostty/keybinds.ghostty"
  "ohmyposh/config.omp.json::$HOME/.config/ohmyposh/config.omp.json"
  "karabiner/capslock-ijkl.json::$HOME/.config/karabiner/assets/complex_modifications/capslock-ijkl.json"
)
