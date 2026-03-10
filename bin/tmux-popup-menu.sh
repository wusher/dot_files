#!/bin/bash

# Searchable tmux command palette for prefix+space.

if ! command -v fzf >/dev/null 2>&1; then
  printf 'fzf is required for command palette.\n'
  printf 'Install with: brew install fzf\n'
  sleep 2
  exit 0
fi

selection=$(
  cat <<'EOF' | fzf --prompt='tmux> ' --height=100% --layout=reverse --border=none --delimiter=$'\t' --with-nth=2
new_window	󰐘  New Window
split_vertical	󰤼  Split Vertical
split_horizontal	󰤻  Split Horizontal
zoom	󰓚  Zoom Toggle
scratch	󰩹  Scratch Toggle
resize_mode	󰩨  Enter Resize Mode
copy_mode	󰆏  Enter Copy Mode
rename_window	󰑕  Rename Window
rename_session	󰑕  Rename Session
kill_pane	󰅖  Kill Pane
kill_window	󰅙  Kill Window
detach	󰗼  Detach Client
choose_tree	󰙅  Session/Window Tree
last_window	󰕮  Last Window
command_prompt	󰘳  Command Prompt
show_keys	󰌌  Show Keybindings
reload	󰑐  Reload Config
quit	󰿅  Cancel
EOF
)

[ -z "$selection" ] && exit 0

action=${selection%%$'\t'*}

case "$action" in
  new_window) tmux new-window -c "#{pane_current_path}" ;;
  split_vertical) tmux split-window -h -c "#{pane_current_path}" ;;
  split_horizontal) tmux split-window -v -c "#{pane_current_path}" ;;
  zoom) tmux resize-pane -Z ;;
  scratch) tmux send-keys "C-a" "." ;;
  resize_mode) tmux switch-client -T resize ;;
  copy_mode) tmux copy-mode ;;
  rename_window) tmux command-prompt -I "#W" "rename-window '%%'" ;;
  rename_session) tmux command-prompt -I "#S" "rename-session '%%'" ;;
  kill_pane) tmux kill-pane ;;
  kill_window) tmux kill-window ;;
  detach) tmux detach-client ;;
  choose_tree) tmux choose-tree -Zw ;;
  last_window) tmux last-window ;;
  command_prompt) tmux command-prompt ;;
  show_keys) tmux display-popup -E -w 90% -h 90% "tmux list-keys | less" ;;
  reload) tmux source-file ~/.tmux.conf \; display "Config reloaded" ;;
  quit) exit 0 ;;
esac
