#!/bin/bash

key_table="$1"
client_prefix="$2"
pane_mode="$3"
window_zoomed_flag="$4"

if [ "$client_prefix" = "1" ]; then
  # Prefix pressed
  printf '#[fg=#1f2335,bg=#f7768e,bold] 󰘳 #[fg=#f7768e,bg=#1f2335,nobold]'
  exit 0
fi

if [ "$pane_mode" = "1" ] || [ "$pane_mode" = "copy-mode" ] || [ "$pane_mode" = "copy-mode-vi" ]; then
  printf '#[fg=#1f2335,bg=#e0af68,bold] 󰆏 #[fg=#e0af68,bg=#1f2335,nobold]'
  exit 0
fi

case "$key_table" in
  resize)
    printf '#[fg=#1f2335,bg=#e0af68,bold] 󰩨 #[fg=#e0af68,bg=#1f2335,nobold]'
    ;;
  copy-mode|copy-mode-vi)
    printf '#[fg=#1f2335,bg=#e0af68,bold] 󰆏 #[fg=#e0af68,bg=#1f2335,nobold]'
    ;;
  *)
    if [ "$window_zoomed_flag" = "1" ]; then
      printf '#[fg=#1f2335,bg=#9aad6a,bold] 󰆍 #[fg=#9aad6a,bg=#1f2335,nobold]'
    else
      printf '#[fg=#1f2335,bg=#7aa2f7,bold] 󰆍 #[fg=#7aa2f7,bg=#1f2335,nobold]'
    fi
    ;;
esac
