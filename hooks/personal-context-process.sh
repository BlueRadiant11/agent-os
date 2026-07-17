#!/bin/bash
# SessionStart hook (8-hook split): format-and-reports + coding-workflow + agent-governance.
# Size target: ~7.5KB.

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
[[ -d "$PORTFOLIO_DIR" ]] || exit 0

files=(
  "work-style/format-and-reports.md"
  "work-style/coding-workflow.md"
  "work-style/agent-governance.md"
)

block=""
for rel in "${files[@]}"; do
  abs="$PORTFOLIO_DIR/$rel"
  if [[ -f "$abs" ]]; then
    block="${block}═══ ${rel} ═══"$'\n\n'
    block="${block}$(cat "$abs")"$'\n\n'
  fi
done

ctx="PERSONAL CONTEXT 5/8 — Process canon (format, coding workflow, agent governance).

${block}"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
