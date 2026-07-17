#!/bin/bash
# SessionStart hook (8-hook split): schedule-and-habits + spending-and-preferences + external-writing.
# Size target: ~5.5KB.

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
[[ -d "$PORTFOLIO_DIR" ]] || exit 0

files=(
  "work-style/schedule-and-habits.md"
  "work-style/spending-and-preferences.md"
  "work-style/external-writing.md"
)

block=""
for rel in "${files[@]}"; do
  abs="$PORTFOLIO_DIR/$rel"
  if [[ -f "$abs" ]]; then
    block="${block}═══ ${rel} ═══"$'\n\n'
    block="${block}$(cat "$abs")"$'\n\n'
  fi
done

ctx="PERSONAL CONTEXT 6/8 — Life canon (schedule + habits, spending, external writing).

${block}"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
