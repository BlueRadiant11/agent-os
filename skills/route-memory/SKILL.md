---
name: route-memory
description: "Manual on-demand version of the future Memory Agent. Scans the past 24 hours of session history (Claude Code, Codex, Cursor) for load-bearing facts and routes each into the correct memory or context file under ~/personal-context/. Produces an approval digest first; writes only after the operator approves. Use when the operator says 'route memory', 'synthesize the day', 'run memory routing', 'process yesterday's sessions', or any phrasing that asks for the daily memory sweep before the Memory Agent ships."
argument-hint: "[past 24 hours | past 48 hours | since yesterday]"
---

# /route-memory

Manual daily memory sweep. Reads recent session history, classifies what is load-bearing, and routes it into the operator's personal-context files using the rules in `~/.claude/architecture/memory/`. This is the on-demand stand-in for the future Memory Agent cron.

## Bright lines (do not cross)

- **No git commits, no pushes, no deploys, no Supabase writes, no MCP writes.** This skill writes only local files under `~/personal-context/`.
- **No write happens before the operator approves the routing digest.** Present, wait, then write.
- **No `--no-verify`, no force flags, no destructive shortcuts.** If something blocks, surface it.
- **Truth above all.** If a fact is uncertain, mark it uncertain in the digest. Do not invent details to fill a slot.
- **Goals Supabase is read-only context.** Do not write to project `YOUR_SUPABASE_PROJECT_ID`, table `goals`, or any other database. Goal-state changes go to `~/personal-context/goals/<topic>.md` only.

## When to run

the operator invokes manually (typically morning or end of day) until the Memory Agent ships. One run per call — do not loop.

## Inputs

Optional argument: a time-window override. Default is past 24 hours. Accept phrasings like `past 48 hours`, `since yesterday morning`, `this week`. If the argument is empty or unparseable, default to 24 hours and state that in the digest header. If the parsed window is greater than 7 days, note in the digest header that large windows may produce noisy output.

## Step 1 — Load the routing rules

Before anything else, read end-to-end:

- `~/.claude/architecture/memory/`

That file is the source of truth for capture rules, frontmatter schema, dedup behavior, and which file each kind of fact belongs in. Use its "Capture rules — what to write where" section as the classifier. Do not paraphrase those rules from memory — re-read them each run, since they may have changed.

Also list (do not fully read yet) the destination files so you know what exists:

- `~/personal-context/identity.md`
- `~/personal-context/identity/roles-and-time.md`
- `~/personal-context/projects/<project>.md`
- `~/personal-context/goals/<topic>.md`
- `~/personal-context/how-i-work.md`
- `~/personal-context/decisions/project-alpha.md`
- `~/personal-context/decisions/agent-os/`
- `~/personal-context/decisions/career.md`
- `~/personal-context/decision-log.md`
- `~/.claude/architecture/memory/`

## Step 2 — Harvest sessions

Dispatch the `compound-engineering:research:session-historian` agent. Pass it:

- The time window (default: past 24 hours).
- Scope: all platforms — Claude Code (`~/.claude/projects/`), Codex (`~/.codex/sessions/`), Cursor (`~/.cursor/projects/`). Do not restrict by repo or branch — the operator's work crosses repos and contexts.
- Task prompt: "Return load-bearing facts from these sessions. Load-bearing means anything that would shift the operator's identity, goals, priorities, working style, project state, or Agent OS architecture if a future agent didn't know it. Skip everyday work execution, code commits, debugging steps, and routine status. Return each fact as: (1) one-sentence summary, (2) which session/timestamp it came from, (3) verbatim quote or strongest evidence, (4) your read on which of these four buckets it fits — project-specific, life-growth-specific, goals-specific, agent-os-improvement, or none-of-the-above."
- Output format: a structured list, one fact per entry.
- Omit the `mode` parameter so the operator's permission settings apply.

If the session-historian returns nothing relevant, stop. Report "No load-bearing facts in the past <window>" and end the run.

## Step 2.5 — Source health

Before classifying, check the harvest succeeded cleanly. Three failure cases require explicit handling — never fall through silently.

