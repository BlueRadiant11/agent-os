#!/bin/bash
# SessionStart hook (8-hook split): voice canon + hard rules.
# Size target: ~8.5KB.

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
[[ -d "$PORTFOLIO_DIR" ]] || exit 0

files=(
  "work-style/voice-canon.md"
  "work-style/hard-rules.md"
)

block=""
for rel in "${files[@]}"; do
  abs="$PORTFOLIO_DIR/$rel"
  if [[ -f "$abs" ]]; then
    block="${block}═══ ${rel} ═══"$'\n\n'
    block="${block}$(cat "$abs")"$'\n\n'
  fi
done

ctx="PERSONAL CONTEXT 4/8 — Voice canon + hard rules (auto-injected every session).

${block}"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
