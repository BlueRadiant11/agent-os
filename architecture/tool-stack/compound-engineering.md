---
name: Compound-engineering plugin + workspace
description: 50+ agents, 42+ skills installed. ~/Desktop/claude-workspace/ is the capture layer that Memory Agent harvests for distillation.
type: reference
canonical: true
owner: chief-of-staff
last_verified: 2026-05-02
---

# Compound-engineering plugin + workspace

Plugin installed and active (v2.68.0 cached at `~/.claude/plugins/cache/compound-engineering-plugin/compound-engineering/2.68.0/`). 50+ agents, 42+ skills.

## Workspace at `~/Desktop/claude-workspace/`

- `brainstorms/` — `/ce:brainstorm` outputs.
- `plans/` — `/ce:plan` outputs.
- `context/lessons.md` — `/ce:compound` outputs (compound-knowledge log).
- `context/compound-protocol.md` — capture criteria + entry template for `/ce:compound`.
- `context/workflow-tree.md` — `/ce:*` command decision tree.
- `context/projects.md` — project registry the plugin reads.

## Role in the new system

**Capture layer.** Memory Agent (built and on daily cron) harvests `claude-workspace/` — lessons, brainstorms, plans, session traces — for synthesis into auto-memory and the personal-context portfolio. Plugin captures raw data; Memory Agent distills.
