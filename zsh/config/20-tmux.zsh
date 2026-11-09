# 33% left (70% gbox / 30% shell), 66% right nvim
dev() {
  local name="${1:-${PWD:t}}"
  if tmux has-session -t "=$name" 2>/dev/null; then
    tmux attach -t "=$name" || tmux switch-client -t "=$name"
    return
  fi
  tmux new-session -d -s "$name" -c "$PWD" nvim
  tmux split-window -hb -l 33% -t "$name:1.1" -c "$PWD"
  tmux split-window -v -l 30% -t "$name:1.1" -c "$PWD"
  tmux send-keys -t "$name:1.1" gbox Enter
  tmux select-pane -t "$name:1.3"
  tmux attach -t "=$name" 2>/dev/null || tmux switch-client -t "=$name"
}
