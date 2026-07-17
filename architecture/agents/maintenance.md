---
name: Agent roster maintenance
description: When and how to update the roster files. Killed-agents-removed rule. Agent-body frontmatter carve-out for last_verified.
type: process
canonical: true
owner: chief-of-staff
last_verified: 2026-05-12
---

# Maintenance

## When to update

- **Add an entry** when a new agent is built (in `agents/built.md`) or planned (in `agents/aspirational.md`).
- **Update invocation paths** in `agents/invocation-paths.md` when an agent graduates or gets rolled back.
- **Update boundaries** in `agents/boundaries.md` when overlap shows up in practice.
- **Update dispatch** in `agents/dispatch.md` when a new task category needs routing or an existing one moves.
- **Mirror in `~/.claude/CLAUDE.md`** is one line — update both when this folder changes substantively.

## Killed agents — remove, don't tombstone

Killed entries get **removed** from `agents/built.md` and `agents/aspirational.md`. The kill decision lives in `~/personal-context/decisions/agent-os/` (or `decision-log.md` for cross-domain) — that's where the receipt belongs, not in the active inventory.

**Why:** roster files are operational reference. Future readers shouldn't have to skip past obituaries to see what's running. The decision log preserves history.

## Agent body files do not carry `last_verified`

Files at `~/.claude/agents/*.md` are **operational prompts**, not registry / canon / policy files. They don't get `last_verified` frontmatter and they aren't expected to. Defrag-agent runs should not flag agent bodies for missing `last_verified`.

**Why:** the `last_verified` field exists for canonical files that mirror external state (e.g., `life-os-schema.md`) or carry policy that ages (e.g., `agent-charter.md`, `build-rules.md`). Agent bodies don't fit either shape. Their version-of-truth is the file content itself — defrag's drift checks already cover them via Pass A (registry vs. file) and Pass B (documented rule vs. enforcement).

**Receipt:** RG-02 from defrag run 2026-05-12 surfaced this as a class-level schema gap. Decision: decline + document the carve-out here so it stops getting re-flagged.

The required frontmatter for an agent body is what Claude Code itself requires: `name`, `description`, `model`, `tools`, optional `color`. Nothing else.
