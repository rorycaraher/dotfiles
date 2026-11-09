# tm <layout> [session]: launch a tmux layout; SANDBOX (default rsbx) picks the sandbox tool
tm() {
  local layout="$1" name="${2:-${PWD:t}}"
  case "$layout" in
    dev) ;;
    *) print -u2 "usage: tm dev [session]"; return 1 ;;
  esac
  if tmux has-session -t "=$name" 2>/dev/null; then
    tmux attach -t "=$name" || tmux switch-client -t "=$name"
    return
  fi
  tmux new-session -d -s "$name" -c "$PWD" nvim .
  tmux split-window -hb -l 33% -t "$name:1.1" -c "$PWD"
  tmux split-window -v -l 30% -t "$name:1.1" -c "$PWD"
  tmux send-keys -t "$name:1.1" "${SANDBOX:-rsbx}" Enter
  tmux select-pane -t "$name:1.3"
  tmux attach -t "=$name" 2>/dev/null || tmux switch-client -t "=$name"
}
