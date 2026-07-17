---
name: dedupe-memory
description: Sweep every memory and context file in the Agent OS for duplicates, superseded entries, and same-fact drift across files. Surface findings as a structured report and propose consolidations. Always human-gated -- never auto-edits, never auto-deletes. Use when the user says "dedupe memory", "clean memory", "audit memory", "find drift", or wants the memory layer reconciled against memory/ (single-page files).
---

# Dedupe Memory

You are running a cross-file dedup audit across the Agent OS memory layer. Your job is to read every in-scope file, detect duplicate / superseded / drifted information, and propose consolidations against the canonical-home rules in `memory/ (single-page files)`. the operator approves or rejects every finding. You never delete or edit before approval.

## Hard rules (load-bearing — do not violate)

1. **Report before edit, every time.** The pattern is: read all files in scope -> detect findings -> print full report -> wait for explicit approval -> only then execute approved edits. There is no "small enough to auto-apply" exception. Even a one-line removal goes through the gate.
2. **Approval must be explicit.** "Looks good" / "approved" / "go" / "yes do all of them" / "do 1, 3, 5" all count. Silence does not count. Ambiguous responses ("maybe", "I'll think about it") do not count -- ask again.
3. **Never guess at canonical home.** When `memory/ (single-page files)` doesn't unambiguously identify the canonical file for a fact, flag the conflict for the operator to resolve. Do not pick a winner.
4. **Preserve frontmatter on every edit.** Required fields: `name`, `description`, `type`, `canonical`, `owner`, `last_verified`. If a file is missing frontmatter, do not invent it -- flag the gap separately. If the file has frontmatter, update `last_verified` to today's date when you make any content edit.
5. **No git push, no MCP writes, no Supabase, no external sends.** This skill only edits local files in the in-scope directories. If a finding implies an action outside that scope, surface it as a recommendation in the report -- do not execute it.
6. **Truth above all.** If you partially completed an approved batch (e.g., 3 of 5 edits succeeded, 2 failed), say so explicitly. Do not claim work was done that wasn't.

## Files in scope

Read all of these every run. Do not narrow scope without the operator's explicit instruction.

- `/Users/yourname/personal-context/*.md` -- identity portfolio (top level)
- `/Users/yourname/personal-context/decisions/*.md` -- per-domain decision logs
- `/Users/yourname/.claude/projects/-Users-yourname-Desktop/memory/*.md` -- auto-memory layer
- `/Users/yourname/Desktop/claude-workspace/context/*.md` -- capture layer
- `/Users/yourname/Desktop/*/CLAUDE.md` -- project CLAUDE.md files (currently `project-alpha/CLAUDE.md` and `life-os/CLAUDE.md`)

Out of scope (do not touch):
- `/Users/yourname/.claude/CLAUDE.md` -- operating contract; above this skill's threshold; manual review only
- `/Users/yourname/Desktop/claude-workspace/brainstorms/`, `/Users/yourname/Desktop/claude-workspace/plans/` -- append-only capture
- Project source code (only the project CLAUDE.md is in scope, never src/, tests/, supabase/, etc.)
- Anything outside the five scoped patterns

### Project CLAUDE.md drift — special handling

Project CLAUDE.mds (`project-alpha/CLAUDE.md`, `life-os/CLAUDE.md`) duplicate the operator-level facts (cap table, contact info, role descriptions, project status framing) that are also stated canonically in the portfolio. They drift silently when the portfolio updates and the project CLAUDE.md doesn't — exactly the failure mode the audit (2026-05-01) flagged with the Project Alpha cap.

**Treat project CLAUDE.mds as mirrors when checking facts that overlap with the portfolio:**

- **the operator-level facts** (cap, contact, role descriptions, identity-flavored project framing): **portfolio canon wins.** Flag as `Drift` when the project CLAUDE.md disagrees with portfolio canon. Propose updating the project CLAUDE.md.
- **Project-specific operational facts** (build commands, repo quirks, env keys, internal file paths, dev workflow, deployment shape): **project CLAUDE.md canon wins.** Do NOT flag as drift even if absent from the portfolio — these are intentionally not in the portfolio.
- **Mixed / unclear** (e.g., a sentence stating both who built it AND a build command): flag as `Canonical-conflict` for the operator to resolve, do not pick a winner.

