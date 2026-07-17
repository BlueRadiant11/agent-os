---
name: jot
description: Quick-capture a thought, decision, insight, or correction and route it to the right memory file. Use when the operator types `/jot` (scan recent context for load-bearing facts), `/jot <thought>` (capture and classify a single thought), or `/jot <type>: <thought>` with type prefixes `decision`, `insight`, `fact`, `correction`, `lesson`, `pending`, `reference` (skip classification). Also use when the operator says "jot that down", "capture this", "remember this", "log that decision", "park this for later", or otherwise asks to save a thought into the memory system.
argument-hint: "[optional: a thought, or `<type>: <thought>`]"
---

# /jot

Quick-capture skill. the operator drops a thought; you classify it, propose where it lands, and write only after he confirms.

The routing rules are governed by `/Users/yourname/.claude/architecture/memory/`. **That file is the source of truth — when in doubt about where something goes, re-read it.** This skill encodes the same rules so you can act fast, but the architecture file wins on conflict.

## Modes

`/jot` is invoked in three shapes. Detect which one and follow the matching path.

### Mode 1 — Default (no args): scan recent context

Triggered by bare `/jot` with no argument.

1. Scan the recent conversation (this session, working back as far as is useful — typically the last 20–40 turns) for **load-bearing facts** that should persist beyond this session. Load-bearing means: a future Claude session would behave wrongly without knowing this.

   Look specifically for:
   - **Decisions** the operator made (life-level or per-domain)
   - **Identity-level facts** (a new role, relationship, milestone, value, constraint)
   - **Working-style insights** the operator validated ("yes, exactly," "do that going forward," or 3+ confirmations of the same pattern)
   - **Corrections** the operator gave you ("stop doing X", "always do Y instead")
   - **Project state changes** (new deadline, dropped commitment, priority shift, role change)
   - **Operational technical lessons** that match the four criteria in `~/Desktop/claude-workspace/context/compound-protocol.md` (surprising / costly / counterintuitive / would save future googling)
   - **Pending actions / deferrals** ("shelve this," "do this later," "remind me when…")
   - **External-system pointers** (the operator names a dashboard / channel / file as authoritative)

   Negative test: if a future session would still produce correct behavior without this fact (because it'll resurface naturally, or it's session-scoped chatter), it's not load-bearing — skip it.

2. Skip the chatter. Don't capture: hypotheticals, options being weighed, things still in debate, things already captured to memory in this session, or anything that's just session-scoped context.

3. If you find nothing worth capturing, say so in one line and stop. Don't manufacture entries.

4. If you find candidates, run **classification + dedup + proposal** (see "Required behavior" below) and present a batched approval.

### Mode 2 — Explicit (`/jot <thought>`)

Triggered by `/jot` followed by free text without a recognized type prefix.

1. Take the thought as written.
2. Classify it (see "Classification" below).
3. Run dedup check.
4. Present proposal.

### Mode 3 — Type-prefixed (`/jot <type>: <thought>`)

Triggered by `/jot` followed by a recognized type prefix and a colon. Recognized prefixes:

- `decision:` — a decision that landed
- `insight:` — a validated working-style insight
- `fact:` — an identity-level fact about the operator
- `correction:` — feedback the operator gave you
- `lesson:` — an operational technical lesson
- `pending:` — a pending action or deferral
- `reference:` — an external-system pointer

Skip classification. Use the prefix to pick the routing branch. Still run dedup, still present the proposal, still wait for confirmation before writing.

The prefix selects the bucket family; the proposal preview shows the absolute destination path so a mis-prefix surfaces before the write — the operator catches it at the confirm step.

## Composition

**Direct invocation.** the operator types `/jot` (any of the three modes) and the skill runs end-to-end with him in the loop for the proposal confirmation.

**Composed by memory-agent.** Memory-agent (`/Users/yourname/.claude/agents/memory-agent.md`, "Skills you compose" § `/jot`) calls this skill for in-session single-fact capture when a discrete fact needs to land *now*. The propose-before-write contract still holds — memory-agent surfaces the proposal upstream and waits for the operator's confirmation; it does not pre-execute even when called autonomously.

