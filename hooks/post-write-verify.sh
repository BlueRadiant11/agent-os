#!/bin/bash
# PostToolUse hook (matcher: Write|MultiEdit): verifies that Write/MultiEdit
# results actually landed on disk.
#
# The Write tool can report `File created successfully` based on upstream API
# success while the file never lands — observed 2026-05-12 when macOS TCC
# silently blocked a write to ~/Desktop/hooks-audit.md after the operator denied a
# VS Code permission prompt. The tool layer does not `stat` post-write;
# this hook closes that gap.
#
# Behavior: read `tool_input.file_path` from stdin JSON; if the file does not
# exist on disk after the tool call, emit `hookSpecificOutput.additionalContext`
# warning of the silent failure. Silent on success.
#
# Why this exists: truth-above-all bright line. Silent success is the worst
# possible outcome; this hook prevents the model from declaring an artifact
# landed when it didn't.
#
# Registry: ~/.claude/architecture/hooks/registry.md.

set -euo pipefail

# Read JSON payload from stdin
payload=$(cat)

# Extract file_path. Fail-safe: any parse error → exit 0.
file_path=$(printf '%s' "$payload" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {}) or {}
    print(ti.get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

# If no file_path, exit silent
if [[ -z "$file_path" ]]; then
  exit 0
fi

# If the file exists on disk, the write landed — silent success
if [[ -e "$file_path" ]]; then
  exit 0
fi

# The tool returned but the file isn't there. Silent FS failure (likely TCC).
python3 -c "
import json
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': '⚠ Write tool reported success but file does not exist at ${file_path}. Likely a macOS TCC permission denial (Desktop/Documents/Downloads guarded paths) or other silent FS failure. Verify before declaring the artifact landed; consider re-writing to an unguarded path (e.g., ~/.claude/architecture/, ~/personal-context/, ~/Desktop/claude-workspace/).'
    }
}))
"

exit 0
