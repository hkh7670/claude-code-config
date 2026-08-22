#!/usr/bin/env bash

# Claude Code Stop hook.
# tmux에서는 현재 session에 연결된 client TTY에 OSC 알림을 직접 출력한다.
# SSH client의 PTY라면 SSH를 통해 로컬 터미널(Ghostty 등)까지 전달된다.

set -uo pipefail

raw=$(cat)

summary=$(printf '%s' "$raw" | python3 -c '
import json
import re
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    data = {}

message = data.get("last_assistant_message") or ""
line = next(
    (line.strip() for line in message.splitlines() if line.strip()),
    "Done",
)

# OSC escape sequence injection 방지
line = re.sub(r"[\x00-\x1f\x7f]", " ", line)

print(line[:100])
' 2>/dev/null)

[ -z "$summary" ] && summary="Done"

target=""

if [ -n "${TMUX:-}" ] && command -v tmux >/dev/null 2>&1; then
  # Claude가 실행 중인 tmux session
  session=$(tmux display-message -p '#S' 2>/dev/null || true)

  if [ -n "$session" ]; then
    # 해당 session에 붙어 있는 client 중 가장 최근에 활동한 client 선택
    target=$(
      tmux list-clients -t "$session" \
        -F '#{client_activity} #{client_tty}' 2>/dev/null |
        sort -rn |
        head -1 |
        cut -d' ' -f2-
    )
  fi
else
  target=$(tty 2>/dev/null || true)
fi

if [ -n "$target" ] && [ -w "$target" ]; then
  printf '\033]9;Claude Code: %s\007' "$summary" >"$target"
fi

exit 0
