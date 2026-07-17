---
name: dispatch-protocol
description: Internal Chief-of-Staff procedure for dispatching work to sub-agents. Covers when to dispatch vs. inline, splitting multi-project requests, briefing background agents, the standardized agent-to-CoS handoff format, verifying before relaying, and the morning brief inbox (asynchronous channel for cron-driven agents). Use when CoS is about to dispatch a sub-agent, when a multi-project ask lands, when an agent reports back, or when reading the inbox at session start.
---

# /dispatch-protocol

Internal procedure for the dispatcher half of Chief of Staff. CoS reads this when about to delegate, when an agent reports back, or when reading the inbox.

**Default dispatch path (2026-06-10, native):** plain `Agent` tool calls. The dispatch is one tool call carrying the brief directly in the prompt. Foreground responses return via the Agent tool wrapper; background responses (`run_in_background=true`) surface via Claude Code's native completion notification — don't poll. Use `SendMessage` to continue a previously spawned agent with its context intact. The sentinel + `pre-tool-use-bridge-only.sh` enforcement layer was removed 2026-06-10 (the pad infrastructure it guarded was torn out 2026-05-19; the sentinel outlived its referent) — receipt: `~/personal-context/decisions/agent-os/2026-06-10-fable-fit-overhaul.md`.

## Design-question fallback (universal sub-agent contract)

Every sub-agent body inherits this section (canonical home: here, as of 2026-06-10). When an agent needs an answer to a design question the operator didn't provide in the dispatch prompt, it consults sources in this order, stopping at the first hit:

1. **`~/personal-context/`** direct match. `Grep` / `Read` against likely homes (`work-style/`, `projects/`, `decisions/`, `identity/`, `goals/`).
2. **Inference** from `~/personal-context/` patterns. Look at how other skills / agents handle similar concerns; pick the most consistent option.
3. **Agent's own judgment.** Truly novel design choice with no signal. Make a call, document as a FINDING in the response (severity `low` unless genuinely high-stakes; describe decision, reasoning, override path).

Never escalate to the operator mid-run. The agent runs in one shot from dispatch to response.

*Trivial-skill carve-out: dispatch-protocol is a meta-procedural docs-skill (no execution surface), zero design decisions distinct from the documented procedure. Brainstorm + plan skipped per Path A § Trivial-skill carve-out (`~/.claude/agents/agent-skill-creator.md:46`). Approved by the operator 2026-05-02.*

## When to dispatch (default = yes if any apply)

- **Independent work** that doesn't need real-time the operator input.
- **Mechanical operations** that would fill the main context window — file rewrites, repo sweeps, doc updates, find-and-replace, build/test runs, format conversions.
- **Multi-project / multi-task requests.** N independent things → dispatch N agents in parallel — one per project, not one sequential pass through all of them.
- **Long-running tasks** with predictable shape — anything taking more than a few tool calls of mechanical work.

## When NOT to dispatch (do inline)

- **Interview-style work** that needs the operator in the loop turn-by-turn ("walk me through", "interview me", "talk through this").
- **Quick edits** where dispatching would take longer than just doing.
- **Sensitive operations** the operator wants to watch (anything touching auth, money, external messaging, production data).
- **Reasoning / synthesis** that benefits from CoS's accumulated session context.

## Splitting multi-project requests

When the operator describes 2+ independent things in one ask, split into per-agent dispatches *before* doing anything else. One agent per logical project. Run in parallel using a single message with multiple `Agent` tool calls so they run concurrently.

Example: "Build skills X, Y, Z and run them in the background" → three parallel `Agent` calls, one per skill, each with its own self-contained brief.

### Compose `superpowers:dispatching-parallel-agents` for the parallel-shape decision

When the case is specifically multi-domain parallel (2+ independent problem domains with no shared state), compose `superpowers:dispatching-parallel-agents` for the per-dispatch structure (focused scope, self-contained context, constraints, specific output format, post-return conflict review). The skill governs the *shape* of each parallel dispatch; the `Agent` tool is the dispatch mechanism. Compose superpowers' parallel-dispatch skill, then run each surfaced parallel item as an `Agent` call.

This is a "compose within" pattern, not a swap. dispatch-protocol owns the broader dispatch surface (when-to-dispatch-vs-inline, briefing format, handoff contract, inbox protocol); superpowers' skill plugs into the multi-project-parallel branch only. Receipt: `~/personal-context/decisions/agent-os/2026-05-19-superpowers-scoped-adoption.md`.

## Permission posture

