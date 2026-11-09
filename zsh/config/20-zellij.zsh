# zj <layout> [session]: launch a zellij layout (session defaults to <layout>-<dir>); SANDBOX (default rsbx) is the sandbox pane command
# layouts come from ~/.config/zellij-private/layouts, then ~/.config/zellij/layouts
# an optional zj_setup_<layout> hook (e.g. in zsh-private/) takes the extra args and sets reply=(cwd session)
zj() {
  local layout="${1:-}" cwd="$PWD" name file
  local dirs=("$HOME/.config/zellij-private/layouts" "$HOME/.config/zellij/layouts")
  shift
  for file in ${^dirs}/$layout.kdl(N); do break; done
  if [[ -z "$layout" || ! -f "$file" ]]; then
    print -u2 "usage: zj <layout> [session]; layouts: $(ls ${dirs} 2>/dev/null | sed -n 's/\.kdl$//p' | sort -u | tr '\n' ' ')"
    return 1
  fi
  if (( $+functions[zj_setup_$layout] )); then
    zj_setup_$layout "$@" || return 1
    cwd="$reply[1]" name="$reply[2]"
  else
    name="${1:-$layout-${PWD:t}}"
  fi
  if zellij list-sessions -ns 2>/dev/null | grep -qxF "$name"; then
    zellij attach "$name"
  else
    (cd "$cwd" && zellij --session "$name" --new-session-with-layout "$file")
  fi
}
