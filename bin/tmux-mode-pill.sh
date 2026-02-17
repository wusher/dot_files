#!/bin/bash

key_table="$1"
client_prefix="$2"

if [ "$client_prefix" = "1" ]; then
  # Prefix pressed
  printf '#[fg=#f7768e,bg=#1f2335,bold]#[fg=#1f2335,bg=#f7768e,bold] 󰘳 #[fg=#f7768e,bg=#1f2335,nobold]'
  exit 0
fi

case "$key_table" in
  resize)
    printf '#[fg=#e0af68,bg=#1f2335,bold]#[fg=#1f2335,bg=#e0af68,bold] 󰩨 #[fg=#e0af68,bg=#1f2335,nobold]'
    ;;
  copy-mode|copy-mode-vi)
    printf '#[fg=#bb9af7,bg=#1f2335,bold]#[fg=#1f2335,bg=#bb9af7,bold] 󰆏 #[fg=#bb9af7,bg=#1f2335,nobold]'
    ;;
  *)
    printf '#[fg=#7aa2f7,bg=#1f2335,bold]#[fg=#1f2335,bg=#7aa2f7,bold] 󰆍 #[fg=#7aa2f7,bg=#1f2335,nobold]'
    ;;
esac