- **Unreachable platforms.** If a platform directory (`~/.cursor/projects/`, `~/.codex/sessions/`) does not exist on this machine, note the missing platform in the digest header and proceed with the platforms that did return. Do not abort.
- **Session-historian error.** If the agent dispatch errors out (timeout, sandbox boundary, permission failure, infrastructure issue), abort the run with a BLOCKED report. Name the exact error and what would unblock. Do not fall through to "no load-bearing facts" — that's a truth-above-all violation.
- **Malformed output.** If session-historian returns output that does not match the expected per-fact structure (missing summary / source / quote / category fields), abort with BLOCKED naming the malformation. Do not attempt to parse partial or guessed structure.

## Step 3 — Classify

For each fact returned, apply the four-category routing. The categories and their destinations are:

**1. Project-specific** — anything about an active workstream's state, decisions, scope, or role.
- Project state change (priorities, deadlines, scope, commitments dropped or added) → `~/personal-context/projects/<project>.md`
- Project Alpha product/business decision → `~/personal-context/decisions/project-alpha.md`
- Role or responsibility shift → `~/personal-context/identity/roles-and-time.md`

**2. Life growth-specific** — identity-shaping or working-style facts about the operator himself.
- New identity-level fact (role, value, milestone, relationship he names as load-bearing) → `~/personal-context/identity.md`
- Goal-level shift or new arc → `~/personal-context/goals/<topic>.md`
- Validated positive working-style insight (3+ confirmations OR explicit the operator validation in-session) → `~/personal-context/how-i-work.md`

**3. Goals-specific** — explicit goal additions, priority reorderings, deadline shifts.
- → `~/personal-context/goals/<topic>.md`
- Reminder: the Life OS Supabase `goals` table is read-only context. This skill never writes there.

**4. Agent OS improvement-specific** — anything about how the Agent OS itself should change.
- Architecture or sub-agent decision → `~/personal-context/decisions/agent-os/`
- Working-style implication for the Agent OS (how the operator wants to interact with agents) → `~/personal-context/how-i-work.md`
- Memory-system rule change → `~/.claude/architecture/memory/`

If a fact does not match any of the four categories, skip it. Note skipped items in the digest under "Skipped" with a one-line reason — do not silently drop. Use this four-reason rubric:

- `not load-bearing` — fact is real but wouldn't shift behavior of a future agent.
- `already captured live` — fact already exists in destinations verbatim (caught at harvest, not at the dedup stage).
- `outside the four categories` — load-bearing but doesn't fit project / life-growth / goals / Agent-OS-improvement. Surface for the operator to decide whether to extend the architecture.
- `transient context` — session-scoped detail (working notes, debug, hypothetical) that won't matter beyond the session.

If a skip doesn't fit one of these four, surface as `uncertain — needs the operator's read` instead.

If a fact spans two categories, route to the most specific one and cross-reference the other in the entry's `links_to` field. Examples:

- Project Alpha decision that also shifts a goal → `~/personal-context/decisions/project-alpha.md` (most specific), cross-reference `goals/<topic>.md` in `links_to`. Don't double-write.
- Agent OS improvement that's also a working-style insight → `~/personal-context/decisions/agent-os/`, cross-reference `how-i-work.md`. Architecture decision is more durable than working-style flavor.
- Identity-level fact that mentions a project → `~/personal-context/identity.md`, no cross-reference. Project mention is contextual, not load-bearing.

## Step 4 — Dedup against existing files

Before drafting any new entries, read the destination files identified in Step 3. For each candidate fact:

- Search the destination file for high textual or semantic similarity (same decision, same insight, same project state).
- If a near-match exists: propose an *update* to the existing entry (refresh `last_verified`, append clarifying detail) rather than a new entry. Show both the existing entry and the proposed update in the digest.
- If no match: propose a *new entry* in the file's existing format.

Dedup is a stop on writing — if you can't tell whether something is a duplicate, mark it `uncertain — needs the operator's read` in the digest and let him decide.

## Step 5 — Draft entries

For each routed fact, draft the actual text that would be written. Match the destination file's existing format exactly:

