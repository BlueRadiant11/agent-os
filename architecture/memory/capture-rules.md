---
name: Memory capture rules
description: What to write where, by fact type. The routing table for every piece of remembered knowledge.
type: process
canonical: true
owner: chief-of-staff
last_verified: 2026-05-02
---

# Capture rules — what to write where

By fact type. Match the trigger; write to the named file.

## Decisions

- **Life-level / identity-shaping decision** → `decision-log.md`
- **In-flight per-domain decision** → `decisions/<domain>.md`
- **Triggers:** decision lands; alternatives considered; trajectory affected

## Working-style insights

- **Validated positive insight** → `how-i-work.md` (after 3+ confirmations or explicit the operator validation)
- **Correction the operator gave you** → auto-memory `feedback` file
- **Triggers:** the operator says "yes exactly do that" or "stop doing X"

## Project state changes

- **Change in priorities, deadlines, role status** → relevant portfolio file (`projects/<project>.md`, `goals/`, `identity/roles-and-time.md`)
- **Triggers:** the operator names a deadline / new commitment / dropped commitment

## Operational lessons (technical / tooling)

- **Project-specific technical lesson** (something learned while working in `~/Desktop/project-alpha/`, `~/Desktop/life-os/`, etc.) → `/ce:compound`, which writes to that project's `docs/solutions/<category>/<slug>-<date>.md`. Plugin behavior.
- **Cross-project / Agent OS / Claude-Code-itself lesson** → manual append to `~/Desktop/claude-workspace/context/lessons.md`. Older convention; still the right home for lessons that don't belong to any one project repo.
- **Triggers:** match the four criteria in `~/Desktop/claude-workspace/context/compound-protocol.md` (surprising / costly / counterintuitive / would save future googling).

## Identity-level facts about the operator

- **New fact about who the operator is** → relevant portfolio file (`identity.md`, `identity/relationships-*.md`, etc.)
- **Triggers:** the operator shares a new role, relationship, value, milestone

## External-system pointers

- **Where to find X in tool Y** → auto-memory `reference` file
- **Triggers:** the operator names a system / dashboard / channel as authoritative

## Pending actions / deferrals

- **"Remember to do X later"** → auto-memory `project` file
- **Triggers:** the operator says "shelve this," "do this later," or pre-commits a future trigger
