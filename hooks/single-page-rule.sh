#!/bin/bash
# PostToolUse hook: enforces the single-page rule on ~/personal-context/.
# When a file in that tree is edited and exceeds 100 lines, emit a
# systemMessage + additionalContext warning. Silent on every other path.
#
# Rule canonically defined in ~/.claude/architecture/memory/schema.md
# § "Single-page rule" (hard cap: 100 lines, single-topic, zero exceptions).
# Wired in ~/.claude/settings.json "hooks" block.

set -euo pipefail

f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')

case "$f" in
  "$HOME/personal-context/"*.md|"/Users/yourname/personal-context/"*.md)
    ;;
  *)
    exit 0
    ;;
esac

[[ -f "$f" ]] || exit 0

lines=$(wc -l < "$f" | tr -d ' ')

if [[ "$lines" -gt 100 ]]; then
  rel="${f#$HOME/}"
  cat <<JSON
{"systemMessage":"~/$rel is $lines lines — over the 100-line single-page-rule cap. Split or trim before continuing.","hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"VIOLATION: ~/$rel is $lines lines, exceeding the hard 100-line cap encoded in ~/.claude/architecture/memory/schema.md. The single-page rule keeps every personal-context file in zero-degradation territory for agent reading. Split into single-topic sub-files following the agent-native filing scheme — one focused topic per file, ≤100 lines."}}
JSON
fi
