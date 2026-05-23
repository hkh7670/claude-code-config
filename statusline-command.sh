#!/usr/bin/env bash

input=$(cat)
NOW=$(date +%s)

# Catppuccin Macchiato palette (truecolor)
MAUVE=$'\033[38;2;198;160;246m'
BLUE=$'\033[38;2;138;173;244m'
TEAL=$'\033[38;2;139;213;202m'
GREEN=$'\033[38;2;166;218;149m'
YELLOW=$'\033[38;2;238;212;159m'
RED=$'\033[38;2;237;135;150m'
PEACH=$'\033[38;2;245;169;127m'
FLAMINGO=$'\033[38;2;240;198;198m'
LAVENDER=$'\033[38;2;183;189;248m'
OVERLAY=$'\033[38;2;110;115;141m'
SUBTEXT=$'\033[38;2;165;173;203m'
RST=$'\033[0m'
SEP=" ${OVERLAY}│${RST} "

# Parse JSON in a single jq call
{
  read -r MODEL
  read -r DIR
  read -r CTX_PCT
  read -r CTX_SIZE
  read -r FIVE_PCT
  read -r FIVE_RESET
  read -r SEVEN_PCT
  read -r SEVEN_RESET
  read -r COST
} < <(echo "$input" | jq -r '
  (.model.display_name // "—"),
  (.workspace.current_dir // .cwd // ""),
  (.context_window.used_percentage // ""),
  (.context_window.context_window_size // 200000),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (.cost.total_cost_usd // 0)
')

# Context window size → human label (200k / 1M)
if [[ "$CTX_SIZE" =~ ^[0-9]+$ ]] && (( CTX_SIZE >= 1000000 )); then
  CTX_LABEL="$((CTX_SIZE / 1000000))M"
else
  CTX_LABEL="$((CTX_SIZE / 1000))k"
fi

# Clickable directory (OSC 8 hyperlink)
DNAME="${DIR##*/}"
DIR_SEG="${BLUE}󰉋 "$'\033]8;;file://'"${DIR}"$'\033\\'"${DNAME}"$'\033]8;;\033\\'"${RST}"

# Git status (cached 5s per dir)
GIT=""
if [[ -n "$DIR" ]]; then
  CF="/tmp/claudeline-$(echo "$DIR" | cksum | cut -d' ' -f1)"
  BRANCH="" STAGED=0 MODIFIED=0
  if [[ -f "$CF" ]] && (( NOW - $(stat -f %m "$CF") < 5 )); then
    IFS=$'\t' read -r BRANCH STAGED MODIFIED < "$CF"
  elif GIT_OPTIONAL_LOCKS=0 git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(GIT_OPTIONAL_LOCKS=0 git -C "$DIR" branch --show-current 2>/dev/null)
    while IFS= read -r l; do
      [[ "${l:0:1}" != " " && "${l:0:1}" != "?" ]] && ((STAGED++))
      [[ "${l:1:1}" != " " && "${l:1:1}" != "?" ]] && ((MODIFIED++))
    done < <(GIT_OPTIONAL_LOCKS=0 git -C "$DIR" status --porcelain 2>/dev/null)
    printf '%s\t%s\t%s' "$BRANCH" "$STAGED" "$MODIFIED" > "$CF"
  fi
  if [[ -n "$BRANCH" ]]; then
    GIT="${SEP}${TEAL}󰘬 ${BRANCH}${RST}"
    (( STAGED > 0 ))   && GIT+=" ${GREEN}+${STAGED}${RST}"
    (( MODIFIED > 0 )) && GIT+=" ${YELLOW} ${MODIFIED}${RST}"
  fi
fi

# ═══ LINE 1: model · dir · git ═══════════════════════════════════
printf '%s\n' "${MAUVE}✦ ${MODEL} ${OVERLAY}(${CTX_LABEL} context)${RST}${SEP}${DIR_SEG}${GIT}"

# Context usage percent (falls back to 5h if context field missing)
PCT_SRC=""
if [[ -n "$CTX_PCT" && "$CTX_PCT" != "null" ]]; then
  PCT_SRC="$CTX_PCT"
elif [[ -n "$FIVE_PCT" && "$FIVE_PCT" != "null" ]]; then
  PCT_SRC="$FIVE_PCT"
fi
PCT=0
if [[ -n "$PCT_SRC" ]]; then
  PCT=$(printf '%.0f' "$PCT_SRC")
  (( PCT < 0 )) && PCT=0
  (( PCT > 100 )) && PCT=100
fi

# Lavender gradient bar (light → dark, single hue, no tier switching)
WIDTH=20
FILLED=$(( (PCT * WIDTH + 50) / 100 ))
(( FILLED > WIDTH )) && FILLED=$WIDTH
EMPTY=$((WIDTH - FILLED))

LT_R=196; LT_G=181; LT_B=253
DK_R=109; DK_G=40;  DK_B=217

BAR=""
if (( FILLED > 0 )); then
  DENOM=$(( FILLED > 1 ? FILLED - 1 : 1 ))
  for ((i=0; i<FILLED; i++)); do
    r=$(( LT_R + (DK_R - LT_R) * i / DENOM ))
    g=$(( LT_G + (DK_G - LT_G) * i / DENOM ))
    b=$(( LT_B + (DK_B - LT_B) * i / DENOM ))
    BAR+=$'\033[38;2;'"${r};${g};${b}m█"
  done
  BAR+="$RST"
fi
if (( EMPTY > 0 )); then
  BAR+=$'\033[38;2;120;120;135m\033[48;2;48;48;58m'
  for ((i=0; i<EMPTY; i++)); do BAR+="⣿"; done
  BAR+="$RST"
fi

# 5h rate limit with reset countdown
RLIM=""
if [[ -n "$FIVE_PCT" && "$FIVE_PCT" != "null" ]]; then
  FI=$(printf '%.0f' "$FIVE_PCT")
  if   (( FI >= 80 )); then RC="$RED"
  elif (( FI >= 50 )); then RC="$YELLOW"
  else                       RC="$LAVENDER"
  fi
  RLIM="${SEP}${RC}󰥔 5h: ${FI}%${RST}"
  if [[ -n "$FIVE_RESET" && "$FIVE_RESET" != "null" ]]; then
    REM=$((FIVE_RESET - NOW))
    (( REM > 0 )) && RLIM+=" ${SUBTEXT}$((REM / 3600))h$(((REM % 3600) / 60))m${RST}"
  fi
fi

# 7d rate limit
if [[ -n "$SEVEN_PCT" && "$SEVEN_PCT" != "null" ]]; then
  SI=$(printf '%.0f' "$SEVEN_PCT")
  if   (( SI >= 80 )); then SC="$RED"
  elif (( SI >= 50 )); then SC="$YELLOW"
  else                       SC="$SUBTEXT"
  fi
  RLIM+="${SEP}${SC}7d: ${SI}%${RST}"
  if [[ -n "$SEVEN_RESET" && "$SEVEN_RESET" != "null" ]]; then
    REM=$((SEVEN_RESET - NOW))
    if (( REM > 0 )); then
      D=$((REM / 86400))
      H=$(((REM % 86400) / 3600))
      RLIM+=" ${SUBTEXT}${D}d${H}h${RST}"
    fi
  fi
fi

# Cost
COST_SEG=""
if [[ -n "$COST" && "$COST" != "null" && "$COST" != "0" ]]; then
  COST_FMT=$(printf '$%.2f' "$COST")
  COST_SEG="${SEP}${OVERLAY}${COST_FMT}${RST}"
fi

# ═══ LINE 2: bar · 5h · 7d · cost ═════════════════════════════════
printf '%s\n' "${BAR} ${LAVENDER}${PCT}%${RST}${RLIM}${COST_SEG}"
