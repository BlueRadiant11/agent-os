# Agent OS

A personal operating system built on Claude Code. One chief-of-staff session that holds context across your whole operation, a roster of specialist sub-agents it dispatches to, a persistent file-based memory layer, and hooks that inject the right context at the right time.

This is a working system extracted from daily use, published as a fill-in-the-blanks template. The machinery is real; the person has been replaced with placeholders.

## What's inside

- `CLAUDE.md` — the chief-of-staff contract: identity, bright lines, two-gate approval model, dispatch rules, memory architecture. The front door.
- `agents/` — five built sub-agents: memory-agent (memory synthesis), defrag-agent (architecture audit, read-only by design), arch-implementer (applies defrag findings), agent-skill-creator (builds new skills/agents), coach-agent (weekly data-anchored coaching).
- `skills/` — the slash commands the system composes: `/morning` (daily brief), `/jot` (quick capture into memory), `/route-memory`, `/dedupe-memory`, `/coach`, `/dispatch-protocol`, `/build-pipeline`, `/build-interview`.
- `hooks/` — SessionStart hooks that auto-inject your identity and work-style files into every session, a keyword-driven context router (`context-router.py` + map), a single-page-rule enforcer for memory files, and an example bedtime lockout.
- `architecture/` — the system's self-documentation: agent registry, permission tiers, hook registry, memory schema, change protocol. `architecture/index.md` is the map.
- `personal-context/` — the memory layer scaffold. Empty by design; the system is only as good as what you put here.
- `commands/brief.md` — `/brief`, a git status dashboard across one repo or a whole directory of repos.
- `settings.json` — permission allowlist, hook wiring, and plugin config to adapt.

## Core ideas

- **Two-gate model.** The agent decides nothing that touches the world (Gate 1), and even after a "go," the actual push/send/spend needs approval again (Gate 2). Between the gates sits a pre-approved autonomy zone.
- **Memory vs context.** Memory is what's true (persistent files in `~/personal-context/`). Context is what's active (auto-injected or keyword-routed per session). `/jot` is the bridge.
- **Single-page rule.** Every memory file is ≤100 lines, one topic. Enforced by a hook, not by discipline.
- **Audit-fix loop.** defrag-agent (read-only) proposes findings; arch-implementer applies approved ones. The auditor can't edit; the editor can't decide.
- **Docs are the system's memory.** Architectural changes update the canonical docs in the same turn, following the change protocol in `architecture/index.md`.

## Install

1. Back up your existing `~/.claude` configuration.
2. Copy `CLAUDE.md`, `agents/`, `skills/`, `hooks/`, `commands/`, and `architecture/` into `~/.claude/`.
3. Copy `personal-context/` to `~/personal-context/`.
4. Merge what you want from `settings.json` into `~/.claude/settings.json` — at minimum the `hooks` block if you want the auto-injection. Review the permission allowlist before adopting it; it reflects one operator's risk tolerance.
5. Make the hooks executable: `chmod +x ~/.claude/hooks/*.sh`.
6. Fill in the blanks (below), then start a Claude Code session anywhere and say "morning".

Requirements: Claude Code, `jq` (used by the SessionStart hooks), Python 3 (context router). Optional: a Supabase project if you want the Life OS integration the morning/coach skills query — replace `YOUR_SUPABASE_PROJECT_ID` where it appears, or strip those sections. The skills reference two optional plugin ecosystems (compound-engineering, superpowers); the system degrades gracefully without them, but some skill compositions will no-op.

## Fill in the blanks

Search the repo for `FILL IN` — every site is marked. The load-bearing ones:

1. `personal-context/identity.md` — who you are. Injected into every session.
2. `personal-context/work-style/hard-rules.md` — your non-negotiables. Agents enforce what's written, not what's implied.
3. `personal-context/work-style/voice-canon.md` — how agents should sound.
4. `CLAUDE.md` § "Who I am" — your priority ranking and sacred windows.
5. `hooks/context-router-map.json` — your projects' keyword → context-file routes.

## A note on what this is not

This is one person's system, shaped by their constraints. The agents assume a solo operator with a day job, side projects, and a habit tracker. Fork the shape, not the life.
