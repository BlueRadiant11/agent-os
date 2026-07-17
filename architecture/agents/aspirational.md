---
name: Aspirational sub-agents
description: Planned but not built. Capabilities, boundaries, build readiness. Killed agents removed per the no-tombstone rule.
type: roster
canonical: true
owner: chief-of-staff
last_verified: 2026-05-07
---

# Aspirational sub-agents (planned, not built)

<!-- coach-agent — GRADUATED FROM ASPIRATIONAL 2026-05-07. Built as a maintenance-mode exception per decisions/agent-os/2026-05-07-coach-agent-exception.md. Now lives in agents/built.md. Per the no-tombstone rule, the aspirational entry is removed; receipts live in the decision-log. -->

## self-improvement-agent

- **Status:** aspirational
- **Capability:** researches and proposes Agent OS upgrades nightly. Implements low-risk routine cleanup autonomously; surfaces novel changes for approval.
- **Boundary:** focuses on the *Agent OS itself* (this folder, CLAUDE.md, skill / agent inventory, plugin updates, settings.json hygiene). Distinct from Memory Agent (memory layer) and Defrag Agent (architecture audit).
- **Trigger:** nightly cron (when built); manual "find improvements"
- **Invocation (planned):** Autonomous for low-risk routine; Operator-directed for novel changes
- **Build readiness:** needs spec — what counts as "low-risk routine" vs. "novel"

## project-agents (project-alpha, life-os, etc.)

- **Status:** aspirational
- **Capability:** per-project agent that holds project-specific context, decisions, and operating norms. the operator dispatches Project Alpha questions to project-alpha-agent; Life OS questions to life-os-agent; etc.
- **Boundary:** project-specific. Memory Agent stays cross-project; project agents go deep on one repo / domain.
- **Trigger:** the operator asks something project-specific while not currently in that repo
- **Invocation (planned):** Operator-directed
- **Build readiness:** project CLAUDE.mds already exist; per-project agents would compose those plus relevant portfolio sections

## communication-agent

- **Status:** aspirational (was SHELVED 2026-05-01 → pulled off shelf 2026-05-02; reverts to plain aspirational). Heaviest-constraint build of the planned roster.
- **Capability:** drafts internal and external messages. **the operator approves every send.**
- **Boundary:** drafts only. Sending is the operator-only per bright lines. The agent can't be autonomous for sends — ever; the bright line is contract-level, not tier-level.
- **Trigger:** the operator asks for a draft
- **Invocation (planned):** Operator-directed for drafts. Sends are bright-line gated regardless of invocation path — push/send/spend approval still applies.
- **Build readiness:** non-trivial — approval-loop UX needs design before this ships