Load-bearing API surface: three modes (default scan / explicit thought / type-prefixed), propose-before-write, dedup pass, classification ladder, and `last_verified` hygiene. Callers depend on these — preserve them across changes.

## Classification

When the bucket is not pre-declared, classify by asking — silently — these questions in order. Stop at the first match.

1. **Is it a correction the operator just gave me about how to behave?** → auto-memory `feedback` file
2. **Is it a decision that landed?**
   - Touches identity, life arc, or shapes the operator's path → `~/personal-context/decision-log.md`
   - Concerns one active domain (Agent OS, Project Alpha, career) → `~/personal-context/decisions/<domain>.md`
3. **Is it a working-style insight the operator validated?** → `~/personal-context/how-i-work.md`
4. **Is it a new fact about who the operator is** (role, relationship, value, milestone, constraint)? → the matching file in `~/personal-context/`:
   - identity → `identity.md`
   - work / responsibilities → `identity/roles-and-time.md`
   - active workstream → `projects/<project>.md`
   - person → `identity/relationships-personal.md` or `identity/relationships-work.md` or `identity/relationships-family.md`
   - tool / system → `~/.claude/architecture/tool-stack/<area>.md`
   - voice rule → `work-style/voice-canon.md`
   - goal / priority → `goals/<topic>.md`
   - guardrail / constraint → `work-style/hard-rules.md` or `work-style/spending-and-preferences.md`
   - expertise area → `domain-knowledge/<area>.md`
5. **Is it an operational technical lesson** that meets the four criteria in `~/Desktop/claude-workspace/context/compound-protocol.md`? → recommend invoking `/ce:compound` rather than writing directly. `/ce:compound` writes to `docs/solutions/` (per its own spec); the lessons.md path was the older home and the protocol now routes through `/ce:compound`. If the operator wants a quick local jot instead, write to `~/Desktop/claude-workspace/context/lessons.md`.
6. **Is it an external-system pointer** ("X lives in Y")? → auto-memory `reference` file
7. **Is it a pending action or deferral?** → auto-memory `project` file
8. **Anything else?** Surface back to the operator: "I'm not sure where this goes — possible homes: A, B, C. Which?"

If a thought spans two buckets (e.g., a decision that also expresses a working-style insight), split it. One write per fact, each routed to its proper home.

## Required behavior in every mode

### Always show, never silent-write

For each fact you intend to capture, present a punch-list block before any write:

```
JOT — proposed captures

  1. <classification>: <one-line summary>
     destination: <absolute path>
     entry preview:
       <the exact text that will be written>

  2. ...

confirm? (y / edit / skip <n> / cancel)
```

Wait for explicit confirmation. Treat "y" as approval for all proposals in the batch. the operator can edit the text or skip individual items by number. Do not write before he says yes.

### Batch when multiple facts surface

One approval covers all the proposals in the batch. Don't loop through them one at a time — group them into a single punch list and ask once.

### Dedup before proposing

Before showing a proposal, search the target file for whatever's about to be captured. Use `Grep` (or `Read` if the file is short) on the destination file, then any plausibly-related siblings (e.g., for a decision, also check the other `decisions/<domain>.md` files; for an identity fact, check the obvious neighbors).

- **High textual / semantic similarity to an existing entry** → no-op, report "already captured at <path>" and skip that item.
- **Adjacent but different** → flag in the proposal: "similar entry exists at <path>, line <n> — capture as new entry, update existing, or skip?"
- **No match** → propose a fresh entry.

### File creation — frontmatter

When a target file doesn't exist yet, create it with the schema from `memory/`:

```yaml
---
name: <Human-readable name>
description: <one-line description for indexes>
type: identity | feedback | project | reference | decision-log | architecture | canon | process
canonical: true | false
owner: chief-of-staff
last_verified: YYYY-MM-DD
---
```

