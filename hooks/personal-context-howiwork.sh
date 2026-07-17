#!/bin/bash
# SessionStart hook (8-hook split): how-i-work.md (validated working-style insights).
# Size target: ~7.5KB.

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
[[ -d "$PORTFOLIO_DIR" ]] || exit 0

abs="$PORTFOLIO_DIR/how-i-work.md"
[[ -f "$abs" ]] || exit 0

ctx="PERSONAL CONTEXT 3/8 — How the operator works best (auto-injected every session).

═══ how-i-work.md ═══

$(cat "$abs")
"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
