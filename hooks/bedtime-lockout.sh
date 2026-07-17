#!/bin/bash
# UserPromptSubmit hook: enforces the 8:30 PM bedtime lockout.
#
# Example of a deterministic-friction hook: if the operator's sleep protocol
# bans late-evening screen work, this hook enforces it at the harness layer
# instead of relying on discretion. Adjust the window or delete the hook if
# it doesn't fit your protocol.
#
# Window: 20:30 to 06:00 local time. Crosses midnight.
# Outside the window: silent exit.
# Inside the window: returns {"decision":"block"} to halt prompt processing.
#
# Override: edit this hook or remove its entry from ~/.claude/settings.json.
# The friction is the edit itself — deliberate, visible, leaves a git diff
# in the canonical layer if the operator wants to track override frequency later.
#
# Wired in ~/.claude/settings.json "hooks.UserPromptSubmit" block.
# Registry: ~/.claude/architecture/hooks/registry.md.

set -euo pipefail

hour=$(date +%H)
minute=$(date +%M)

# Force base-10 arithmetic (08, 09 would otherwise be parsed as octal)
now_min=$((10#$hour * 60 + 10#$minute))
start_min=$((20 * 60 + 30))  # 20:30 = 1230
end_min=$((6 * 60))          # 06:00 = 360

# Window crosses midnight: in-window if past 20:30 OR before 06:00
if (( now_min >= start_min )) || (( now_min < end_min )); then
  cat <<'JSON'
{"decision":"block","reason":"Bedtime lockout active (8:30 PM – 6:00 AM). The operator's sleep protocol bans late-evening screen work; this hook is its deterministic friction. To override, edit ~/.claude/settings.json or ~/.claude/hooks/bedtime-lockout.sh — but if you're doing that, you already know you're spending against the protocol."}
JSON
fi
