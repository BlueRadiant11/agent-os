---
name: Built sub-agents
description: Capabilities, paths, scope, invocation path, and triggers for every shipped agent in the roster.
type: roster
canonical: true
owner: chief-of-staff
last_verified: 2026-05-19
---

# Built sub-agents

**Bridge protocol (universal, lightweight sentinel-only after 2026-05-19 teardown):** All five built agents inherit the universal Bridge protocol — items 0 + 3 only — per `~/.claude/architecture/agents/bridge-protocol.md`. Items 1, 2, 6, 7, 8 (pad I/O) were removed 2026-05-19 with the pad-layer teardown; items 4, 5 (mid-build question surfacing + SendMessage resume) were removed 2026-05-17 by the interview-first pivot. Every dispatch carries `BRIDGE_PAD_PATH: inline` (or any value) as prompt line 1 — that's the entire convention. Foreground responses return via the Agent tool wrapper; background responses surface via Claude Code's native completion notification. Raw `Agent` dispatches are blocked at the tool layer by `pre-tool-use-bridge-only.sh` PreToolUse hook (built 2026-05-19); Item 0's defensive sentinel-detection remains as a handler for incoming Agent invocations that somehow lack the sentinel (e.g., hook misfire, foreign caller), explicitly NOT permission for CoS to dispatch raw. Sub-agents resolve design questions via Item 3's fallback hierarchy (`~/personal-context/` → inference → agent's own judgment as FINDING). New agents built via `agent-skill-creator` inherit the lightweight contract by default.

## memory-agent

- **Path:** `~/.claude/agents/memory-agent.md`
- **Built:** 2026-05-01
- **Persona:** meticulous, organized, librarian-meets-systems-architect.
- **Capability:** master navigator + operational steward of the memory + context layer. Daily synthesis from sessions / claude-workspace / Life OS deltas / GitHub. Drift reconciliation across mirrored facts (incl. project CLAUDE.mds). Staleness sweeping (TTL-aware). Index maintenance (`MEMORY.md`, future per-folder indexes). Conflict surfacing (when two facts disagree, propose resolution; never pick silently).
- **Composes:** `/jot`, `/route-memory`, `/dedupe-memory`
- **Source of truth:** `~/.claude/architecture/memory/` — re-reads before non-trivial action
- **Scope (writes):** `~/personal-context/`, `~/.claude/projects/-Users-yourname-Desktop/memory/`, `~/Desktop/<project>/CLAUDE.md` (mirror updates only)
- **Out of scope:** `~/Desktop/claude-workspace/` writes (owned by `/ce:*` skills); Supabase writes (the operator approval); CLAUDE.md and project source code edits
- **Invocation:** **Operator-directed** as of 2026-05-04 (cron disabled — see `decisions/agent-os/2026-05-04-cron-runaway-disabled.md`). Composable by other agents in autonomous chains. Full permissions when running. Carve-outs that gate to the operator regardless of invocation: deletions, canonical conflicts, CLAUDE.md edits, edits to existing decision-log entries. See `agents/invocation-paths.md`.
- **Triggers:** synchronous via Agent tool; manual on-demand dispatch via `bash ~/.claude/scripts/memory-agent-daily.sh` (the runner script is intact for manual invocation, just no longer cron-fired). Drops to `~/.claude/inbox/memory-agent-<timestamp>.md`.

## agent-skill-creator

- **Path:** `~/.claude/agents/agent-skill-creator.md`
- **Built:** 2026-05-01
- **Persona:** terse, structured, operational.
- **Capability:** builds new skills and sub-agents on Chief-of-Staff handoff. Skill build path: `/ce:brainstorm` → `/ce:plan` → `/ce:work` → write `~/.claude/skills/<name>/SKILL.md` → optional `/ce:compound`. Agent build path: same loop plus `agent-native-architecture` for design + optional `agent-native-reviewer` for verification.
- **Composes (skills):** `/ce:brainstorm`, `/ce:plan`, `/ce:work`, `agent-native-architecture`, `/ce:compound`
- **Composes (agents):** `agent-native-reviewer`
- **Conventions cold:** SKILL.md / agent.md frontmatter; voice rules from `work-style/voice-canon.md`; memory-layer rules from `memory/`; bright lines (no commits / push / send / spend / external writes)
- **Invocation:** Operator-directed — every build artifact requires CoS or the operator approval

## arch-implementer

- **Path:** `~/.claude/agents/arch-implementer.md`
- **Built:** 2026-05-01
- **Persona:** hygienist with surgical tools — counterpart to defrag-agent's auditor.
- **Capability:** the **fix-half** of the audit-fix loop. Takes defrag-agent's report (with finding IDs like `RG-01`, `BP-02`) plus the operator's approval list, parses each approved finding, executes the `recommended action`, runs `verify by:`, reports back what landed.
- **The two-agent loop:** defrag-agent (audit) → produces report with stable IDs → the operator approves specific IDs → CoS dispatches arch-implementer with approved-ID list + the defrag report → arch-implementer applies, verifies, reports.
- **Boundary:** architecture lane only (same as defrag). Refuses content edits.
- **Composes:** nothing. Direct Read/Edit/Write/Bash.
- **Invocation:** Operator-directed as of 2026-05-04 (the chained-after-defrag-cron path went dead when both crons were disabled). the operator runs defrag manually, triages findings, and dispatches arch-implementer with an approved-ID list. Full permissions in the architecture scope when running. Up-to-10-findings cap retained. Ambiguous findings still skip via the per-finding execution branch.

## defrag-agent

- **Path:** `~/.claude/agents/defrag-agent.md`
- **Built:** 2026-05-01
- **Persona:** systems hygienist. Visually distinct from Memory Agent (cyan vs. yellow); structurally distinct (no Edit/Write — proposes only).
- **Capability:** periodic audit of the Agent OS architecture itself. Surfaces duplicated agents, inconsistent patterns, drifted docs, settings.json drift, hook configuration issues, registry inconsistencies. Pass A: existing-hook drift. Pass B: enforcement-gap detection (rules without hooks). Proposes fixes; doesn't auto-fix.
- **Boundary:** **architecture, not content. Locked.** Memory Agent owns memory layer content. Defrag Agent owns the meta-layer.
- **Composes:** nothing — walks files directly with Read / Grep / Glob / read-only Bash.
- **Cadence:** Operator-directed only as of 2026-05-04. Trigger phrases: "audit the system" / "defrag the system" / `/morning` triage. Weekly cron disabled — see `decisions/agent-os/2026-05-04-cron-runaway-disabled.md`.
- **Invocation:** Operator-directed. Tools restricted to Read / Grep / Glob / Bash structurally enforce propose-only — architecture changes still need the operator approval at the finding-ID level (arch-implementer applies after the operator triages findings).

## coach-agent

- **Path:** `~/.claude/agents/coach-agent.md`
- **Built:** 2026-05-07
- **Persona:** weekly buttress — DeMello laid-back-funny + Robbins energetic-positive blend. Two voice registers: encouragement (anchored to data wins) and sober honesty (anchored to data misses, no fear/anger/shame).
- **Capability:** weekly Sunday-evening interpretive coaching. Reads past 7 days of Life OS data (habits, goals, mood, sleep_data, people, tasks) plus identity portfolio (`identity.md`, `goals/`, `decision-log.md`). Returns digest in WINS / EDGES / REFLECTION shape: 1-3 wins, 1-3 edges, 1 reflection prompt. Distinct from `/morning`'s daily WHERE YOU'RE SLIPPING bite — Coach buttresses, `/morning` slaps.
- **Boundary:** drafts only. No Supabase writes, no canon-file edits, no git commits, no external sends. Composes `/jot` only when the operator explicitly states `capture: ...` in conversation.
- **Composes:** `/jot` (gated by `capture:` prefix; `/jot`'s own propose-before-write contract handles approval).
- **Source of truth:** `~/.claude/agents/coach-agent.md`.
- **Scope (reads):** Life OS Supabase project `YOUR_SUPABASE_PROJECT_ID`, `~/personal-context/identity.md`, `~/personal-context/identity/`, `~/personal-context/goals/`, `~/personal-context/decision-log.md`, recent `~/personal-context/decisions/`, `~/personal-context/work-style/` (canon baked at persona-build time; `how-i-work.md` permitted at runtime).
- **Scope (writes):** none directly; drafts `/jot` content for the operator approval.
- **Invocation:** **Operator-directed.** Trigger phrases: `/coach`, "coach me", "coach session", "weekly review". v1 = no autonomous trigger; cron-disabled posture per `decisions/agent-os/2026-05-04-cron-runaway-disabled.md`.
- **Triggers:** the operator types `/coach` (typically Sunday evening as part of week-close ritual). Optional focus argument lets the operator override the active-growth-edges priority for one session.
- **Origin:** brainstorm `~/Desktop/claude-workspace/brainstorms/2026-05-07-coach-agent-requirements.md`; plan `~/Desktop/claude-workspace/plans/2026-05-07-001-feat-coach-agent-plan.md`; maintenance-mode exception receipt `~/personal-context/decisions/agent-os/2026-05-07-coach-agent-exception.md`.
- **Kill criterion:** if at week 8 the operator can't name 2+ specific behaviors that changed because of Coach observations specifically, retire or rebuild. Soft criterion: 3+ skipped Sundays in any 6-week window means the ritual isn't holding.
