#!/bin/bash

# Searchable tmux window switcher for prefix+space.

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
      icon="󰔟"; label="REVIEW"; color=$'\033[38;5;141m'
      ;;
    feedback)
      icon="󰤉"; label="FEEDBACK"; color=$'\033[38;5;204m'
      ;;
    fixing-ci)
      icon="󰙨"; label="FIXING-CI"; color=$'\033[38;5;204m'
      ;;
    exploring)
      icon="󱗖"; label="EXPLORING"; color=$'\033[38;5;114m'
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
  tmux choose-window
  exit 0
fi

window_rows=$(tmux list-windows -F '#{window_id}	#{window_index}:#{window_name}	#{pane_current_path}')

choices=""
while IFS=$'\t' read -r window_id window_label pane_path; do
  local_ws=""
  local_ws_icon=""
  local_ws_label=""
  local_ws_color=""
  local_ws_plain=""
  local_ws_cell=""
  local_ws_display=""
  local_ws_icon_display=""
  local_branch_short=""
  local_branch_cell=""
  local_window_cell=""
  local_display_line=""

  display_path="${pane_path/#$HOME/\~}"
  local_ws=$(workstate_for_path "$pane_path")
  IFS=$'\t' read -r local_ws_icon local_ws_label local_ws_color <<< "$local_ws"
  local_ws_label="${local_ws_label:0:6}"
  local_ws_plain="$local_ws_label"
  printf -v local_ws_cell '%-6s' "$local_ws_plain"
  local_ws_display="${local_ws_color}${local_ws_cell}${ansi_reset}"
  local_ws_icon_display="${local_ws_color}${local_ws_icon}${ansi_reset}"

  branch="-"
  if git -C "$pane_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$pane_path" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$pane_path" rev-parse --short HEAD 2>/dev/null || printf -- '-')
  fi
  local_branch_short=$(truncate_text "$branch" 40)

  printf -v local_window_cell '%-18s' "$window_label"
  printf -v local_branch_cell '%-40s' "$local_branch_short"
  local_display_line="${local_window_cell} ${local_ws_display} ${local_branch_cell} ${display_path} ${local_ws_icon_display}"

  choices+="$window_id"
  choices+=$'\t'
  choices+="$local_display_line"
  choices+=$'\n'
done <<< "$window_rows"

selection=$(printf '%s' "$choices" \
  | fzf --prompt='window> ' \
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

tmux select-window -t "$target"
