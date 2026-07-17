---
name: Memory layer schema
description: Frontmatter shape for memory files, single-page rule, canonical-winner rule, defaults by type. The structural contract every personal-context file follows.
type: architecture
canonical: true
owner: chief-of-staff
last_verified: 2026-05-02
---

# Memory schema

## Single-page rule

Every file in `~/personal-context/` is **single-topic** and **≤100 lines**. Hard cap, zero exceptions.

**Why:** zero context degradation for agents reading the file. Above 100 lines, model attention skews — mid-file content gets discounted (lost-in-the-middle), edits to one section drift from another. Below 100 lines, the model holds the whole file in active reasoning.

**How to apply:**
- New files: design for single topic, ≤100 lines.
- Existing files past cap: defrag-agent surfaces as registry-category finding; arch-implementer splits per the agent-native filing scheme — semantic subdirectories where 3+ related files cluster, flat at top level for stable single-topic canon.
- Index / reference files don't get an exception. They split too.

## Frontmatter schema

Required for every memory file at layers 1–4:

```yaml
---
name: Human-readable name
description: One-line description for indexes
type: identity | feedback | project | reference | decision-log | architecture | canon | process
canonical: true | false
owner: chief-of-staff | memory-agent | coach-agent | operator
last_verified: 2026-05-01
---
```

Optional fields (use when relevant):

```yaml
domain: agent-os | project-alpha | career | health | etc.   # for per-domain files
valid_until: 2026-09-30                                # TTL for time-sensitive memories
links_to: [other-memory-name, ...]                     # graph edges
originSessionId: <session-id>                          # provenance for in-session captures
```

**Existing files migrate lazily** — new writes use the schema, old files get migrated when next touched.

## Auto-memory defaults by type

When backfilling or creating files in `~/.claude/projects/-Users-yourname-Desktop/memory/`:

| `type` | `canonical` | `owner` | Reasoning |
| --- | --- | --- | --- |
| `feedback` | `false` | `operator` | Mirrors corrections; `how-i-work.md` is canonical home for validated insights |
| `project` | `true` | `chief-of-staff` | Auto-memory `project` IS canonical home for pending actions / deferrals |
| `reference` | `true` | `chief-of-staff` | Auto-memory `reference` IS canonical home for "where to find X" pointers |
| `user` | `true` | `operator` | Identity-level facts not yet promoted to portfolio files |

If a specific entry breaks the default, set explicitly and note why in the body.

## Canonical-winner rule

When two architectural sources disagree on a fact: **surface the conflict, never pick silently.** Memory-agent flags as a finding for the operator to resolve. Mirrors update toward the file marked `canonical: true`. the operator's testimony always wins over recall.
