#!/usr/bin/env bash

input=$(cat)
#echo "$input" > /tmp/statusline-debug.json

# --- Parse fields ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
fast_mode=$(echo "$input" | jq -r '.fast_mode // false')
rl_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Folder: basename of cwd
folder=$(basename "$cwd")
folder_icon=$(printf '󰝰')

# Git branch (skip optional locks, no error output)
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# Git changed files count
changed=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --short 2>/dev/null | wc -l | tr -d ' ')

# Current time
current_time=$(date '+%H:%M')

# --- ANSI colors (Snazzy palette, Pure-style) ---
RESET='\033[0m'
DIM='\033[2m'
CYAN='\033[96m'
MAGENTA='\033[95m'
YELLOW='\033[93m'
WHITE='\033[97m'
GREEN='\033[92m'
RED='\033[91m'
BLUE='\033[94m'

# --- Build progress bar ---
build_bar() {
  local pct="${1:-0}"
  local width=10
  local filled=$(( (pct * width + 50) / 100 ))
  [ $filled -gt $width ] && filled=$width
  local empty=$(( width - filled ))

  local bar_color
  if [ "$pct" -ge 80 ]; then
    bar_color="$RED"
  elif [ "$pct" -ge 50 ]; then
    bar_color="$YELLOW"
  else
    bar_color="$GREEN"
  fi

  local bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done

  printf "${bar_color}${bar}${RESET} ${WHITE}%d%%${RESET}" "$pct"
}

# --- Assemble output ---
printf "${CYAN}%s %s${RESET}" "$folder_icon" "$folder"

if [ -n "$branch" ]; then
  printf "  ${MAGENTA} %s${RESET}" "$branch"
fi

# Git changes (only show when there are uncommitted changes)
if [ -n "$changed" ] && [ "$changed" -gt 0 ] 2>/dev/null; then
  printf "  ${YELLOW} %s${RESET}" "$changed"
fi

if [ -n "$model" ]; then
  printf "  ${DIM}via${RESET}  ${YELLOW}%s${RESET}" "$model"
fi

# Fast mode indicator
if [ "$fast_mode" = "true" ]; then
  printf "  ${YELLOW}[fast]${RESET}"
fi

if [ -n "$rl_5h" ]; then
  pct_int=$(printf "%.0f" "$rl_5h")
  printf "  ${DIM}tokens${RESET}  "
  build_bar "$pct_int"
fi


printf "\n"
