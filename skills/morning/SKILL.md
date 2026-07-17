---
name: morning
description: Read the inbox, harvest overnight signal from claude-workspace / GitHub / Life OS, and present the morning brief in the locked SHIPPED OVERNIGHT / BLOCKED ON YOU / QUEUED FOR TODAY / WHERE YOU'RE SLIPPING / NOTICED format. Use when the operator types "morning", "morning brief", "what's the brief", "what happened overnight", invokes `/morning` directly, or at the start of the first session of the day. Composes nothing. Read-only on every source except inbox archival. Auto-archives inbox after the digest renders (brief = acknowledgment).
argument-hint: "[past 48 hours | since friday | deep]"
---

# /morning

Read the inbox, harvest overnight signal, present the brief. Don't decide, don't write, don't editorialize. The digest is the first thing the operator reads — voice and format are load-bearing.

Locked format below; this skill is canonical for the morning brief format.

## Bright lines (do not cross)

- **No git commits, no pushes, no deploys.**
- **No MCP writes, no Supabase writes.** Read-only on every source.
- **Brief = acknowledgment.** Inbox auto-archives after the digest renders. Items needing follow-up are carried forward by the brief itself (BLOCKED ON YOU / QUEUED / WHERE YOU'RE SLIPPING / NOTICED). Anything not surfaced in the digest is on /morning, not on the archive step — fix the composition, not the gate.
- **No fabrication.** If a source is unreachable, name it in NOTICED. Don't fill the gap.
- **No `/jot`, `/route-memory`, `/dedupe-memory` invocation.** This skill stands alone.
- **No `--no-verify`, `--force`, no destructive shortcuts.** If something blocks, surface it.

## Step 1 — Time window

1. List `~/.claude/inbox/archive/` for the latest `YYYY-MM-DD/` directory. That date is `<window-start>`.
2. If no archive directory exists (first run): default `<window-start>` to 24 hours ago.
3. If the operator passed an argument (`/morning past 48 hours`, `/morning since friday`, `/morning deep`), use it. `deep` triggers Step 6 fallback.
4. Header line in the digest: `morning brief — <today>, window: <window>`.

The window applies to claude-workspace last-modified, GitHub activity, Life OS deltas. The inbox scan is unbounded — every unread file gets read regardless.

## Step 2 — Read the inbox

1. Glob `~/.claude/inbox/*.md`. Exclude `archive/` and `README.md`.
2. For each file:
   - Read end-to-end.
   - Extract `STATUS`, `ARTIFACTS`, `DECISIONS`, `FINDINGS`, `BLOCKERS`, `NEXT`.
   - Note the writing agent from filename (`<agent>-<timestamp>.md`).
   - Note file mtime.
3. Flag files with mtime > 7 days as **stale** — handle separately per Step 10 case 3.

## Step 2.5 — Cron health check (weekly sweeps)

The weekly sweeps run as native CronCreate jobs as of 2026-06-10 (memory-agent Sun ~18:11, defrag-agent Wed ~18:14 — registry: `~/.claude/architecture/runners/active.md`). The launchd log-file check this step used to perform is retired with the launchd lane. Native-cron durability across session restarts is under observation; this step is the watchdog that makes a dropped job cost one week, not a silent forever.

1. Run `CronList`. Expected: the weekly memory sweep (Sun 18:11) and the weekly defrag audit (Wed 18:14).
2. **Both present:** continue.
3. **Either missing** (session restart dropped it, or 7-day auto-expiry): surface in BLOCKED ON YOU as `weekly <name> cron missing — recreate per runners/active.md § "Recreate the jobs"`.
4. **Report overdue:** if the newest `~/.claude/inbox/memory-agent-*.md` (including archive) is older than 8 days, or the newest `defrag-agent-*.md` is older than 8 days, surface in NOTICED with the age — the job may exist but not be firing (laptop closed at fire time, no idle session).

This step costs one tool call and a glob. Do it on every run.

## Step 3 — GitHub deltas

For each repo (`/Users/yourname/Desktop/project-alpha`, `/Users/yourname/Desktop/life-os`):

1. `gh pr list --state open --search "updated:>=<window-start>" --json number,title,author,reviewDecision,createdAt,updatedAt` (open PRs **touched in window** only — don't surface week-old open PRs as overnight signal).
2. `gh pr list --state merged --search "merged:>=<window-start>"` (merged in window).
3. `git log --since="<window-start>" --pretty=format:"%h %s" origin/main` (recent commits).
4. `gh issue list --state open --search "updated:>=<window-start>"` (touched issues).

For author attribution: the operator's GitHub login is `BlueRadiant11` (per `~/personal-context/identity/personal-infrastructure.md`). Bots like `app/dependabot` are not the operator. Verify against `personal-infrastructure.md` rather than guessing from his name — `yourname` is NOT a GitHub username he uses.

If `gh` is denied or unavailable: note in NOTICED ("gh denied — recent commits not pulled"). Continue.

**Stale-open carve-out:** if a long-open PR is genuinely blocking (you're on the critical path waiting for review/merge of your own work, or it's been open >14 days and the user keeps seeing it), surface in NOTICED once with explicit age, not in BLOCKED ON YOU. Don't re-surface every morning unless `updatedAt` is in window.

## Step 4 — Life OS deltas

Supabase MCP, project `YOUR_SUPABASE_PROJECT_ID`, read-only.

**Read `~/.claude/architecture/tool-stack/life-os-schema.md` first.** That file holds the public-schema inventory + the four canonical queries below. Do not introspect `information_schema` on every run — the schema reference exists exactly to avoid that round-trip cost.

Run the canonical queries from `life-os-schema.md` § "Canonical queries — `/morning` Step 4":

1. Goals due ≤14 days out (incl. ≤3 overdue).
2. Mood entries since `<window-start>`.
3. Habits logged in window (counts `jsonb_array_elements_text(log)` since window-start).
4. Goal status changes since `<window-start>` (compare `done` flips via `created_at` if needed; not always available — surface only if observable).
5. Last night's sleep + 7-day median latency (the sleep protocol diagnostic — query and promotion rules in `life-os-schema.md` after the canonical queries section).

Plus the coaching queries from `life-os-schema.md` § "Coaching queries — `/morning` Step 4 (WHERE YOU'RE SLIPPING)":

6. Habits dropped — no log entry in 3+ consecutive days.
7. Goals slipping — deadline 4–7 days out (the 3-day band below this promotes to BLOCKED ON YOU per the rule below; queries 1 and 7 together cover ≤14 days without double-listing).

If a query fails with `relation does not exist` or `column does not exist`: the schema has drifted. Re-introspect, update `life-os-schema.md`, bump its `last_verified`, then continue. Do not silently rewrite the query against guessed table names.

If MCP unreachable: note in NOTICED. Continue.

**Promotion rule:** any goal with deadline <72h promotes to BLOCKED ON YOU as `decision needed: still shipping <goal>?`.

## Step 5 — claude-workspace activity

1. Glob `~/Desktop/claude-workspace/brainstorms/` and `/plans/`.
2. Filter mtime > `<window-start>`.
3. List filenames + one-line summary from each file's frontmatter `title:`.

These go in NOTICED.

## Step 6 — Optional fallback: session-historian

Skip by default. Run only if BOTH:

- Inbox has no memory-agent file from the current day.
- the operator's argument was `deep` or `full`.

If both: dispatch `compound-engineering:research:session-historian` with the time window, route load-bearing facts to the appropriate digest section.

Otherwise: skip. Memory-agent's cron already harvested sessions.

## Step 7 — Multi-source dedup

Build a fact list across all sources. Dedup keys:

- **Same commit SHA** in inbox finding + `gh log` → one bullet.
- **Same absolute file path** in inbox finding + claude-workspace → one bullet.
- **Same goal name** in Life OS delta + memory-agent finding → one bullet.

When merging: append `(via inbox + gh)` or similar at end of bullet.

When unsure if two facts are the same: surface twice. Mis-merge hides; over-surface is recoverable.

## Step 8 — Map to digest sections

First match wins:

| Source signal | Section |
| --- | --- |
| Inbox `STATUS: shipped` + `ARTIFACTS` | SHIPPED OVERNIGHT |
| Inbox `STATUS: partial` or `blocked` | BLOCKED ON YOU |
| Inbox `BLOCKERS` (any) | BLOCKED ON YOU |
| Inbox `NEXT` asking the operator to decide / approve | BLOCKED ON YOU |
| Inbox `FINDINGS` requiring the operator decision (canonical-conflict, deletion, gated edit) | BLOCKED ON YOU |
| Inbox `FINDINGS` informational (low/medium severity) | NOTICED |
| GitHub merged PR / commit overnight | SHIPPED OVERNIGHT |
| GitHub open PR awaiting the operator review | BLOCKED ON YOU |
| GitHub failing CI on default branch | BLOCKED ON YOU |
| GitHub touched issue | NOTICED |
| Life OS goal deadline <72h | BLOCKED ON YOU |
| Life OS goal status change | NOTICED |
| Life OS habit / mood deltas | NOTICED |
| Life OS habit dropped (no log in 3+ days) | WHERE YOU'RE SLIPPING |
| Life OS goal deadline 4–7 days (slipping band) | WHERE YOU'RE SLIPPING |
| Life OS last-night sleep record exists | NOTICED (one-liner: `sleep: <bedtime>, <total>, latency <m>` — drop bedtime if record is `manual`) |
| Life OS last-night latency > 7-day p50 + 10min | WHERE YOU'RE SLIPPING (coach push anchored to the sleep protocol — see voice examples) |
| Life OS no sleep record for last night | NOTICED (`sleep: no record for last night — ring not synced or not worn`) |
| claude-workspace brainstorm/plan modified | NOTICED |
| Source unreachable | NOTICED (name the source) |
| Pre-queued next-move from prior session (auto-memory `project` files, `/jot pending:` captures) | QUEUED FOR TODAY *(only if trigger condition is met today — see below)* |

QUEUED FOR TODAY is omitted entirely if nothing's queued. Don't manufacture a next-move.

**Trigger-condition gate (auto-memory `project_*` entries).** Each entry's body typically declares when it should resurface — phrases like "surface when next opening project-alpha", "remind me Monday morning", "after the next defrag run", "when settings.json next grows", etc. Before placing any auto-memory entry into QUEUED FOR TODAY:

1. Read the entry body.
2. Identify the trigger condition (look for "surface when X", "when next X", "after X", "before X", "until X", "once X").
3. Evaluate the condition against today's reality. Examples:
   - "surface when next opening project-alpha or life-os" → only queue if a project-alpha or life-os session is the current session
   - "remind at next /morning" → queue today
   - "surface after next defrag run" → queue if today's brief includes a fresh defrag inbox file
   - "drop after Permissions registry sync" → don't queue; this is a deletion gate, not a queue trigger (route to BLOCKED ON YOU as a deletion-confirm decision instead)
4. **If trigger met:** queue.
5. **If trigger not met:** skip silently. Do not surface old pending items just because they exist.
6. **If trigger ambiguous:** surface once in NOTICED with the entry path so the operator can clarify; don't auto-queue.

This gate exists to keep QUEUED FOR TODAY honest. An entry from days/weeks ago whose trigger isn't met today is noise, not signal.

## Step 9 — Render the digest

Exact format. Section headers are the locked ALL-CAPS exception.

```
morning brief — <today>, window: <window>

SHIPPED OVERNIGHT
  - <bullet>

BLOCKED ON YOU
  - decision needed: <bullet>
  - approval needed: <bullet>

QUEUED FOR TODAY
  - <bullet>

WHERE YOU'RE SLIPPING
  - <coach-push, one line per item>

NOTICED (FYI)
  - <bullet>
```

Rules:

- **Omit empty sections.** No "SHIPPED OVERNIGHT — none" filler.
- **One line per bullet.** If something needs two lines, split or move to its own section.
- **Front-load the noun.** "PR #47 in project-alpha awaiting your review" not "There is a PR awaiting review numbered 47."
- **Absolute paths** for file references.
- **No emoji, no em-dash spam, no bold-on-everything.**

**Voice for WHERE YOU'RE SLIPPING (deviates intentionally from the rest of the brief):** coach-push — dark humor, mischievous, anchored to a specific stake (exam study, training, sleep, project deadline). One push per item. Do not combine items into a single bullet. Do not use neutral reporting voice here — that's what the other sections are for.

Voice examples for the section:
- *Bedtime habit went dark Tuesday. The exam study grind doesn't get easier on 5 hours.*
- *Q3 portfolio review due Friday — three days, no progress. Ship or move the date.*
- *6am run hasn't happened since last Wednesday. Training afternoons earn themselves.*
- *Onset latency 27min last night, 12 above your 7-day median. The phone was in the room, wasn't it.*

Counter-examples (don't write like this):
- *Habit "Consistent Bedtime" — no log in 4 days.* (Neutral reporting; that's the rest of the brief.)
- *You've been slipping on bedtime. Maybe try harder?* (Therapy-speak / sycophancy.)
- *URGENT: Bedtime habit failure!!!* (AI-tell theatre.)

Omit the section entirely when nothing's slipping. Don't manufacture a coaching push to fill space.

## Step 10 — Empty-case shapes

Three distinct outputs. Don't collapse.

**Case 1 — nothing anywhere:**

```
morning: nothing in the inbox, no overnight activity.
```

End the run. Skip Step 11.

**Case 2 — inbox empty, other sources active:**

Render the digest with the sections that have content. No SHIPPED OVERNIGHT block (no agent reported it). If you ran the GitHub / Life OS scans, populate from those.

The "inbox: empty" NOTICED bullet is conditional on Step 2.5's classification:
- **Cron completed cleanly, no inbox file** → already routed to BLOCKED ON YOU as a wrapper failure; don't double-bullet under NOTICED.
- **Cron didn't fire** → already routed to BLOCKED ON YOU as a cron failure; don't double-bullet under NOTICED.
- **Cron in flight** → already noted under NOTICED as `cron in flight`; do NOT also write `inbox: empty` (it's not empty, it's pending).
- **No cron expected today** (Sundays off, or future schedule changes) → write `inbox: empty` under NOTICED.

**Case 3 — stale inbox items (>7 days):**

Surface in NOTICED (don't pause the brief) — the brief = acknowledgment rule means stale files get archived alongside fresh ones. But staleness is itself a signal the operator should see:

```
NOTICED (FYI)
  - <N> stale agent reports archived (>7 days old): <filenames + ages>
```

If the stale finding looks load-bearing (e.g., a defrag run that surfaced unfixed FINDINGS), promote it: surface its key finding in BLOCKED ON YOU before archiving so it doesn't get buried.

## Step 11 — Auto-archive

The digest IS the acknowledgment. Items needing follow-up have already been carried into BLOCKED ON YOU / QUEUED / WHERE YOU'RE SLIPPING / NOTICED. The original inbox files are now redundant.

After rendering the digest, archive the inbox files that were read:

```
mkdir -p ~/.claude/inbox/archive/<today>
mv <each file read in Step 2> ~/.claude/inbox/archive/<today>/
```

Re-glob the inbox before archiving — files may have landed between Step 2 and now. Archive only files that existed in the Step 2 read set; files that landed after the brief composed don't get archived (they'll be picked up next /morning).

After archiving, append a one-line footer:

```
archived <N> files to ~/.claude/inbox/archive/<today>/
```

If no inbox files were read (empty case 1): skip this step entirely. Don't print the footer.

**Carry-forward safety check.** If a finding from any inbox file does not appear anywhere in the digest, that's a /morning composition bug, not a reason to skip the archive. The fix is to surface the missed finding next session — the archive shouldn't gate around it. Truth above all: if you notice the miss while archiving, surface it in NOTICED before the footer ("composition gap: <file> finding <X> didn't make it into the brief — re-read this file from archive next session").

## Step 12 — Voice gate (self-check before output)

Scan the rendered digest for:

- Sycophantic openers (`Good morning!`, `Hope you slept well!`).
- Trailing pleasantries (`Have a great day!`, `Let me know if you need anything.`).
- AI vocabulary (`delve`, `leverage`, `robust`, `comprehensive`, `seamless`, `elegant`).
- Em-dash spam.
- Bold-on-everything.
- Wrap-up paragraph after NOTICED.
- Internal-deliberation narration (`I checked the inbox and found...`).
- Default tri-bullet — if a section has exactly 3 bullets, verify that's honest, not a tic.

If any present: rewrite. The voice is what's left after removing every AI tell.

## Failure modes to avoid

- **Pass-through of memory-agent's inbox file verbatim.** That's the standardized handoff format, not the morning brief format. Always compose.
- **Skipping the carry-forward audit before archive.** A finding that didn't make it into the digest gets archived anyway — but the gap must be named in NOTICED so the file gets re-read next session from archive. Silently archiving an un-surfaced finding is a memory loss.
- **Fabricating output when a source is denied.** Truth above all. Name the unreachable source in NOTICED.
- **Collapsing the three empty cases.** Each has its own one-liner.
- **Dropping section headers in non-empty cases.** The four labels are the locked frame.
- **Dispatching session-historian on every run.** Fallback only.
- **Invoking `/jot`, `/route-memory`, `/dedupe-memory` from inside `/morning`.** Skill stands alone.
- **Caching across runs.** If the operator runs `/morning` twice, the second run reads the inbox fresh.

## What this skill is not

- Not a memory writer. `/jot` and `/route-memory` capture facts; `/morning` reports.
- Not a drift fixer. Memory-agent owns content; `/morning` may surface drift in NOTICED if memory-agent flagged it, doesn't fix it.
- Not a weekly interpretive coach. Coach Agent (built 2026-05-07, invoked via `/coach` Sunday-evenings) handles weekly interpretive synthesis with WINS / EDGES / REFLECTION shape; `/morning` shows daily data with one coach-voiced section (WHERE YOU'RE SLIPPING) for the daily slap. The two surfaces are deliberately distinct: `/morning` bites with dark humor; Coach buttresses via DeMello-Robbins blend with sober-honesty register for protocol breaks.
- Not a CLAUDE.md editor.
- Not a session classifier. Session-historian classifies; `/morning` either consumes memory-agent's harvest or dispatches session-historian.

## Trust tier

Tier 2 (verification-required). Read-only on every source; the only mutating action is the post-render inbox archival, which executes automatically after the digest renders (per the brief-as-acknowledgment rule).
