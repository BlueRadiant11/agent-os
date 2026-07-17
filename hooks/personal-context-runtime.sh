#!/bin/bash
# SessionStart hook 8/8: runtime state (inbox, permissions counts, recent
# decision activity, on-demand pointers, conditional Agent OS extras).
# Refreshed each session start; not canon — operational snapshot.
# Size target: ~3KB.
# 2026-06-10: archindex + portfolio hooks demoted to the pointer lines below
# (they overflowed the inline budget every session — see hooks/registry.md).

set -euo pipefail

PORTFOLIO_DIR="$HOME/personal-context"
ARCH_DIR="$HOME/.claude/architecture"
INBOX_DIR="$HOME/.claude/inbox"
SETTINGS="$HOME/.claude/settings.json"

[[ -d "$PORTFOLIO_DIR" ]] || exit 0

# Helper: extract description from frontmatter, fallback to first H1
get_desc() {
  local f="$1"
  local desc
  desc=$(awk 'BEGIN{seen=0} /^---[[:space:]]*$/{seen+=1; next} seen==1 && /^description:/{sub(/^description:[[:space:]]*/,""); gsub(/^"|"$/,""); print; exit}' "$f" 2>/dev/null || true)
  if [[ -z "$desc" ]]; then
    desc=$(grep -m1 '^# ' "$f" 2>/dev/null | sed 's/^# //' || true)
  fi
  [[ -z "$desc" ]] && desc="(no description)"
  echo "$desc"
}

# Inbox enumeration (excludes README.md)
inbox_block=""
if [[ -d "$INBOX_DIR" ]]; then
  inbox_files=$(find "$INBOX_DIR" -maxdepth 1 -type f -name "*.md" ! -name "README.md" 2>/dev/null | sort)
  if [[ -n "$inbox_files" ]]; then
    inbox_block="Pending inbox files (read at /morning):"$'\n'
    while IFS= read -r f; do
      bn=$(basename "$f")
      bytes=$(wc -c < "$f" | tr -d ' ')
      inbox_block="${inbox_block}- ${bn} (${bytes} bytes)"$'\n'
    done <<< "$inbox_files"
  else
    inbox_block="Inbox empty (no pending agent reports)."$'\n'
  fi
fi

# Permissions digest
perms_block=""
if [[ -f "$SETTINGS" ]]; then
  allow_count=$(jq '.permissions.allow | length' "$SETTINGS" 2>/dev/null || echo "?")
  ask_count=$(jq '.permissions.ask | length' "$SETTINGS" 2>/dev/null || echo "?")
  deny_count=$(jq '.permissions.deny | length' "$SETTINGS" 2>/dev/null || echo "?")
  perms_block="Global permissions: ${allow_count} allow / ${ask_count} ask / ${deny_count} deny entries. Full detail in ~/.claude/architecture/permissions/{allow,ask,deny}.md."$'\n'
fi

# 5 most recent decision files by mtime
decisions_block="Recent decision activity (5 most recently modified decision files):"$'\n'
decision_paths=()
[[ -f "$PORTFOLIO_DIR/decision-log.md" ]] && decision_paths+=("$PORTFOLIO_DIR/decision-log.md")
if [[ -d "$PORTFOLIO_DIR/decisions" ]]; then
  while IFS= read -r f; do
    decision_paths+=("$f")
  done < <(find "$PORTFOLIO_DIR/decisions" -type f -name "*.md" 2>/dev/null)
fi

if [[ ${#decision_paths[@]} -gt 0 ]]; then
  while IFS= read -r line; do
    f="${line#* }"
    rel="${f#$PORTFOLIO_DIR/}"
    desc=$(get_desc "$f")
    decisions_block="${decisions_block}- ${rel}: ${desc}"$'\n'
  done < <(stat -f '%m %N' "${decision_paths[@]}" 2>/dev/null | sort -rn | head -5)
fi

# Agent OS extras (when cwd is exactly ~/Desktop)
agent_os_extras=""
cwd="${CLAUDE_PROJECT_DIR:-${PWD:-}}"
if [[ "$cwd" == "$HOME/Desktop" ]]; then
  if [[ -f "$ARCH_DIR/agents/aspirational.md" ]]; then
    agent_os_extras="${agent_os_extras}═══ Agent OS session detected (cwd=~/Desktop) — loading roster extras ═══"$'\n\n'
    agent_os_extras="${agent_os_extras}═══ ~/.claude/architecture/agents/aspirational.md ═══"$'\n\n'
    agent_os_extras="${agent_os_extras}$(cat "$ARCH_DIR/agents/aspirational.md")"$'\n\n'
  fi
fi

pointers_block="On-demand maps (NOT auto-injected — read when relevant per CLAUDE.md 'Proactive context'):
- Architecture map + dependency graph: ~/.claude/architecture/index.md (read FIRST on any architecture question or specialist dispatch)
- Portfolio map: ~/personal-context/README.md + subdirectories (projects/, identity/, goals/, decisions/, domain-knowledge/)
- The context-router hook also keyword-injects matched files on prompt submit."

ctx="PERSONAL CONTEXT 8/8 — Runtime state (refreshed each session).

${inbox_block}
${perms_block}
${decisions_block}
${pointers_block}

${agent_os_extras}"

jq -n --arg ctx "$ctx" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
