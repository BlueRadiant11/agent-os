---
name: Custom Agent OS skills
description: Built skills (7) + candidates Chief of Staff pitches. Build path = compound-engineering loop.
type: registry
canonical: true
owner: chief-of-staff
last_verified: 2026-05-12
---

# Custom skills

Build path: `/ce:brainstorm` → `/ce:plan` → `/ce:work <plan-path>` → `/ce:compound` (full loop, no shortcuts).

## Built (7)

| Skill | Path | Purpose | Invocation |
| --- | --- | --- | --- |
| `jot` | `~/.claude/skills/jot/SKILL.md` | Quick single-fact capture with classification + dedup. Three modes: scan recent context (no args), explicit thought, type-prefixed. | Operator-directed (or composed by Autonomous agents) — proposal-before-write is the human gate |
| `route-memory` | `~/.claude/skills/route-memory/SKILL.md` | Daily synthesis from session history. Routes content into four categories. Composed by Memory Agent on Operator-directed runs (cron disabled 2026-05-04). | Operator-directed via memory-agent — digest-before-write |
| `dedupe-memory` | `~/.claude/skills/dedupe-memory/SKILL.md` | Sweep all in-scope memory files for duplicates / supersession / drift / project-CLAUDE.md mirror divergence. Always proposes. | Operator-directed — destructive potential, never auto |
| `morning` | `~/.claude/skills/morning/SKILL.md` | Canonical morning-brief procedure. Harvests inbox + claude-workspace + GitHub + Life OS deltas, dedups across sources, composes the locked SHIPPED OVERNIGHT / BLOCKED ON YOU / QUEUED FOR TODAY / NOTICED format. Read-only sources; archival the operator-gated. | Operator-directed |
| `build-pipeline` | `~/.claude/skills/build-pipeline/SKILL.md` | Designated build path for new skills and sub-agents. Composes `/ce:brainstorm` → `/ce:plan` → `/ce:work` → `/ce:compound` plus design / verification waypoints for agents. | Operator-directed (composed by CoS) |
| `dispatch-protocol` | `~/.claude/skills/dispatch-protocol/SKILL.md` | Internal CoS procedure for dispatch decisions, briefing background agents, standardized handoff format, verification, morning-brief inbox protocol. | Operator-directed (composed by CoS) |
| ~~`refresh-session`~~ archived 2026-05-19 → `~/.claude/skills/.archive/2026-05-19-refresh-session/` | (archived) Two-phase mid-session refresh — captured wip to file, the operator typed `/compact`, dumped wip back. Zero composes in 90 days at audit; native `/compact` + SessionStart loader hooks cover the use case. Reversible via `mv` if a real cycling need surfaces. | (archived) |

The first four shipped 2026-05-01 without brainstorm/plan; defrag-agent's first audit flagged the gap and a retroactive CE-loop pass ran the same day. `/build-pipeline` and `/dispatch-protocol` shipped 2026-05-02 also without brainstorm/plan (defrag findings BP-01/BP-02 pending — accept trivial-skill carve-out or run retroactive CE-loop).

## Candidates (CoS pitches one at a time when triggered)

| Skill | Purpose | Trigger to pitch |
| --- | --- | --- |
| `/decision` | Walks through the decision-log template (Decision / Context / Options / Why / What-would-change), appends to `decision-log.md`. | the operator is making or has just made a decision worth logging. |
| `/triage` | Scans `~/personal-context/` for `_Open:_` lines, ranks top 3, offers to interview. | A portfolio-fill session opens, or the operator asks "what's missing." |
<!-- /coach SHIPPED 2026-05-07 as the invocation surface for coach-agent. Skill at ~/.claude/skills/coach/SKILL.md, agent at ~/.claude/agents/coach-agent.md. Removed from candidates. -->
| `/load <project>` | Session warm-up: loads relevant portfolio slices + project CLAUDE.md + recent session. | the operator shifts to working on Project Alpha / Life OS / day-job context. |
| `/build-agent` | Interview-driven agent build flow. Walks the operator through what the new agent should do, drafts the one-paragraph spec, dispatches `agent-skill-creator`, then handles post-build registry / architecture-schema updates (aspirational → built migration, dependency graph regen). | the operator wants to build a new agent and the spec isn't crisp yet — current path requires writing the spec first. Parked 2026-05-03 with Agent OS → maintenance. |
