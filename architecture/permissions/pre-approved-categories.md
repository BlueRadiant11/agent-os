---
name: Pre-approved task categories
description: Categories of work Chief of Staff may execute without asking. Anything not on this list is treated as new and surfaces for the operator approval (Predict-and-ask). Distinct from settings.json `allow` (which permits specific tool calls); this file enumerates classes of work.
type: registry
canonical: true
owner: operator
last_verified: 2026-05-03
---

# Pre-approved categories

Resolves the deadlock between **Predict-and-ask for new task categories** and **Permission fatigue: don't ask permission to touch what's been pre-authorized.** A task in this list = pre-authorized; not in this list = new, treat as such.

Distinct from `allow.md`: that file lists tool-call patterns the harness auto-approves. This file lists *kinds of work* CoS may undertake without asking. Both gates apply — a tool call must clear `allow.md` AND the work must clear this list.

This file is also the canonical bound for the **Two-gate model's autonomy zone** in CLAUDE.md § "Two-gate model." Between Gate 1 (decide) and Gate 2 (ship), CoS may execute anything in the Pre-approved list below; anything outside the list re-triggers Gate 1, even mid-task.

## Pre-approved (CoS executes without asking)

- **Read-only inspection.** Any Read / Grep / Glob / file-list anywhere on disk the operator owns. No data leaves.
- **Scratch artifact creation.** Writes inside `~/Desktop/claude-workspace/` — plans, brainstorms, lessons, drafts, scratch notes.
- **Memory capture via the `jot` skill.** Routing facts to `~/personal-context/` through the jot skill. The skill is the gate (proposes before write).
- **Agent dispatch.** Invoking any built sub-agent (memory-agent, defrag-agent, arch-implementer, agent-skill-creator) on its declared scope.
- **Skill composition.** Invoking any installed skill (custom or compound-engineering-plugin).
- **Status sweeps and audits.** Querying state (git, supabase read-only, launchctl list, find / grep across the filesystem) to inform a report.

## NOT pre-approved (CoS must ask first)

- **Direct edits to `~/personal-context/`** outside the jot-skill path. The jot skill is the canonical gate; bypassing it is a new category each time.
- **Edits to any canonical home in `~/.claude/architecture/`** — registry rows, dependency graphs, agent canon, memory canon.
- **Edits to `~/.claude/CLAUDE.md`** — the operating contract. Always asks.
- **Edits to `~/.claude/settings.json` or any file in `~/.claude/hooks/`** — runtime config and harness behavior.
- **Creation of new agents, skills, runners, or hooks.** Build pipeline applies (`/ce:brainstorm` → `/ce:plan` → `/ce:work` per `agent-skill-creator`).
- **Anything that hits a bright line.** Push / send / spend. Already non-negotiable; listed here for completeness so the categorization is self-contained.
- **Writes to Supabase, Cloudflare, Vercel, or any MCP service** — runtime state for live products.

## Resolving the gray middle

When a task doesn't clearly match either list, treat as new and ask. The cost of one extra "is this OK?" is low; the cost of an unauthorized initiative on the operator's apex contract is high.

If the same gray-middle category gets approved repeatedly, propose adding it to the pre-approved list. Same evolution shape as `evolution-protocol.md` for the `allow / deny / ask` arrays.

## Maintenance

the operator refines this list after observed friction. The initial entries (drafted 2026-05-03 with the operator's "trust inference" green-light) are best-inference defaults, not absolute truth. If the list is too tight, the failure mode is permission fatigue. If it's too loose, the failure mode is unauthorized initiative. Both are visible in normal sessions; both get caught and proposed back here.