When in doubt, the question is: *"would a teammate cloning this repo without the operator's machine still need this fact?"* If yes → it's project-specific, project CLAUDE.md is canon. If no → it's the operator-level, portfolio is canon.

## Step 1: Load the spec and the files

1. Read `/Users/yourname/.claude/architecture/memory/ (single-page files)` end to end. This is the source of truth for canonical-home rules, the frontmatter schema, layer ownership, and cleaning rules. If this file cannot be read, stop and report -- the skill cannot run without the spec.
2. Glob each in-scope directory and read every `.md` file. For each file, capture: full path, frontmatter (if present), and content body.
3. Build an in-memory inventory keyed by file path with: `name`, `type`, `canonical`, `owner`, `last_verified`, and a list of distinct factual claims/entries the file makes. For long files (`identity.md`, `decision-log.md`, `projects/<project>.md`), break the body into entries by section heading or bullet block so dedup can work at entry granularity, not file granularity.

## Step 2: Detect findings

Run three passes over the inventory. A single fact may produce findings in more than one pass -- record each.

### Pass 1: Duplicates (same fact, two or more files)

A duplicate is the same factual claim appearing in two or more files. "Same" means semantically identical, not byte-identical -- "the operator plays training 5-6:30pm M-F" and "Training window: 5-6:30pm weekdays" are duplicates.

For each duplicate:
- Identify the canonical home using `memory/ (single-page files)`'s capture rules and frontmatter `canonical: true` declarations.
- If the canonical home is clear, propose: keep the entry in `<canonical>`, remove from `<mirror>`, optionally replace the mirror with a one-line reference (e.g., "See `<canonical>` for training window.") only if the mirror file would otherwise feel incomplete without the pointer. Default: just remove from the mirror.
- If the canonical home is unclear or both files claim canonical, flag as a `Canonical-conflict` finding instead of a `Duplicate` finding.

### Pass 2: Superseded (newer entry contradicts older entry)

A superseded entry is the same topic stated two ways, with one entry clearly newer. Signals of "newer":
- `last_verified` date in frontmatter is more recent
- Entry sits in a file with a more recent overall `last_verified`
- Content references events / dates / decisions that postdate the other entry
- Decision-log entries are dated -- newer date wins on the same topic

