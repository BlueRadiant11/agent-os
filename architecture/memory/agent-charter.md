---
name: Memory Agent charter
description: What Memory Agent does on each run, its invocation path, and what's currently working vs. what's still on the build path. Phased operating loop locked 2026-05-12 with mandatory-row handoff format + PostToolUse enforcement hook.
type: charter
canonical: true
owner: memory-agent
last_verified: 2026-05-12
---

# Memory Agent — charter

The cleaning + management layer. Does not replace in-session captures (those happen live by CoS or whichever agent is active). Memory Agent synthesizes, sweeps, and maintains.

## Operating loop — 7 phases, mandatory output per phase

Every full-sweep run executes seven phases. Each phase ends with an explicit STATUS LINE in the handoff. Silent skip is a failure mode — the PostToolUse hook (`memory-agent-handoff-check.sh`) parses the response and surfaces missing phase rows to the parent agent.

0. **Compose skills.** Invoke `/dedupe-memory` first. Use its digest as the baseline for Phases 3 + 4. Skip only on narrow-scope dispatches; mark `SKIPPED — <reason>` explicitly when so.
1. **Navigate.** Read the spec at `/Users/yourname/.claude/architecture/memory/`, the auto-memory index, sample in-scope folders.
2. **Synthesize.** Harvest the dispatch window: sessions, claude-workspace, Life OS deltas, GitHub activity. Route unambiguous facts to canonical homes; surface ambiguous ones as findings.
3. **Reconcile.** Drift / staleness (per `cleaning-rules.md` TTLs) / schema-gap findings across the memory layer.
4. **Project-mirror drift.** Mandatory walk of `~/Desktop/project-alpha/CLAUDE.md` and `~/Desktop/life-os/CLAUDE.md` for the operator-level facts that disagree with portfolio canon. Project-specific operational facts are out of jurisdiction.
5. **Discoverability + pairwise consistency.** Orphan-file detection (each file under `~/personal-context/{goals,projects,identity,domain-knowledge}/` needs ≥1 inbound from SessionStart loader, `context-router-map.json`, or stable cross-reference in CLAUDE.md / identity.md / decision-log). Pairwise-consistency check on named entities appearing in 3+ canonical files.
6. **Index + handoff.** Update `MEMORY.md` for in-scope writes / deletes. Render the enriched-finding handoff (paths + detail + recommended action + verify-by per finding).

Full phase detail in `/Users/yourname/.claude/agents/memory-agent.md` § "Operating loop." Charter and body must agree — change one, change both.

## Finding format

Findings must include all four sub-fields. Arch-implementer consumes findings directly; missing sub-fields force a re-dispatch.

```
M-NNN — <one-line summary> [severity: high | medium | low]
  paths: <absolute paths, comma-separated>
  detail: <one or two sentences of evidence>
  recommended action: <specific, executable instruction>
  verify by: <command or grep pattern that confirms the fix>
```

## Invocation path

**Autonomous.** Per `~/.claude/architecture/agents/invocation-paths.md` (renamed 2026-05-03 from the prior trust-tier model) — full permissions in scope; routine work runs autonomously. Bright-line constraints (deletions, canonical conflicts, CLAUDE.md edits, decision-log rewrites) surface as FINDINGS at the contract level, not via path-level carve-outs.

## Today vs. target

**Working today:**
- Single writer (CoS, in-session)
- Manual capture into the right files
- Schema applied to new files only
- Memory Agent runs Operator-directed only as of 2026-05-04 (daily 06:00 cron disabled — see `decisions/agent-os/2026-05-04-cron-runaway-disabled.md`); manual dispatch or composition by other agents drops reports to `~/.claude/inbox/`

**Build path remaining:**
- Automated drift reconciliation (currently surfaces in report; doesn't auto-apply yet beyond mirror updates)
- Multi-writer conflict handling
- Index auto-regeneration

**Build sequencing:** spec done across `memory/*.md`. Capture habits codified in `~/.claude/CLAUDE.md`. Per-domain decision files + `how-i-work.md` exist. Memory Agent body at `~/.claude/agents/memory-agent.md`. Cron runner at `~/.claude/scripts/memory-agent-daily.sh`. Further build per the decisions in `decisions/agent-os/`.
