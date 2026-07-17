---
name: Memory layer overview
description: Principle + the six layers of the Agent OS memory system, ordered by lifespan and access pattern.
type: architecture
canonical: true
owner: chief-of-staff
last_verified: 2026-05-02
---

# Memory — overview

How the Agent OS remembers things. Multi-layered, schemaful, owned-write. Designed so multiple agents can read and write without trampling each other.

## Principle

**Be deliberate about what gets remembered.** Generic auto-memory doesn't always pick up the right things — major decisions, priority shifts, end-of-session insights need explicit capture, not implicit hope. The architecture below replaces "hope the agent remembers" with "a defined surface for every kind of fact."

## Layers

Six layers, ordered by lifespan + access pattern:

| Layer | Lifespan | Location | Read by | Written by | Auto-loaded? |
| --- | --- | --- | --- | --- | --- |
| **1. Operating contract** | Years | `~/.claude/CLAUDE.md` | All agents | the operator + CoS (with approval) | Yes, every session |
| **2. Identity portfolio** | Months–years | `~/personal-context/**/*.md` | All agents | the operator + CoS + Memory Agent | No, on-demand |
| **3. Auto-memory** | Days–months | `~/.claude/projects/-Users-yourname-Desktop/memory/` | All agents | In-session captures + Memory Agent | Index always; entries on-demand |
| **4. Capture layer** | Append-only forever | `~/Desktop/claude-workspace/` (lessons, brainstorms, plans) | All agents (esp. Memory) | `/ce:*` skills | No, on-demand |
| **5. Live state** | Real-time | Life OS Supabase, project Supabases, GitHub | Coach Agent + Memory Agent | App users + agents | No, queried |
| **6. Session memory** | Single session | Context window | Current agent only | The model itself | Yes, current session only |

## How to use this spec

- **Chief of Staff** reads `memory/schema.md` and `memory/capture-rules.md` when deciding where to write a new memory.
- **the operator** reads any file in `memory/` when he wants to understand what gets remembered and how.
- **Future agents** read these files as their charter for the memory layer.
- **Memory Agent** implements `memory/agent-charter.md`.

Update memory files when the architecture changes. Other memory files reference *the rules*, not duplicate them.