For each superseded pair:
- Propose: remove the old entry, keep the new entry. If the old entry is in a decision log, propose moving it to a struck-through state (decision logs preserve history; identity files don't).
- If "newer" is genuinely ambiguous (no dates, no clear signal), flag as `Drift` instead of `Superseded`.

### Pass 3: Drift (same fact stated differently across files)

Drift is the same fact stated in two or more files with materially different wording, where neither version is clearly newer or canonical. The danger is silent contradiction -- the two will diverge further over time.

For each drift case:
- Identify the canonical home (same logic as Pass 1).
- Propose: reconcile to the text in `<canonical>`. Update the non-canonical files to match.
- If canonical is unclear, flag as `Canonical-conflict`.

### Additional finding type: `Canonical-conflict`

When `canonical:` is missing, both files declare `canonical: true`, or `memory/ (single-page files)`'s capture rules don't unambiguously map the fact to a single home. Do not propose an edit. Surface the conflict to the operator with the relevant evidence and let him decide.

### Additional finding type: `Schema-gap`

When an in-scope file is missing required frontmatter fields. Do not propose content edits to such a file until the operator decides whether to migrate the schema. Surface separately.

## Step 3: Render the report

Print a single markdown report. Do not abbreviate. Group by finding type, then by severity (impact). Severity rubric:

- **High** -- canonical-home file disagrees with itself, or the duplicate is a load-bearing fact -- meaning a fact a future agent would behave wrongly without (same definition `/jot` uses for capture triggers; covers identity, decisions, priorities, deadlines)
- **Medium** -- mirrors of low-stakes facts, drift in non-canonical text
- **Low** -- formatting drift, near-identical phrasings of the same minor fact

Report format:

```
DEDUPE MEMORY -- AUDIT REPORT
=============================
Files scanned: N
Findings: D duplicates, S superseded, R drift, C canonical-conflicts, G schema-gaps
Spec read: /Users/yourname/.claude/architecture/memory/ (single-page files) (last_verified: <date>)

---

## Duplicates (D)

### [D1] [High] Fact: "Training window 5-6:30pm M-F"
- Appears in:
  - `/Users/yourname/personal-context/identity/roles-and-time.md` (line 42)
  - `/Users/yourname/.claude/CLAUDE.md` (line 18)  [out of scope -- noted only]
- Canonical home (per memory/ (single-page files)): `identity/roles-and-time.md` (identity portfolio, type: identity)
- Proposing: no action -- the CLAUDE.md mention is in the operating contract layer (out of scope). Flagged for visibility only.

### [D2] [Medium] Fact: "Project Alpha is the eventual primary project"
- Appears in:
  - `/Users/yourname/personal-context/projects/<project>.md` (line 12)
  - `/Users/yourname/personal-context/goals/<topic>.md` (line 8)
- Canonical home: `goals/<topic>.md` (priority ranking lives here per memory/ (single-page files) "capture rules > project state changes")
- Proposing: remove from `projects/<project>.md` (mirror); keep in `goals/<topic>.md`.

---

## Superseded (S)

### [S1] [High] Topic: "Project Alpha customer count"
- Old: `/Users/yourname/personal-context/projects/<project>.md` line 28: "47 customers"  (last_verified: 2026-03-15)
- New: `/Users/yourname/.claude/projects/-Users-yourname-Desktop/memory/project_alpha.md` line 4: "42 customers"  (last_verified: 2026-04-22)
- Proposing: remove old entry from `projects/<project>.md`; replace with current count synced from auto-memory entry, OR remove the count from `projects/<project>.md` entirely and reference auto-memory as source of truth.

---

## Drift (R)

### [R1] [Medium] Fact: "the operator's morning study window"
- File A: `identity/roles-and-time.md` -- "7-9am M-F, exam study, sacred"
- File B: `goals/<topic>.md` -- "morning hours dedicated to exam study prep"
- Canonical home: `identity/roles-and-time.md` (rhythm lives here)
- Proposing: update File B to reference File A's exact wording, or remove the redundant phrase from File B.

---

## Canonical-conflicts (C)

### [C1] Fact: "Agent OS is the current hot project"
- Appears in:
  - `/Users/yourname/personal-context/projects/<project>.md` (declares canonical: true)
  - `/Users/yourname/personal-context/goals/<topic>.md` (declares canonical: true)
- memory/ (single-page files) is ambiguous -- "projects/<project>.md" is named for active workstreams; "goals/<topic>.md" owns priority ranking. The fact "Agent OS is hot" is both.
- No proposal -- needs your decision: which file owns priority/hotness ranking?

---

## Schema-gaps (G)

### [G1] `/Users/yourname/Desktop/claude-workspace/context/lessons.md`
- Missing required frontmatter: `name`, `type`, `canonical`, `owner`, `last_verified`
- Per memory/ (single-page files), capture-layer files do require the schema (they're in layers 1-4).
- No proposal -- needs your decision: migrate now, or defer to Memory Agent build.

---

## Approval gate

Reply with one of:
- "approve all" -- I'll execute every proposal in order
- "approve <ids>" -- e.g., "approve D1, S1, R1" -- selective
- "reject <ids>" + reason -- I'll skip and note
- "amend <id>: <new instruction>" -- I'll re-propose
- "stop" -- abort run, no edits

Canonical-conflicts (C*) and schema-gaps (G*) require your direct decision -- I won't execute these without specific instructions on how to resolve.
```

## Step 4: Wait for approval

After printing the report, stop and wait. Do not start editing. Do not print "executing now" or any forward-looking commitment until the operator replies with explicit approval.

When the operator replies, parse:
- Approval list (which IDs to execute)
- Rejections (which IDs to skip + reasons -- preserve in the run summary)
- Amendments (re-propose with the new framing, then wait for approval again on the amended item)
- Resolutions for canonical-conflicts and schema-gaps (his explicit decision becomes the proposal, then it executes)

If the reply is unclear, ask one targeted question. Do not execute on a guess.

If the reply approves an ID that isn't in the report (typo, hallucinated ID), or approves an ID that was already rejected earlier in the same response, ask once before proceeding. Do not silently skip; do not silently substitute a similar ID.

## Step 5: Execute approved edits

For each approved finding, in the order the operator listed them:

1. Re-read the target file fresh (it may have changed since Step 1 if the operator was active).
2. **Spec-currency check.** If `memory/ (single-page files)`'s `last_verified` is newer than your last read at Step 1, re-read the spec before this edit. The spec wins on conflict -- never proceed with a stale spec.
3. Apply the edit using the file-editing tool. One edit per tool call -- do not batch edits across files.
4. If the file has frontmatter, bump `last_verified` to today's date (YYYY-MM-DD).
5. Verify the edit landed by re-reading the relevant section of the file.
6. If the edit fails (file changed, conflict, permission issue): stop the batch, report the failure with the exact error, and ask the operator how to proceed. Do not silently skip.

Never:
- Delete an entire file. The skill removes entries; whole-file deletion requires a separate explicit instruction.
- Edit the frontmatter `canonical` field. That's a higher-level decision that needs explicit approval, not a side effect of dedup.
- Touch files outside the scoped directories.
- Use git commands. The skill does not commit, push, or stage. the operator commits manually if he wants to.

## Step 6: Run summary

After all approved edits land (or the batch is interrupted), print a punch list:

```
DEDUPE RUN COMPLETE

EXECUTED
  - [D2] removed Project Alpha line from projects/<project>.md
  - [S1] updated customer count reference in projects/<project>.md

REJECTED (per your call)
  - [R1] -- you wanted to keep both wordings

PARKED FOR YOU
  - [C1] canonical conflict -- still open
  - [G1] schema gap on lessons.md -- still open

FAILED
  - none

FILES TOUCHED
  - /Users/yourname/personal-context/projects/<project>.md
```

Do not summarize the diffs themselves. the operator reads the diff if he wants to verify.

## Operating notes

- **Conservative bias.** When in doubt between "this is a duplicate" and "these are two distinct facts that look similar", classify as drift and let the operator decide. False merges are worse than false negatives.
- **Don't churn.** If a fact appears in canonical form in one file and a paraphrased mention in another file is genuinely useful contextual scaffolding (not a fact-mirror), leave it. Dedup is for fact-level redundancy, not prose echo.
- **Don't summarize the spec back to the operator.** He wrote it. Reference it (`per memory/ (single-page files) > capture rules > decisions`), don't restate it.
- **Voice rules apply.** Punch-list reports, no AI tells, no decorative emoji, no "let me know if you need anything else." See `~/.claude/CLAUDE.md` for the full list.

## What this skill is not

- Not a TTL sweeper (that's a future `refresh-memory` skill or the Memory Agent's `last_verified > 90 days` flag).
- Not a capture router (that's `route-memory`).
- Not a writer (that's the agent that captures live).
- Not the Memory Agent. The Memory Agent will eventually orchestrate dedupe, refresh, synthesis, and indexing on a daily cron. This skill is the manual, on-demand, human-gated dedupe pass that the Memory Agent will internalize when built.

## Composition contract

Memory-agent invokes this skill on health-check triggers and parses its output to drive its autonomous carve-out logic. The contract:

- This skill is **uniformly propose-before-edit**. It never auto-applies, regardless of caller. Memory-agent decides what to apply autonomously *after* the report returns; the skill never short-circuits that decision.
- The parse anchors are load-bearing. Memory-agent reads:
  - The header (`DEDUPE MEMORY -- AUDIT REPORT`)
  - The finding ID convention (`D1`, `S1`, `R1`, `C1`, `G1` -- letter + sequence, zero-padding optional)
  - The severity tags (`[High|Medium|Low]`)
  - The approval grammar (`approve all` / `approve <ids>` / `reject <ids>` / `amend <id>:` / `stop`)
- Don't change the report shape, finding-ID convention, severity tag set, or approval grammar without a coordinated update to `memory-agent.md`. The propose-before-edit posture is memory-agent's safety dependency, not a stylistic choice.
