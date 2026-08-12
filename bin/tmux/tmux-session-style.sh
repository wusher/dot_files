#!/bin/bash

session_name="$1"

[ -z "$session_name" ] && exit 0
tmux has-session -t "$session_name" 2>/dev/null || exit 0

case "$session_name" in
  cybersyn)
    tmux set-option -t "$session_name" status off
    ;;
  scrach|scratch)
    tmux set-option -t "$session_name" status on
    tmux set-option -t "$session_name" status-style "bg=yellow,fg=#1f2335"
    ;;
  *)
    tmux set-option -t "$session_name" status on
    tmux set-option -t "$session_name" status-style "bg=#1f2335,fg=#a9b1d6"
    ;;
esac
