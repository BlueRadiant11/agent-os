---
name: Claude Code (primary surface)
description: the operator's primary coding and chief-of-staff surface. Fable-era native capability map — what the harness does so the Agent OS doesn't rebuild it. Re-verify on every major harness or model upgrade.
type: reference
canonical: true
owner: chief-of-staff
last_verified: 2026-06-10
---

# Claude Code

Primary coding and chief-of-staff surface. Configured at `~/.claude/CLAUDE.md`. Model: `claude-fable-5[1m]` (Fable 5, 1M context) as of 2026-06-10. Two modes:

- **Interactive** — the operator at the keyboard. Talker, sparring partner, scribe, teacher.
- **Autonomous** — background dispatches, scheduled jobs, queued tasks.

**Standing rule (lesson 2026-06-10):** after any major Claude Code or model upgrade, re-verify this file and re-audit which homegrown mechanisms the harness now ships natively. The change protocol fires on self-edits only; the substrate changing underneath has no trigger — this file is the compensating control.

## Native capability map (what NOT to rebuild)

### Scheduling & recurrence
- **`CronCreate`** — harness-managed cron (local-time 5-field expressions). Jobs fire only while a session is idle; `durable: true` persists to `.claude/scheduled_tasks.json` across restarts. Recurring jobs auto-expire after ~7 days (durable reload semantics under observation — see `runners/active.md`). Replaced the launchd lane 2026-06-10.
- **`/schedule`** — cloud routines on Anthropic infra; run without the local machine but have no local filesystem and may lack interactively-authenticated MCP. Right for remote-only checks (GitHub/Vercel sweeps), wrong for memory-layer writes.
- **`ScheduleWakeup` / `/loop`** — self-paced recurring work inside a session.
- **`Monitor`** — event-driven watching (logs, processes); use instead of polling crons.

### Orchestration
- **`Agent` tool** — background runs with native completion notifications (no polling, no pad infra), `SendMessage` continuation of a previously spawned agent with context intact, per-dispatch `model` override, `isolation: "worktree"` for parallel file mutation.
- **`Workflow` tool** — deterministic multi-agent scripts (pipeline/parallel/fan-out) with hard agent caps (1000 lifetime, ~10 concurrent) and token budgets. Structurally runaway-proof: the safe shape for any future large fan-out. Explicit opt-in only ("use a workflow" / ultracode).
- **`TaskCreate` / `TaskUpdate` / `TaskList`** — persistent task tracking that survives context compaction. CLAUDE.md mandates for 3+-step work.

### Context & memory
- **Auto-memory** — `~/.claude/projects/<project-key>/memory/` with `MEMORY.md` index. **Keyed to the session's working directory**: a session in `~/Desktop/life-os/` has a different memory than one in `~/Desktop`. Repo-relevant rules must live in `~/personal-context/` (global SessionStart hooks load it in every project) or the repo's own CLAUDE.md — never only in auto-memory. Promotion sweep done 2026-06-10.
- **Native context management** — long conversations are summarized automatically; TaskCreate + canonical files are the durable state, not conversation memory.
- **`ToolSearch` / deferred tools** — MCP and harness tool schemas load on demand; large tool surfaces don't cost context until used.

### Review & verification
- **`/code-review`** (with `ultra` for multi-agent cloud review), **`/security-review`**, **`/simplify`**, **`/verify`** — native review surfaces; prefer over hand-rolled review dispatch when they fit.
- **`AskUserQuestion`** — structured decision prompts (used by `/build-interview`).
- **Fast mode** (`/fast`) — faster Opus output for interactive work; not a model downgrade.

## Personal context portfolio

`~/personal-context/` — portable across AI tools. Markdown-first, single-page rule (≤100 lines). Loaded by global SessionStart hooks in every project (8 hooks as of 2026-06-10; archindex + portfolio demoted to on-demand pointers).

## Known seams

- Native cron fires only with a session open — acceptable given daily sessions; `/morning` runs a CronList health check (added 2026-06-10).
- Cloud `/schedule` routines can't reach `~/personal-context/` — local-write jobs stay on local CronCreate.
- Auto-memory project-keying (above) — the sharpest trap; re-check when starting sessions from new directories.
