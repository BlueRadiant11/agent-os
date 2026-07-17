---
name: Agent invocation paths
description: Two-path invocation model. Both paths grant full permissions in scope; the path label captures who started the agent, not what it can do. Bright lines from CLAUDE.md (push/send/spend/personal hard rules/customer "yours forever" zones/destructive shortcuts) apply regardless of path.
type: registry
canonical: true
owner: chief-of-staff
last_verified: 2026-06-10
---

# Agent invocation paths

Replaces the prior `trust-tiers.md` (2026-05-03). The previous "Tier 1 / Tier 2" labels did no real gating work — both granted full permissions, and bright lines applied regardless. Renaming to "invocation paths" matches reality: the label captures *how the agent was started*, not *what it can do*.

## Two paths

- **Operator-directed.** the operator tells the agent to run (natural language, slash command, or explicit dispatch). The agent runs with **full permissions** in its operating scope. the operator knows it's running because he started it.
- **Autonomous.** A skill, another agent, a cron, or a hook invokes the agent. The agent runs with **full permissions** in its operating scope. the operator may not know it's running until the report lands or the artifact appears.

Both paths grant the same authority. **The path label captures the invocation route, not the permission scope.**

## Per-agent paths

| Agent / Skill | Invocation | Notes |
| --- | --- | --- |
| Chief of Staff | (operator) | The active session the operator talks to |
| memory-agent | **Operator-directed + weekly native cron** | Weekly CronCreate job (Sun ~18:11) revived 2026-06-10 on the native scheduler (`runners/active.md`); the launchd daily cron was disabled 2026-05-04 (catchup-hook runaway, `decisions/agent-os/2026-05-04-cron-runaway-disabled.md`) and the lane retired 2026-06-10. Also Operator-directed via natural-language dispatch or `/route-memory` / `/dedupe-memory`; composable by other agents in autonomous chains. Full permissions when running: edit, delete, reconcile, archive, dedupe, route. |
| defrag-agent | **Operator-directed + weekly native cron** | Weekly CronCreate job (Wed ~18:14) revived 2026-06-10 (`runners/active.md`); launchd cron was disabled 2026-05-04 (same incident), lane retired 2026-06-10. Also Operator-directed via natural-language ("audit the architecture", "defrag the system") or explicit dispatch. Tools structurally restricted to Read / Grep / Glob / Bash by the audit-fix-loop design (separate constraint from invocation — see below). Full permissions for the read scope it has. |
| arch-implementer | **Operator-directed** | Was Autonomous-via-defrag-cron-chain (2026-05-02 → 2026-05-04). When the defrag cron was disabled the chain went with it; arch-implementer is now Operator-directed with an approved-ID list (manual `/morning` triage gates the apply step). Full permissions in the architecture scope. Ambiguous findings still skip via the per-finding execution branch — each finding parsed and applied independently. Up-to-10 findings per run cap retained. |
| agent-skill-creator | **Operator-directed** | the operator directs when a build is approved. Full permissions during the build. |
| `jot` skill | Operator-directed | the operator-typed verb. Proposes before write — the operator's own confirm is the explicit step in the skill, not a path constraint. |
| `route-memory` skill | Operator-directed | the operator-typed verb (or memory-agent composes it → Autonomous in that path). Digest-before-write same shape. |
| `dedupe-memory` skill | Operator-directed | the operator-typed verb. Reports findings; the operator approves which to apply. |
| coach-agent | **Operator-directed** | Weekly Sunday-evening ritual via `/coach`. Reads Life OS + identity portfolio for past 7 days. Composes `/jot` via explicit `capture:` gate. Autonomous graduation gated on lock-on-entry cron infrastructure (currently disabled per `decisions/agent-os/2026-05-04-cron-runaway-disabled.md`). |
| self-improvement-agent (planned) | Autonomous | Will fire on cron. |
| project-agents (planned) | Operator-directed | Operator-directed when context-switching to a project. |
| communication-agent (planned) | Operator-directed | Operator-directed for drafts. **Sends still cross the bright line — push/send/spend approval applies.** |

## Bright lines apply regardless of invocation path

Path grants permissions for routine work. The bright lines from `~/.claude/CLAUDE.md` § "Bright lines" are non-negotiable for every agent on every path:

- Truth above all — never claim something works when it doesn't.
- Push, send, spend always require the operator's approval. Two-gate model crossings are not in any agent's scope.
- Never enter "yours forever" zones (customer conversations, strategic Project Alpha decisions, hiring decisions). Recommend; never act.
- No destructive shortcuts (`--no-verify`, `--force`, deleting unfamiliar files to make obstacles disappear).
- Personal hard rules (see `~/personal-context/work-style/hard-rules.md`), study mornings sacred, voice rules in 'What frustrates me', never fold under pressure.

These are at the operating-contract level, not the path level. An autonomous agent with full permissions still cannot push, send, or spend without the operator.

## The audit-fix loop is structural, not path-driven

defrag-agent's read-only tool list (Read / Grep / Glob / Bash — no Edit / Write) is a *structural* decision from 2026-05-01 (`decisions/agent-os/2026-05-01-fix-loop-and-infra.md` § "Audit-fix two-agent pattern"). The two-agent separation (defrag finds, arch-implementer fixes) is durable safety: defrag *cannot* edit, so its findings are always proposals; arch-implementer *only* edits within its scope. This is independent of the invocation-path system. Autonomous = "runs without direct the operator-direction"; the tool list is a separate constraint.

If the operator wants to collapse the audit-fix loop (give defrag Edit / Write tools), that's a separate decision logged separately. The current invocation-path canon does not change defrag's tool list.

## Graduation / demotion

- **Silent rollback** by the operator → drop to Operator-directed for that agent / skill in that domain. The agent now runs only when the operator directs it.
- **Silent acceptance** → maintain the current invocation path.
- **Explicit approval + active use** → graduate from Operator-directed to Autonomous (skill / cron / agent invocation enabled).

The graduation rule is mechanical. Adaptive autonomy still applies — patterns of friction or smooth runs over time inform whether the path should shift.
