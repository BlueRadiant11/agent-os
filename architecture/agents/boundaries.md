---
name: Agent boundaries
description: Pairwise overlap resolution between agents. Architecture vs content seam test, plus the canonical-winner rule.
type: reference
canonical: true
owner: chief-of-staff
last_verified: 2026-05-03
---

# Boundaries between agents

## Architecture vs content seam test

The primary boundary across the agent roster:

- **"What's true?"** — a fact, an entry value, a date, a Project Alpha cap, a project description. **Content.** Memory-agent's lane.
- **"Whether two structural records agree?"** — registry vs. file, doc vs. settings.json, invocation-path table vs. graduation event, planned roster vs. actual `.md` files. **Architecture.** Defrag-agent's lane.

When the call is ambiguous, surface the ambiguity itself as a finding under category `roster` or `registry` and let the operator decide. **Never pick silently** — same canonical-winner rule that governs every other registry.

## Pairwise overlap resolution

| Pair | Resolution |
| --- | --- |
| Memory Agent ↔ Defrag Agent | Memory = content; Defrag = architecture. Memory worries about a stale entry; Defrag worries about an inconsistent rule in CLAUDE.md. |
| Memory Agent ↔ Self-Improvement Agent | Memory keeps memory layer healthy; Self-Improvement researches *new improvements* and proposes them. Memory cleans what exists; Self-Improvement evolves what could be. |
| Coach Agent ↔ Memory Agent | Coach reads current Life OS state for coaching; Memory harvests Life OS *deltas* for synthesis. Coach is real-time; Memory is summary. |
| `/jot` ↔ `/route-memory` | `/jot` = single fact, manual; `/route-memory` = past-N-hours batch. Same routing rules; different scope. |
| `/jot` ↔ `/dedupe-memory` | `/jot` prevents duplicates at write time; `/dedupe-memory` cleans up duplicates that already exist. Preventive vs. corrective. |
| defrag-agent ↔ arch-implementer | defrag audits and surfaces; arch-implementer applies what the operator approves. Defrag has read-only tools; arch-implementer has Edit/Write. |