- Files with a `## Entries` section: append under it in the file's existing entry shape. Decision files use the Decision / Context / Options / Why this path / What would change it shape — match it.
- New files (rare, but possible if a routing target doesn't exist yet): before creating, list the destination directory and check for similarly-named existing files (case mismatch, hyphen vs underscore, plural vs singular). If a candidate exists, surface as `uncertain — possible file mismatch` and let the operator decide whether to use the existing file or create a new one. If no candidate, use the full frontmatter schema from `memory/`:
  ```yaml
  ---
  name: <human-readable name>
  description: <one-line description>
  type: identity | feedback | project | reference | decision-log | architecture | canon | process
  canonical: true | false
  owner: chief-of-staff
  last_verified: <today's date YYYY-MM-DD>
  ---
  ```
- Existing files: do not rewrite frontmatter. If `last_verified` is more than 30 days old and you're touching the file, propose bumping it as a separate digest line so the operator sees the change. In async mode (memory-agent caller), the bump is part of the same write batch — memory-agent's Tier-3 carve-out covers `last_verified` bumps on files actually edited. The bump line in the digest is informational + actionable, not a separate approval.

Voice: match the destination file's tone. Most personal-context files are blunt, lowercase-comfortable, no AI-tells. No em-dash spam, no wrap-up paragraphs.

**Provenance.** When the destination file's existing entries include `originSessionId` (decision logs sometimes do; identity-portfolio entries usually don't), capture the source session ID returned by session-historian as that field. Don't manufacture this field for files that don't use it; respect existing format.

## Step 6 — Present the routing digest

Output a single digest in this shape, then **stop and wait for the operator's approval before writing**:

```
ROUTE-MEMORY DIGEST — <date>, window: <window>
Mode: <sync (awaiting approval) | async (memory-agent caller, autonomous carve-out applies)>

PROPOSED WRITES (<n>)

  1. [project-specific] -> ~/personal-context/projects/<project>.md
     Action: append new entry
     Source: <session id / timestamp>
     Entry text:
       <exact text that would be appended>

  2. [agent-os-improvement] -> ~/personal-context/decisions/agent-os/
     Action: update existing entry "<entry title>"
     Source: <session id / timestamp>
     Diff:
       - <existing line>
       + <new line>

  ...

UNCERTAIN — NEEDS YOUR CALL (<n>)

  - <one-line summary>
    Possible homes: <file A> or <file B>
    Why uncertain: <reason>

SKIPPED (<n>)

  - <one-line summary> — <reason: not load-bearing | already captured live | outside the four categories>

Approve? Reply 'approve all' to write everything, 'approve <numbers>' to write a subset, 'skip <numbers>' to skip specific items, or 'cancel' to abort the run.
```

If the result is empty, distinguish three cases — do not collapse them into one message:

- **No sessions in window:** one-line `route-memory: no sessions in past <window>`. End the run.
- **Sessions present, nothing load-bearing:** one-line `route-memory: <n> sessions reviewed, nothing load-bearing in past <window>`. End the run.
- **Sources unreachable:** handled in Step 2.5 via BLOCKED. Do not duplicate the BLOCKED pathway here.

When there is at least one proposed write, uncertain item, or skipped item with an interesting reason, show the full digest skeleton.

## Step 7 — Write (only after approval)

After the operator approves:

1. For each approved entry, perform the write using the Edit tool (for appends/updates to existing files) or the Write tool (for new files only). Never use the Write tool to overwrite an existing file.
2. After all writes complete, output a one-line confirmation per file written, in the format:
   ```
   wrote: ~/personal-context/<file>  (<append|update|new>)
   ```
3. If any write fails, stop the batch, report which file failed and the error, and do not retry silently.

Do not run any verification reads after writing. the operator can read the diff if he wants.

## Step 8 — Do not do these things

- Do not invoke `compound-engineering:ce-compound`, `ce-brainstorm`, or any other skill from inside this one. This skill stands alone.
- Do not write to `~/Desktop/claude-workspace/context/lessons.md`. That's the operational-lessons capture surface; it has its own skill (`ce-compound`) and its own criteria.
- Do not write to auto-memory (`~/.claude/projects/-Users-yourname-Desktop/memory/`). Auto-memory writes are in-session captures by the Chief of Staff, not synthesis-from-history.
- Do not create planning docs or summaries as a side effect.
- Do not push, commit, or deploy anything. Ever.
- Do not silently fall through on session-historian errors. A tool failure is BLOCKED, not "no load-bearing facts."
- Do not manufacture entries to fill the digest. Under-capture beats over-capture; an empty digest is a valid result.
- Do not double-write a fact across two categories. Cross-category facts route to the most specific home with a `links_to` cross-reference, never two appended entries.

## Reporting voice

Punch-list, no decoration, no emoji, no wrap-up paragraph. Match the format above. If something blocks, surface it as:

```
BLOCKED
  - <what blocked>
  - <what would unblock>
```

End the run when writes complete or when the operator says cancel. Do not propose a follow-up unless something genuinely needs one.
