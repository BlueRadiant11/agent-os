---
name: Scheduled runners — Mac launchd
description: Local cron framework architecture. Plist + shell + log convention. Why local launchd vs. cloud cron.
type: reference
canonical: true
owner: chief-of-staff
last_verified: 2026-06-10
---

# Scheduled runners — Mac launchd

Local cron framework for firing Agent OS work on a schedule. Built 2026-05-01. **RETIRED 2026-06-10** — dormant since the 2026-05-04 catchup-hook runaway (post-mortem: `~/personal-context/decisions/agent-os/2026-05-04-cron-runaway-disabled.md`), then replaced by native CronCreate scheduling in the Fable-fit overhaul (`~/personal-context/decisions/agent-os/2026-06-10-fable-fit-overhaul.md`). Runner scripts archived at `~/.claude/scripts/.archive-2026-06-10/`. This file stays as historical reference for the launchd mechanism in case the fallback (trigger-only launchd) is ever needed; `runners/active.md` is the live registry.

## Architecture

- **LaunchAgent plists** at `~/Library/LaunchAgents/com.yourname.<runner>.plist` — define the schedule.
- **Runner shell scripts** at `~/.claude/scripts/<runner>.sh` — invoke `claude -p` non-interactively with a self-contained prompt.
- **Logs** at `~/.claude/scripts/logs/` — per-day per-runner plus launchd's stdout/stderr.
- **Output destination:** `~/.claude/inbox/<agent>-<ISO-timestamp>.md` (CoS reads at session start).
- **Conventions doc** at `~/.claude/scripts/README.md`.

## Why local launchd vs. cloud cron

Runners need access to local files (`~/personal-context/`, `~/.claude/`, `~/Desktop/`). Cloud runners (Cloudflare / Vercel / Zapier) can't see those.

**Constraint and catch-up (historical, see incident below):** launchd `StartCalendarInterval` only fires when the laptop is awake at the scheduled clock time. **macOS does NOT catch up missed `StartCalendarInterval` runs on wake** — silent skip. Plan 004 (2026-05-03) layered a SessionStart catch-up hook on top to handle missed fires. That design fanned out: 3,060 dispatches in ~5 hours on 2026-05-04 because stamp-after-success + fire-and-forget background dispatch is not real idempotency. Both crons + the catch-up hook were removed 2026-05-04. The full post-mortem and what would have to change to bring crons back lives in `~/personal-context/decisions/agent-os/2026-05-04-cron-runaway-disabled.md`. The idempotency helper at `~/.claude/scripts/lib/idempotency.sh` is preserved but **insufficient on its own** for safe scheduling — the next attempt needs lock-on-entry, PID validation, hook coalescing, and a cascade test.

## Cron-mode `claude -p` requires explicit `--add-dir`

Non-interactive `claude -p` runs in a tighter sandbox than interactive. By default reads `~/Desktop/` but NOT `~/personal-context/`, `~/.claude/projects/`, `~/.claude/agents/`. Without widening, agents return `STATUS: partial`.

Pass `--add-dir` with directories the agent needs. **Critical:** `--add-dir` is variadic — multiple space-separated dirs in a single flag, then `--` before the prompt:

```
claude -p \
  --add-dir DIR1 DIR2 DIR3 \
  -- "prompt"
```

(Multiple `--add-dir` in a row each taking one dir consumes the prompt as a directory.)

`Write` tool calls hit a permission gate even when the destination path is in settings.json `allow`. Cleanest fix: runner shell captures stdout, writes the artifact via `mv` not Claude's Write tool. Bypasses the gate.

What `--add-dir` does NOT cover: `Bash`, `git`, `gh`, MCP tools. Those need separate allow rules in settings.json or `--allowedTools`.

Lesson source: `~/Desktop/claude-workspace/context/lessons.md` (2026-05-01 entry).
