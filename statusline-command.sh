#!/usr/bin/env bash

input=$(cat)
NOW=$(date +%s)

# Catppuccin Mocha palette (truecolor)
MAUVE=$'\033[38;2;203;166;247m'    # cba6f7
BLUE=$'\033[38;2;137;180;250m'     # 89b4fa
TEAL=$'\033[38;2;148;226;213m'     # 94e2d5
GREEN=$'\033[38;2;166;227;161m'    # a6e3a1
YELLOW=$'\033[38;2;249;226;175m'   # f9e2af
RED=$'\033[38;2;243;139;168m'      # f38ba8
PEACH=$'\033[38;2;250;179;135m'    # fab387
FLAMINGO=$'\033[38;2;242;205;205m' # f2cdcd
LAVENDER=$'\033[38;2;180;190;254m' # b4befe
OVERLAY=$'\033[38;2;108;112;134m'  # overlay0 6c7086
SUBTEXT=$'\033[38;2;166;173;200m'  # subtext0 a6adc8
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
if [[ "$CTX_SIZE" =~ ^[0-9]+$ ]] && ((CTX_SIZE >= 1000000)); then
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
  if [[ -f "$CF" ]] && ((NOW - $(stat -f %m "$CF") < 5)); then
    IFS=$'\t' read -r BRANCH STAGED MODIFIED <"$CF"
  elif GIT_OPTIONAL_LOCKS=0 git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(GIT_OPTIONAL_LOCKS=0 git -C "$DIR" branch --show-current 2>/dev/null)
    while IFS= read -r l; do
      [[ "${l:0:1}" != " " && "${l:0:1}" != "?" ]] && ((STAGED++))
      [[ "${l:1:1}" != " " && "${l:1:1}" != "?" ]] && ((MODIFIED++))
    done < <(GIT_OPTIONAL_LOCKS=0 git -C "$DIR" status --porcelain 2>/dev/null)
    printf '%s\t%s\t%s' "$BRANCH" "$STAGED" "$MODIFIED" >"$CF"
  fi
  if [[ -n "$BRANCH" ]]; then
    GIT="${SEP}${TEAL}󰘬 ${BRANCH}${RST}"
    ((STAGED > 0)) && GIT+=" ${GREEN}+${STAGED}${RST}"
    ((MODIFIED > 0)) && GIT+=" ${YELLOW} ${MODIFIED}${RST}"
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
  ((PCT < 0)) && PCT=0
  ((PCT > 100)) && PCT=100
fi

# Two-color dot-texture bar (Mocha), matching the reference style:
# lavender fill normally, red fill once usage crosses the danger threshold.
# Both filled and empty segments use the same "⣿" texture glyph — only the
# color (and a lighter bg on the filled side) differs, giving a clean 2-tone box.
WIDTH=20
FILLED=$(((PCT * WIDTH + 50) / 100))
((FILLED > WIDTH)) && FILLED=$WIDTH
EMPTY=$((WIDTH - FILLED))

if ((PCT >= 80)); then
  FILL_FG=$'\033[38;2;243;139;168m' # red f38ba8
  FILL_BG=$'\033[48;2;69;35;46m'    # muted red-tinted surface
else
  FILL_FG=$'\033[38;2;180;190;254m' # lavender b4befe
  FILL_BG=$'\033[48;2;40;42;66m'    # muted lavender-tinted surface
fi

BAR=""
if ((FILLED > 0)); then
  BAR+="${FILL_FG}${FILL_BG}"
  for ((i = 0; i < FILLED; i++)); do BAR+="⣿"; done
  BAR+="$RST"
fi
if ((EMPTY > 0)); then
  # overlay0 fg on surface0 bg — subtle empty-track contrast on the Mocha base
  BAR+=$'\033[38;2;108;112;134m\033[48;2;49;50;68m'
  for ((i = 0; i < EMPTY; i++)); do BAR+="⣿"; done
  BAR+="$RST"
fi

# 5h rate limit with reset countdown
RLIM=""
if [[ -n "$FIVE_PCT" && "$FIVE_PCT" != "null" ]]; then
  FI=$(printf '%.0f' "$FIVE_PCT")
  if ((FI >= 80)); then
    RC="$RED"
  elif ((FI >= 50)); then
    RC="$YELLOW"
  else
    RC="$LAVENDER"
  fi
  RLIM="${SEP}${RC}󰥔 5h: ${FI}%${RST}"
  if [[ -n "$FIVE_RESET" && "$FIVE_RESET" != "null" ]]; then
    REM=$((FIVE_RESET - NOW))
    ((REM > 0)) && RLIM+=" ${SUBTEXT}$((REM / 3600))h$(((REM % 3600) / 60))m${RST}"
  fi
fi

# 7d rate limit
if [[ -n "$SEVEN_PCT" && "$SEVEN_PCT" != "null" ]]; then
  SI=$(printf '%.0f' "$SEVEN_PCT")
  if ((SI >= 80)); then
    SC="$RED"
  elif ((SI >= 50)); then
    SC="$YELLOW"
  else
    SC="$SUBTEXT"
  fi
  RLIM+="${SEP}${SC}7d: ${SI}%${RST}"
  if [[ -n "$SEVEN_RESET" && "$SEVEN_RESET" != "null" ]]; then
    REM=$((SEVEN_RESET - NOW))
    if ((REM > 0)); then
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
  COST_SEG="${SEP}${PEACH}${COST_FMT}${RST}"
fi

# ═══ LINE 2: bar · 5h · 7d · cost ═════════════════════════════════
printf '%s\n' "${BAR} ${LAVENDER}${PCT}%${RST}${RLIM}${COST_SEG}"
