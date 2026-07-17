#!/bin/bash
# SessionStart hook (8-hook split): decision-log.md (life-level decisions).
# Size target: ~9KB.

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
[[ -d "$PORTFOLIO_DIR" ]] || exit 0

abs="$PORTFOLIO_DIR/decision-log.md"
[[ -f "$abs" ]] || exit 0

ctx="PERSONAL CONTEXT 2/8 — Life-level decision log (auto-injected every session).

═══ decision-log.md ═══

$(cat "$abs")
"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
