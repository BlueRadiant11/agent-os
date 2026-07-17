#!/bin/bash
# SessionStart hook (8-hook split): identity.md only.
# Size target: ~5.5KB. Part of the 9-hook split (2026-05-03) that broke the
# overflow into smaller chunks each below the harness inline-budget ceiling.

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
[[ -d "$PORTFOLIO_DIR" ]] || exit 0

abs="$PORTFOLIO_DIR/identity.md"
[[ -f "$abs" ]] || exit 0

ctx="PERSONAL CONTEXT 1/8 — Identity (auto-injected every session).

═══ identity.md ═══

$(cat "$abs")
"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
