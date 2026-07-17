#!/bin/bash
# PostToolUse hook (matcher: Edit|Write|MultiEdit): tracks edits to canonical files per session.
#
# Reads the post-edit file's frontmatter; if it contains `canonical: true`,
# increments a per-session counter at ~/.claude/state/canonical-edit-counter-<session_id>.json.
# At threshold 3, emits additionalContext reminding the model to dispatch defrag-agent
# before session end.
#
# Why this exists: Pass B Signal 9 (~/.claude/agents/defrag-agent.md:145) declares that
# a session editing ≥3 canonical files without subsequently dispatching defrag-agent is
# load-bearing drift risk. Prose-in-body rules don't reliably enforce; this hook is the
# mechanical safety net.
#
# Registry: ~/.claude/architecture/hooks/registry.md
# Build-rules basis: ~/.claude/architecture/hooks/build-rules.md § Signal 9.

set -euo pipefail

# Read JSON payload from stdin
payload=$(cat)

# Extract session_id and file_path. Fail-safe: any parse error → exit 0.
session_id=$(printf '%s' "$payload" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('session_id', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

file_path=$(printf '%s' "$payload" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {}) or {}
    # Write/Edit/MultiEdit all expose file_path
    print(ti.get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

# If we can't identify session or file, exit silent
if [[ -z "$session_id" || -z "$file_path" ]]; then
  exit 0
fi

# Only consider files that actually exist post-edit
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Check frontmatter (first 20 lines) for `canonical: true`
if ! head -20 "$file_path" 2>/dev/null | grep -qE '^canonical:[[:space:]]*true[[:space:]]*$'; then
  exit 0
fi

# It's a canonical file. Increment counter.
state_dir="$HOME/.claude/state"
counter_file="$state_dir/canonical-edit-counter-${session_id}.json"
mkdir -p "$state_dir"

# Read current count (default 0), increment, write back, capture new value
new_count=$(python3 -c "
import json, os, sys
path = '${counter_file}'
sid = '${session_id}'
try:
    if os.path.exists(path):
        with open(path) as f:
            d = json.load(f)
    else:
        d = {}
    cur = int(d.get(sid, 0))
    cur += 1
    d[sid] = cur
    with open(path, 'w') as f:
        json.dump(d, f)
    print(cur)
except Exception:
    print(0)
" 2>/dev/null || echo "0")

# Threshold semantics: emit exactly once when crossing 3. Suppress thereafter.
if [[ "$new_count" == "3" ]]; then
  python3 -c "
import json
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': 'Three or more canonical files have been edited this session. Per Pass B Signal 9 (~/.claude/agents/defrag-agent.md:145), dispatch defrag-agent before session end to catch dependency-graph staleness and cross-reference drift before they ship.'
    }
}))
"
fi

exit 0
