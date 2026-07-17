#!/bin/bash
# SessionStart hook (8-hook split): shelf.md (paused items index).
# Size target: ~6KB.

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
abs="$PORTFOLIO_DIR/shelf.md"
[[ -f "$abs" ]] || exit 0

ctx="PERSONAL CONTEXT 7/8 — Shelf (paused items index, auto-injected every session).

═══ shelf.md ═══

$(cat "$abs")
"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
