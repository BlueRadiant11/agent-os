---
name: Agent dispatch quick reference
description: Task-to-agent routing table for Chief of Staff. When the operator asks X, dispatch to Y.
type: reference
canonical: true
owner: chief-of-staff
last_verified: 2026-05-19
---

# When to dispatch which agent

**Default dispatch path (2026-05-19, lightweight sentinel-only):** Chief of Staff composes `/bridge-dispatch` for every `Agent` tool call. The dispatch is a single tool call: `Agent(prompt="BRIDGE_PAD_PATH: inline\n\n<task>", ...)`. No pad infrastructure, no briefing.md, no return.md polling. Foreground responses return via the Agent tool wrapper; background responses (`run_in_background=true`) surface via Claude Code's native completion notification. Raw `Agent` calls are blocked at the tool layer by `pre-tool-use-bridge-only.sh` (PreToolUse:Agent matcher) — no carve-outs for triviality, general-purpose, Explore, or one-shot research. See `~/.claude/skills/bridge-dispatch/SKILL.md` § Scope (load-bearing). Sub-agents resolve design questions via the fallback hierarchy (`~/personal-context/` direct → inference → agent's own judgment as FINDING) per `~/.claude/architecture/agents/bridge-protocol.md` Item 3.

| Task / question | Dispatch to |
| --- | --- |
| "Where does this fact go?" | memory-agent |
| "Synthesize what happened today" | memory-agent (composes `/route-memory`) |
| "Find duplicate / stale memories" | memory-agent (composes `/dedupe-memory`) |
| "Build a new skill / agent" | agent-skill-creator (with crisp spec) |
| "Where am I lacking on habits / goals?" / "coach me" / weekly Sunday check-in | coach-agent (via `/coach`) |
| "Audit the Agent OS architecture for drift" | defrag-agent |
| "Apply the architecture fixes I just approved" | arch-implementer (takes defrag report + approved IDs) |
| "Help me write this email / message" | communication-agent (when built) — for now CoS drafts inline |
| Project-specific work in Project Alpha / Life OS | open the project repo (project CLAUDE.md applies); project-agents not yet needed |
| Multi-project / multi-task ask | Chief of Staff splits into per-agent dispatches in parallel |
