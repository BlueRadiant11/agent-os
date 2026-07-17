---
name: Memory cleaning rules
description: TTLs per layer, staleness signals, dedup detection, conflict resolution, orphan-file detection, pairwise consistency. The rules that keep the memory layer from rotting.
type: process
canonical: true
owner: chief-of-staff
last_verified: 2026-05-12
---

# Cleaning rules — what gets removed or refreshed

## TTL defaults per layer

- Operating contract: never expires (manual review only)
- Identity portfolio: review on life events; otherwise no auto-expire
- Auto-memory: 90-day soft TTL; flag for review, don't auto-delete
- Capture layer: append-only, never auto-delete (manual cull when `lessons.md` exceeds ~40 entries / ~500 lines per the protocol)
- Live state: re-query, never cached
- Session memory: dies with session

## Staleness signals

- `last_verified` older than 90 days for auto-memory entries → flag for refresh
- `valid_until` past current date → soft-archive
- Memory contradicts current observation → trust observation, update memory
- Same fact in 2+ canonical files → flag drift, reconcile to whichever has `canonical: true`

## Dedup detection

- Memory Agent compares new captures to existing entries before writing
- Threshold: high textual / semantic similarity → propose update instead of new entry
- the operator resolves ambiguous cases

## Conflict resolution

- Two writes to the same file simultaneously: last-writer-wins on a field-by-field basis only if `owner` is the same; otherwise the registered `owner` wins
- Cross-file fact drift: canonical home wins; mirrors update to match
- the operator's testimony always wins over recall

## Orphan-file detection

Every file under `~/personal-context/{goals,projects,identity,domain-knowledge}/` must have ≥1 inbound reference from one of:

- A SessionStart loader hook (`~/.claude/hooks/personal-context-*.sh`) that auto-injects it
- `~/.claude/hooks/context-router-map.json` (keyword routing)
- A stable cross-reference in `CLAUDE.md`, `identity.md`, or `decision-log.md`

Files with zero inbound references are orphans — the operator wrote them but future sessions can't find them. Memory Agent surfaces orphans as findings during Phase 5 of the operating loop.

## Pairwise consistency

When a named entity (proper-noun phrase — a growth-edge name, project codename, person name) appears in 3+ canonical files, Memory Agent spot-checks pairwise that key facts agree across all files:

- Dates of origin
- Description / framing
- Classification or type
- Status (active / paused / dropped)

Inconsistencies surface as findings. Trigger threshold: 3+ inbound references. Below threshold, the cross-file-drift rule above is sufficient.
