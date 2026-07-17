---
name: Memory categories — current state
description: Where each kind of memory currently lives across the Agent OS layers.
type: reference
canonical: true
owner: chief-of-staff
last_verified: 2026-05-02
---

# Memory categories — current state

Quick map of which file owns which kind of fact.

## In identity portfolio (`~/personal-context/`)

- `identity.md` — who the operator is, distilled
- `identity/` — roles, time accounting, relationship inventories
- `current-projects.md` + `projects/` — active workstreams
- `tool-stack.md` + `permissions/` + `hooks/` + `runners/` — what he uses + how it's wired
- `work-style/voice-canon.md` — voice rules
- `work-style/` — preferences, constraints, habits, spending posture
- `goals/` — short and long arcs
- `domain-knowledge/` — expertise
- `decision-log.md` — life-level decisions (zoom-out)
- `decisions/agent-os/` — Agent OS architecture decisions (zoom-in; themed sub-files)
- `decisions/project-alpha.md` — Project Alpha decisions (zoom-in)
- `decisions/career.md` — career-arc decisions (zoom-in)
- `how-i-work.md` — distilled positive insights about the operator's working style
- `memory/` — the spec itself (this folder)
- `agents/` — agent canon
- `agent-os-architecture.md` — top-level architecture index
- `shelf.md` — explicitly paused items
- `README.md` — portfolio overview

## In auto-memory (`~/.claude/projects/.../memory/`)

- `MEMORY.md` — index (truncated after line 200)
- Individual files by type (`feedback`, `project`, `reference`, `user`)

## In capture layer (`~/Desktop/claude-workspace/`)

- `context/lessons.md` — non-obvious technical lessons
- `context/compound-protocol.md` — capture criteria for lessons
- `brainstorms/` — `/ce:brainstorm` outputs
- `plans/` — `/ce:plan` outputs

## Deferred (not built yet)

- Per-person interaction memory (`relationship_<initials>.md`) — deferred until Memory Agent ships and capture / cleaning is solid.