Optional fields when relevant: `domain`, `valid_until`, `links_to`, `originSessionId` (for in-session captures from sessions with a known ID).

For auto-memory files specifically (`~/.claude/projects/-Users-yourname-Desktop/memory/`), follow the existing convention there — `type: feedback | project | reference | user` and `originSessionId` when known. Filename pattern is `<type>_<short_slug>.md`. After creating a new auto-memory file, also append a one-line entry to `~/.claude/projects/-Users-yourname-Desktop/memory/MEMORY.md` matching the existing index format:

```
- [<Human name>](<filename>.md) — <short description>
```

For appending to existing files, match the file's existing format. Don't reformat or reorder existing entries.

### last_verified hygiene

When you append to an existing canonical file, update its `last_verified` field to today's date. When you create a new file, set `last_verified` to today.

## Routing — quick reference

| Bucket | Destination |
| --- | --- |
| Life-level decision | `/Users/yourname/personal-context/decision-log.md` |
| In-flight Agent OS decision | `/Users/yourname/personal-context/decisions/agent-os/` |
| In-flight Project Alpha decision | `/Users/yourname/personal-context/decisions/project-alpha.md` |
| In-flight career decision | `/Users/yourname/personal-context/decisions/career.md` |
| Validated working-style insight | `/Users/yourname/personal-context/how-i-work.md` |
| Correction the operator gave you | `/Users/yourname/.claude/projects/-Users-yourname-Desktop/memory/feedback_<slug>.md` (+ MEMORY.md index entry) |
| Identity / role / relationship / etc. | matching file in `/Users/yourname/personal-context/` (see classifier list) |
| Operational technical lesson | recommend `/ce:compound`; fallback `/Users/yourname/Desktop/claude-workspace/context/lessons.md` |
| External-system pointer | `/Users/yourname/.claude/projects/-Users-yourname-Desktop/memory/reference_<slug>.md` (+ MEMORY.md index entry) |
| Pending action / deferral | `/Users/yourname/.claude/projects/-Users-yourname-Desktop/memory/project_<slug>.md` (+ MEMORY.md index entry) |

If any of these paths look wrong on a future run, **re-read `memory/` first** before improvising — the architecture file is canon, this table is a mirror.

## Voice for written entries

Match the file's existing voice. Across the memory layer, that means:

- Blunt, direct, present tense
- No AI tells (no "delve," "leverage," "robust," "comprehensive," "seamless")
- No emoji
- Short — usually one to three sentences per entry
- Date-prefix entries in append-only logs (`decision-log.md`, `decisions/<domain>.md`) using `YYYY-MM-DD` to match the existing format in those files

When in doubt, read the last few entries in the destination file and mirror their shape.

## Failure modes to avoid

- **Silent write.** Never write before showing the proposal and getting explicit confirmation.
- **Capturing in-progress thinking.** If the operator is still weighing options, don't capture. Wait until something lands.
- **Manufacturing entries.** Mode 1 should under-capture, not over-capture. "Nothing worth jotting" is a valid result.
- **Writing into the wrong layer.** Decisions go in the identity portfolio, not auto-memory. Corrections go in auto-memory, not the identity portfolio. The architecture file makes this explicit; respect it.
- **Skipping dedup.** Always check before writing — drift is the enemy.
- **Touching CLAUDE.md.** This skill never writes to `~/.claude/CLAUDE.md`. Operating-contract changes go through the operator, not /jot.
- **Running in cron / autonomous mode.** `/jot` is synchronous-only. The proposal-before-write contract requires the operator in the loop. In autonomous / cron contexts, the right tool is `/route-memory`, not `/jot`.
- **Crossing the sandbox boundary.** No git push, no MCP writes, no spending, no sending. Only local file writes inside the memory layer.

## Output

Each invocation ends with a one-line summary of what landed where, or "nothing captured" if the operator cancelled or there was nothing to write. Default verbosity: terse. He can ask for the diff if he wants it.
