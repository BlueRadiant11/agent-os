---
name: Persisted-output failsafe procedure
description: Chunk-read protocol when a SessionStart hook output overflows the inline budget and gets persisted to disk. Documented fallback for the rare case the 10-hook split (2026-05-03) doesn't keep every hook under the limit.
type: process
canonical: true
owner: chief-of-staff
last_verified: 2026-05-03
---

# Persisted-output failsafe

Background: SessionStart hooks emit `additionalContext` blocks. When a single hook's output exceeds the harness inline budget, Claude Code persists the full output to disk and surfaces only a 2KB preview wrapped in a `<persisted-output>` block ("Output too large", "Full output saved to: <path>"). The 2KB preview is **not** the always-on core — the rest of the canon is on disk and the agent must read it before responding.

This file is the documented fallback for the rare case the [10-hook split](../hooks/registry.md) doesn't keep every hook under the inline ceiling. After the 2026-05-03 split, `archindex.sh` (~9.75KB) is borderline; if it persists, follow this procedure.

## Procedure (happy path)

1. Detect the wrapper: look for `<persisted-output>` plus "Output too large" plus "Full output saved to: <path>" in the SessionStart additionalContext block.
2. Read the persisted file's first chunk: `Read offset=1 limit=800`.
3. Note the total line count from the file's leading lines (the loader emits this) or infer from the chunk content.
4. Continue chunk-reading: `Read offset=801 limit=800`, `Read offset=1601 limit=800`, etc.
5. Stop when offset exceeds the total line count.
6. Only then proceed to respond to the user.

A single `Read` on the full file fails with "tokens exceeds maximum" (>25,000 tokens). Chunked reads work because each chunk stays under that limit.

## Shadow paths (failure modes)

- **Missing path.** The wrapper claims a file at `<path>` but the path doesn't exist or is unreadable. Treat as a memory miss. Surface to the operator immediately: "Persisted-output path missing: `<path>`. Cannot load canon. Want me to inspect the loader or proceed without?" Do not proceed silently.
- **Mid-loop error.** A chunk Read fails partway through (transient FS issue, stale path, permission error). Restart the loop from chunk 0. If it fails again on the same chunk, surface to the operator with the offset and error.
- **Unexpected format.** The file's leading lines don't match the loader's emitted format (no clear total line count, structure is malformed). Fall back to read-until-EOF: keep incrementing offset by 800 until a chunk returns empty. Note the format anomaly in your response so the operator can investigate.

In all three cases, the bright line is the same: skipping the canon is a memory miss. The contract requires either successful chunk-read or explicit surface-to-the operator — never silent proceed-without.

## Why this exists

The 2026-05-02 SessionStart loader emitted ~69KB in one block. The harness persisted it; the agent had to remember to chunk-read. Forgetting was a silent failure: the agent could continue without the always-on core and have no signal anything was missing. This was a P0 in the 2026-05-03 doc-review — fixed by Unit 1 (10-hook split). This file is the documented insurance: if a hook regresses or grows, the procedure for handling it is here.
