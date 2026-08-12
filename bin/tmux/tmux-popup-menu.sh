#!/bin/bash

# Searchable tmux session switcher for prefix+space.

set -euo pipefail

ansi_reset=$'\033[0m'

truncate_text() {
  local text="$1"
  local max_len="$2"

  if (( ${#text} <= max_len )); then
    printf '%s' "$text"
    return
  fi

  if (( max_len <= 3 )); then
    printf '%s' "${text:0:max_len}"
    return
  fi

  printf '%s...' "${text:0:max_len-3}"
}

format_activity() {
  local epoch="$1"

  if [[ -z "$epoch" ]]; then
    printf '-'
    return
  fi

  date -r "$epoch" '+%m-%d %H:%M' 2>/dev/null || printf '%s' "$epoch"
}

workstate_for_path() {
  local pane_path="$1"
  local root cur state_file state icon label color

  root=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null || true)
  if [[ -n "$root" && -f "$root/.workstate" ]]; then
    state_file="$root/.workstate"
  else
    cur="$pane_path"
    while [[ "$cur" != "/" ]]; do
      if [[ -f "$cur/.workstate" ]]; then
        state_file="$cur/.workstate"
        break
      fi
      cur=$(dirname "$cur")
    done
  fi

  if [[ -n "${state_file:-}" ]]; then
    state=$(tr '[:upper:]' '[:lower:]' < "$state_file" | tr -d '[:space:]')
  else
    state=""
  fi

  case "$state" in
    wip)
      icon="󱨎"; label="WIP"; color=$'\033[38;5;114m'
      ;;
    review)
      icon="󰔟"; label="REVIEW"; color=$'\033[38;5;201m'
      ;;
    feedback)
      icon="󰤉"; label="FEEDBACK"; color=$'\033[38;5;204m'
      ;;
    fixing-ci)
      icon="󰙨"; label="FIXING-CI"; color=$'\033[38;5;204m'
      ;;
    exploring)
      icon="󱗖"; label="EXPLORING"; color=$'\033[38;5;73m'
      ;;
    blocked)
      icon="󰜺"; label="BLOCKED"; color=$'\033[38;5;179m'
      ;;
    post-deploy)
      icon=""; label="POST-DEPLOY"; color=$'\033[38;5;179m'
      ;;
    done)
      icon="󰄬"; label="DONE"; color=$'\033[38;5;77m'
      ;;
    *)
      icon=""; label="NONE"; color=$'\033[38;5;245m'
      ;;
  esac

  printf '%s\t%s\t%s' "$icon" "$label" "$color"
}

if ! command -v fzf >/dev/null 2>&1; then
  tmux choose-tree -s
  exit 0
fi

session_rows=$(tmux list-sessions -F '#{session_id}	#{session_name}	#{session_attached}	#{session_activity}')

choices=""
while IFS=$'\t' read -r session_id session_name session_attached session_activity; do
  local_ws=""
  local_ws_icon=""
  local_ws_label=""
  local_ws_color=""
  local_ws_plain=""
  local_ws_cell=""
  local_ws_display=""
  local_ws_icon_display=""
  local_session_cell=""
  local_panes_cell=""
  local_activity_cell=""
  local_attached_cell=""
  local_display_line=""
  pane_rows=""
  pane_count=""
  pane_path=""
  display_path=""
  activity_display=""

  pane_rows=$(tmux list-panes -t "$session_id" -F '#{window_active}	#{pane_active}	#{pane_current_path}')
  pane_count=$(printf '%s\n' "$pane_rows" | wc -l | tr -d ' ')
  pane_path=$(printf '%s\n' "$pane_rows" | awk -F '\t' '$1 == 1 && $2 == 1 { print $3; exit }')
  if [[ -z "$pane_path" ]]; then
    pane_path=$(printf '%s\n' "$pane_rows" | awk -F '\t' 'NR == 1 { print $3; exit }')
  fi

  display_path="${pane_path/#$HOME/\~}"
  local_ws=$(workstate_for_path "$pane_path")
  IFS=$'\t' read -r local_ws_icon local_ws_label local_ws_color <<< "$local_ws"
  local_ws_label="${local_ws_label:0:6}"
  local_ws_plain="$local_ws_label"
  printf -v local_ws_cell '%-6s' "$local_ws_plain"
  local_ws_display="${local_ws_color}${local_ws_cell}${ansi_reset}"
  local_ws_icon_display="${local_ws_color}${local_ws_icon}${ansi_reset}"

  activity_display=$(format_activity "$session_activity")

  if [[ "$session_attached" != "0" ]]; then
    attached_display='*'
  else
    attached_display=' '
  fi

  printf -v local_session_cell '%-24s' "$(truncate_text "$session_name" 24)"
  printf -v local_panes_cell '%5s' "$pane_count"
  printf -v local_activity_cell '%-11s' "$activity_display"
  printf -v local_attached_cell '%1s' "$attached_display"
  local_display_line="${local_attached_cell} ${local_session_cell} ${local_panes_cell} ${local_activity_cell} ${local_ws_display} ${display_path} ${local_ws_icon_display}"

  choices+="$session_id"
  choices+=$'\t'
  choices+="$local_display_line"
  choices+=$'\n'
done <<< "$session_rows"

selection=$(printf '%s' "$choices" \
  | fzf --prompt='session> ' \
        --height=100% \
        --layout=reverse \
        --border=none \
        --ansi \
        --no-exact \
        --delimiter=$'\t' \
        --with-nth=2 \
        --exit-0 \
        --select-1)

[ -z "$selection" ] && exit 0

target=${selection%%$'\t'*}

tmux switch-client -t "$target"
