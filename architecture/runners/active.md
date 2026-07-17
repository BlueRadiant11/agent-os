---
name: Active scheduled runners
description: Scheduled jobs in the Agent OS. As of 2026-06-10 — two weekly native CronCreate jobs (memory sweep, defrag audit). The launchd lane is retired; /morning Step 2.5 is the watchdog.
type: registry
canonical: true
owner: chief-of-staff
last_verified: 2026-06-10
---

# Active runners

**As of 2026-06-10: two weekly jobs on native CronCreate** (Claude Code's harness scheduler). The launchd lane (plists + runner shell scripts + idempotency lib + runners.conf) is retired — archived at `~/.claude/scripts/.archive-2026-06-10/`. Receipt: `~/personal-context/decisions/agent-os/2026-06-10-fable-fit-overhaul.md`. Prior incident post-mortem: `~/personal-context/decisions/agent-os/2026-05-04-cron-runaway-disabled.md`.

## The jobs

| Job | Schedule | What fires |
| --- | --- | --- |
| Weekly memory sweep | Sun ~18:11 | Prompt enqueues in the idle session → CoS background-dispatches memory-agent (7-day harvest, routine writes autonomous, deletions/CLAUDE.md/decision-log-edits gated to FINDINGS) → agent writes its handoff to `~/.claude/inbox/memory-agent-<ts>.md` |
| Weekly defrag audit | Wed ~18:14 | Prompt enqueues in the idle session → CoS background-dispatches defrag-agent (full meta-layer sweep + dependency-graph regen) → CoS writes the report (defrag has no Write tool) to `~/.claude/inbox/defrag-agent-<ts>.md`. Never auto-chains arch-implementer. |

Both jobs created with `durable: true`. Job prompts live inside the scheduler; this file is the registry mirror — recreate from the "Recreate the jobs" section below, not from memory.

## Honest reliability state (verify-don't-trust, 2026-06-10)

- Native cron jobs fire **only while a Claude Code session is open and idle**. Acceptable: the operator runs sessions most days (project window 6–8pm; both jobs are scheduled inside it).
- The CronCreate response reported "session-only / auto-expires after 7 days" even with `durable: true`; a scheduler lock (`~/Desktop/.claude/scheduled_tasks.lock`) was acquired but no `scheduled_tasks.json` had been flushed at creation time. **Durability across session restarts is UNVERIFIED.** Canary window: first two weeks (through ~2026-06-24).
- Watchdog: `/morning` Step 2.5 runs `CronList` on every brief and flags missing jobs in BLOCKED ON YOU. A dropped job costs at most one missed week, never a silent permanent failure.
- Fallback if the canary fails (jobs don't survive restarts): decide between recreating jobs at session start (deterministic, no dispatch — a notice/recreate, not a catchup-runaway) or reviving launchd as trigger-only. the operator decides; receipt required.

## Recreate the jobs

Use `CronCreate` with `durable: true`, `recurring: true`:

1. **Memory sweep** — cron `11 18 * * 0`. Prompt: dispatch memory-agent in background; 7-day harvest (sessions, claude-workspace, Life OS, GitHub); routine writes autonomous; gated items (deletions, CLAUDE.md edits, existing decision-log entries, push/send/spend) to FINDINGS; standardized handoff + 7 PHASE rows; agent writes `~/.claude/inbox/memory-agent-<ts>.md`; one-line notice to the operator after verifying the file landed.
2. **Defrag audit** — cron `14 18 * * 3`. Prompt: dispatch defrag-agent in background; full meta-layer sweep + dependency-graph regen; CoS writes the report to `~/.claude/inbox/defrag-agent-<ts>.md` (defrag is read-only); never auto-chain arch-implementer; CronList-check the sibling memory job; one-line notice.

## Why this can't repeat 2026-05-04

The runaway was a SessionStart hook that auto-dispatched "missed" runs reconstructed from filesystem stamps, firing inside the subprocesses it spawned. The native scheduler holds run state in the harness, fires each match once, never reconstructs missed runs from stamps, and no hook of ours touches scheduling. The recursion vector is structurally absent.

## Permission requirements (still in place)

`Write(~/.claude/inbox/**)` and `Edit(~/.claude/inbox/**)` remain in `settings.json` `allow` so inbox reports never block. In place since 2026-05-01.
