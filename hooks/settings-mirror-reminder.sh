#!/bin/bash
# PostToolUse hook: when ~/.claude/settings.json gets edited AND the change
# touches the permissions block, remind to mirror in ~/.claude/architecture/permissions/.
#
# Smarter than the prior version (2026-05-02 to 2026-05-19, fired on every
# settings.json edit). Now gates on whether the edit content contains
# permissions-block keywords. Hooks-block edits / env-var edits / model-pref
# edits no longer trip the reminder.
#
# Gating logic: read the tool_input payload, extract edit content (Edit's
# old_string+new_string, Write's content, MultiEdit's edits array). If the
# content matches `"(allow|deny|ask)":` or `"permissions":`, fire. Else skip.
#
# False-positive tolerance: a hooks-block edit that incidentally contains the
# literal string `"allow":` somewhere (e.g., a script path or comment) WOULD
# fire. Accepted as cost — alternative (parsing JSON structural diff) is
# brittle. Prefer occasional false-positive over silent false-negative when
# permissions drift compounds.

set -euo pipefail

payload=$(cat)

f=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null || echo "")

case "$f" in
  "$HOME/.claude/settings.json"|"/Users/yourname/.claude/settings.json")
    # Extract edit content from tool_input — handle Edit, Write, MultiEdit shapes.
    content=$(printf '%s' "$payload" | jq -r '[
      .tool_input.old_string,
      .tool_input.new_string,
      .tool_input.content,
      (.tool_input.edits[]? | (.old_string, .new_string))
    ] | map(select(. != null)) | join("\n")' 2>/dev/null || echo "")

    # Gate: only fire when the edit content references a permissions-block key.
    if printf '%s' "$content" | grep -qE '"(allow|deny|ask)":|"permissions":'; then
      cat <<'JSON'
{"systemMessage":"settings.json permissions block edited — mirror in ~/.claude/architecture/permissions/ before continuing.","hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"REMINDER: settings.json permissions block was just edited. Per the source-of-truth rule in ~/.claude/architecture/permissions/evolution-protocol.md, mirror the change in the matching ~/.claude/architecture/permissions/{allow,deny,ask}.md file before doing other work. Otherwise registry drift compounds across sessions."}}
JSON
    fi
    ;;
esac
