#!/bin/bash
# PostToolUse hook: when ~/.claude/settings.json gets edited, count hook
# entries in the post-edit `hooks` block and compare to the count of pipe-rows
# in the "Active hooks" table of ~/.claude/architecture/hooks/registry.md.
# If settings.json count exceeds registry count, emit a reminder to mirror
# the new hook in the registry per the rule at agents/arch-implementer.md:146.
# Wired in ~/.claude/settings.json "hooks" block. Silent on counts-equal and
# on non-matching paths.

set -euo pipefail

f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')

case "$f" in
  "$HOME/.claude/settings.json"|"/Users/yourname/.claude/settings.json")
    settings_count=$(jq '[.hooks[][] | .hooks[]] | length' "$HOME/.claude/settings.json" 2>/dev/null || echo 0)
    registry_count=$(grep -cE '^\| `?(PostToolUse|SessionStart|PreToolUse|Stop|UserPromptSubmit)' "$HOME/.claude/architecture/hooks/registry.md" 2>/dev/null || echo 0)
    if [ "$settings_count" -gt "$registry_count" ]; then
      cat <<'JSON'
{"systemMessage":"settings.json hooks block grew — mirror the new hook in ~/.claude/architecture/hooks/registry.md before continuing.","hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"REMINDER: settings.json `hooks` block has more entries than ~/.claude/architecture/hooks/registry.md `Active hooks` table. Per arch-implementer.md:146 — \"Update ~/.claude/architecture/hooks/registry.md with a new row for the hook (event, matcher, script path, purpose, build date). This is part of the same approved finding — the hook is not 'shipped' until the registry mirrors it. Do this in the same atomic flow, not as a follow-up.\""}}
JSON
    fi
    ;;
esac