- **Don't ask permission to dispatch.** Pre-approved, Tier-3 autonomous behavior. The dispatch itself is not the work — the work is what the agent does.
- **Bright lines still apply.** Background agents inherit the two-gate model: cannot push, send, spend, deploy, or write to external services without the gates intact. Brief the agents explicitly with these constraints.
- **Verify before reporting "done."** When a background agent reports completion, read the actual artifact (the file it wrote, the diff it produced) before telling the operator it's done.

## Briefing background agents

Each background-agent prompt must include:

- **Goal in one paragraph.** The agent has zero context — brief like a smart colleague who just walked in.
- **Spec / inputs / outputs.** What success looks like, where artifacts go.
- **Constraints.** Always include: no commits, no pushes, no deploys, no Supabase / external writes unless explicitly authorized.
- **Reporting format.** Use the standardized handoff format below.

## Reporting to the operator

When dispatching, tell the operator in one block:

```
DISPATCHED (background, in parallel)
  - <agent-1>: <one-line purpose>
  - <agent-2>: <one-line purpose>
CONTINUING IN FOREGROUND
  - <what's happening here, if anything>
```

When background agents complete, batch verifications into a single SHIPPED block. Don't interrupt the operator one-at-a-time as agents finish; wait for natural breakpoints.

## Standardized agent-to-CoS handoff format

Every background agent reports back using this format. Compact, structured, scannable. Drives directly into CoS's SHIPPED-block reporting without translation.

```
STATUS: shipped | partial | blocked

ARTIFACTS
  - <absolute path>: <one-line summary> (<bytes>)

DECISIONS
  - <judgment call made during build>: <one-line rationale>

FINDINGS
  - <surfaced issue / drift / risk>: <severity: high | medium | low>

BLOCKERS
  - <if status != shipped, what stopped it>

NEXT
  - <suggested follow-up, if any>
```

Rules:

- **Omit empty sections.** No "DECISIONS: none" filler.
- **Absolute paths only.** No `~/` shorthand in artifacts.
- **One line per item.** If something needs two lines, it needs its own section or follow-up.
- **Findings are first-class.** Real surfaced issues report in FINDINGS, not buried in DECISIONS.
- **Status definitions:** `shipped` = full goal met, artifacts written, validated. `partial` = some artifacts produced, others blocked. `blocked` = could not produce the artifact.

When briefing background agents, **include this format in the prompt** under "Report back" — every brief instructs the agent to use it.

## Verifying before relaying

When an agent reports `STATUS: shipped`, CoS verifies the actual artifact (`wc -l`, `head`, or full `Read`) before passing the success up to the operator. Trust the agent's intent; verify the result. If the artifact doesn't match the report, downgrade to `partial` in the SHIPPED block to the operator with the discrepancy noted.

## Morning brief inbox (asynchronous channel)

When an agent runs **without an active CoS session** (cron, scheduled, autonomous), it can't return synchronously via the Agent tool. It drops a report at **`~/.claude/inbox/<agent-name>-<ISO-timestamp>.md`** in the standardized handoff format. `/morning` reads the inbox when the operator next opens a session and composes the brief.

**Active scheduled runners** — see `~/.claude/architecture/runners/active.md`.

**Inbox protocol** (full README at `~/.claude/inbox/README.md`):

1. **Agent writes:** file at `~/.claude/inbox/<agent-name>-YYYY-MM-DDTHH-MM.md` using the standardized handoff format.
2. **Session-start glance:** on first interaction in a fresh session, check `~/.claude/inbox/`. If non-zero unread reports, surface as one-liner: *"inbox has N unread reports — want a brief?"* Don't auto-process; just signal.
3. **CoS reads on demand** (when the operator says "morning brief" / "check inbox" / `/morning`): list contents, read each file, aggregate into morning brief format, present.
4. **CoS archives after the operator acknowledges:** move each processed file to `~/.claude/inbox/archive/<YYYY-MM-DD>/`.
5. **Stale inbox items (>7 days unread):** surface as overdue; ask the operator whether to process or discard.

**When NOT to use the inbox:**

- In-session agent dispatches — return synchronously via the Agent tool.
- Permanent memory writes — go through `/jot` into the memory layer.
- Long-form artifacts — reference paths in `ARTIFACTS`, keep content elsewhere.

## Anti-pattern

Don't dispatch work that the operator explicitly framed as a conversation. "Walk me through" / "interview me" / "talk through this" → these are inline work, not dispatch candidates. Read intent before defaulting to delegation.
