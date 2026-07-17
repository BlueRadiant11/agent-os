#!/bin/bash
# PostToolUse hook (matcher: Agent): validates memory-agent handoff completeness.
#
# Fires after every Agent tool call. Filters by subagent_type=="memory-agent".
# If the agent's response is missing any of the seven mandatory PHASE rows
# (PHASE 0: through PHASE 6:), emits a system reminder so the parent agent
# (Chief of Staff) sees the gap and can re-dispatch or audit.
#
# Why this exists: prose-in-body instructions don't reliably enforce.
# This hook is the safety net for the phased operating loop locked in
# ~/.claude/agents/memory-agent.md and ~/.claude/architecture/memory/agent-charter.md
# on 2026-05-12.
#
# Decision: ~/personal-context/decisions/agent-os/2026-05-12-memory-agent-phased-loop.md
# Registry: ~/.claude/architecture/hooks/registry.md.

set -euo pipefail

# Read JSON payload from stdin (Claude Code hook spec)
payload=$(cat)

# Extract subagent_type. Only act on memory-agent.
agent_type=$(printf '%s' "$payload" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('subagent_type', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

if [[ "$agent_type" != "memory-agent" ]]; then
  exit 0
fi

# Extract response text. tool_response can be a string or a list of content blocks.
response=$(printf '%s' "$payload" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    r = d.get('tool_response', '')
    if isinstance(r, str):
        print(r)
    elif isinstance(r, list):
        # List of content blocks: concat all text fields
        for block in r:
            if isinstance(block, dict) and 'text' in block:
                print(block['text'])
    elif isinstance(r, dict):
        # Single dict: try common shapes
        if 'content' in r and isinstance(r['content'], list):
            for block in r['content']:
                if isinstance(block, dict) and 'text' in block:
                    print(block['text'])
        elif 'text' in r:
            print(r['text'])
except Exception:
    pass
" 2>/dev/null || echo "")

# If we couldn't extract any response text, exit silently — don't false-positive on parse failure.
if [[ -z "$response" ]]; then
  exit 0
fi

# Trivial-run carve-out: if the response doesn't even mention any phase markers,
# it's likely a one-line "where does X go" answer or a trivial run. Don't enforce.
if ! printf '%s' "$response" | grep -qE 'PHASE [0-6]:'; then
  exit 0
fi

# Validate all 7 phase rows are present
missing=()
for n in 0 1 2 3 4 5 6; do
  if ! printf '%s' "$response" | grep -qE "^[[:space:]]*PHASE ${n}:"; then
    missing+=("PHASE $n")
  fi
done

if (( ${#missing[@]} > 0 )); then
  missing_list="${missing[*]}"
  # Emit additionalContext so the parent agent's next turn sees the gap.
  python3 -c "
import json, sys
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': '⚠ memory-agent handoff is missing required phase rows: ${missing_list}. The agent body (~/.claude/agents/memory-agent.md) defines a 7-phase operating loop (Phase 0 — Compose skills, 1 — Navigate, 2 — Synthesize, 3 — Reconcile, 4 — Project-mirror drift, 5 — Discoverability + pairwise consistency, 6 — Index + handoff). The handoff template requires one explicit row per phase, with SKIPPED — <reason> as a legal value. Missing rows indicate the agent did not follow the loop or did not render the handoff. Audit what got skipped or re-dispatch.'
    }
}))
"
fi

exit 0
