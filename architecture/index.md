---
name: agent-os-architecture
description: Top-level index of where the Agent OS architecture lives — canonical homes + cross-cutting rules. First file to read on any architecture question.
type: reference
canonical: yes
owner: operator
last_verified: 2026-05-17
---

# Agent OS — architecture index

The map. Read first when an architecture question lands, when defrag-agent / arch-implementer starts a run, or when CoS dispatches meta-layer work.

This file is an **index, not a duplicate**. Each row points at the canonical file. Linked file wins on disagreement.

## Canonical homes

### Operating contract
- `~/.claude/CLAUDE.md` — CoS persona, two-mode contract, invocation paths, two-gate model, dispatch policy, bright lines, voice anchor.

### Agents
- `~/.claude/architecture/agents/` — agent canon (roster, invocation paths, boundaries, dispatch quick reference, maintenance).
- `~/.claude/architecture/agents/bridge-protocol.md` — canonical Bridge protocol (universal items 0–8). Added 2026-05-17.
- `~/.claude/agents/*.md` — agent body files (each inherits the Bridge protocol section).
- `~/Desktop/claude-workspace/dispatch-pads/` — file-based dispatch channel (staging/ → active/ → archive/). **Runtime working directory, not a canonical knowledge home:** the pad-anatomy convention is defined in `~/.claude/architecture/agents/bridge-protocol.md` and the `dispatch-pads/README.md` describes layout for human readers; neither has its own dep-graph subsection because the upstream canonical entry covers it. Added 2026-05-17.

### Skills & commands
- `~/.claude/skills/*/SKILL.md` — skill bodies.
- `~/.claude/commands/*.md` — slash commands (reserved).

### Permissions & hooks
- `~/.claude/settings.json` — runtime config. **What enforces.** Registry mirrors this, never the reverse.
- `~/.claude/architecture/permissions/` — registry mirror + evolution protocol + pre-approved task categories.
- `~/.claude/architecture/hooks/` — hook registry + build rules.
- `~/.claude/hooks/*.sh` — hook script bodies.

### Memory layer
- `~/.claude/architecture/memory/` — layer model, schema, capture rules, cleaning rules, agent charter.
- `~/personal-context/decision-log.md` — life-level decisions.
- `~/personal-context/decisions/<domain>.md` — in-flight per-domain decisions.
- `~/.claude/projects/-Users-yourname-Desktop/memory/` — auto-memory.

### Voice
- `~/personal-context/work-style/voice-canon.md` — banned vocabulary, format rules, full voice anchor.

### Build pipeline
- `~/Desktop/claude-workspace/brainstorms/` — required for non-trivial builds.
- `~/Desktop/claude-workspace/plans/` — required plan artifact.
- `~/Desktop/claude-workspace/context/lessons.md` — cross-project operational lessons.

### Operational runners
- `~/.claude/scripts/*` — runner scripts (manual on-demand only as of 2026-05-04 — see `decisions/agent-os/2026-05-04-cron-runaway-disabled.md`).
- `~/.claude/architecture/runners/` — schedule registry + (when re-enabled) activation flow. Currently dormant.
- `~/Library/LaunchAgents/com.yourname.*.plist` — launchd schedules. **Currently empty** — both prior plists unloaded 2026-05-04.
- `~/.claude/inbox/<agent>-<timestamp>.md` — async report drop-box (still used for manual on-demand runs).

### Shelf & projects
- `~/personal-context/shelf.md` — explicitly paused items.
- `~/personal-context/projects/` — per-project active state.

## Cross-cutting rules

| Rule | Canon source | Enforcement |
| --- | --- | --- |
| **Single-page rule** (every `~/personal-context/` file ≤100 lines, single-topic, zero exceptions) | `memory/schema.md` § "Single-page rule" | Defrag-agent registry-category finding; arch-implementer splits per agent-native filing scheme |
| Source-of-truth (registry mirrors `settings.json`) | `permissions/evolution-protocol.md` | `~/.claude/hooks/settings-mirror-reminder.sh` |
| Architecture vs content seam (defrag vs memory-agent) | `agents/boundaries.md` | Behavioral — both agents re-read at run start |
| Two-gate model (decide → ship) | `CLAUDE.md` § "Two-gate model" | Behavioral |
| Invocation-path model (Operator-directed / Autonomous) + per-agent carve-outs | `CLAUDE.md` § "Invocation paths" + `agents/invocation-paths.md` + per-agent frontmatter | Behavioral |
| Killed agents: remove, don't tombstone | `CLAUDE.md` § "Sub-agent roster" | `agents/built.md` + `agents/aspirational.md` stay cleaned; receipts in `decisions/agent-os/` |
| Canonical-winner rule (surface conflicts, never pick) | `agents/boundaries.md` + `memory/schema.md` | Defrag flags as `registry` finding |
| Build-pipeline conformance (brainstorm + plan required) | `skills/build-pipeline/SKILL.md` | Defrag scope #6 |
| Voice canon | `work-style/voice-canon.md` | Defrag scope #3 |

## Change protocol — when changing any canonical home

Every architectural change goes through these steps. **Applies to any canonical home — including `~/.claude/CLAUDE.md` itself, the operating contract.** Encoded as a rule in `CLAUDE.md` § "How I work" and as a defrag-agent scope. The protocol is what makes the index *active enforcement* of cross-reference coherence rather than a passive map.

1. **Identify the surface.** Which canonical home is changing.
2. **Consult the dependency graph below.** It lists every inbound dependent for each canonical home — files that reference the surface and may go stale.
3. **Edit the canonical home.** Apply the change.
4. **Update each inbound dependent listed in the graph.** Don't skip any. If the graph is missing an inbound dependent that grep would find, that's a graph-staleness finding for defrag.
5. **Dispatch defrag-agent to verify and regenerate the graph.** Defrag's scope #2 (registry consistency) regrenerates the graph by walking every canonical home and grepping for inbound references.
6. **Apply approved findings via arch-implementer** if defrag surfaces drift.
7. **Bump `last_verified`** on every canonical file you edited.

## Dependency graph

For each canonical home, the inbound dependents — files that reference it. Auto-maintained by defrag-agent on each run; the snapshot below was last regenerated on the date in this file's frontmatter `last_verified`.

When the graph and reality disagree, reality wins (defrag regenerates from grep). The graph is a cache.

### Operating contract — `~/.claude/CLAUDE.md`

- Inbound: every agent body, every skill, hooks, `~/.claude/scripts/{memory-agent-daily,defrag-agent-weekly}.sh` (runner-prompt bright-line citations). Highest-sensitivity surface.
- Edit gate: arch-implementer requires per-finding-ID approval; blanket category approval does not cover.

### Agent canon — `~/.claude/architecture/agents/{built,aspirational,invocation-paths,dispatch,boundaries,maintenance,chief-of-staff}.md`

- `built.md`: CLAUDE.md (sub-agent roster), `agents/dispatch.md`.
- `invocation-paths.md`: CLAUDE.md (Invocation paths section), `agents/memory-agent.md` (path citation).
- `boundaries.md`: `agents/defrag-agent.md`, `agents/arch-implementer.md`, `agents/memory-agent.md`, `~/.claude/scripts/defrag-agent-weekly.sh` (cron-prompt seam-test citation).
- `dispatch.md`: CLAUDE.md (procedure references), `skills/dispatch-protocol`.
- maintenance.md: no inbound dependents (internal reference doc).
- chief-of-staff.md: no inbound dependents (apex agent, no dispatch chain points at it).
- `coach-agent.md` (built 2026-05-07): CLAUDE.md (sub-agent roster), `agents/dispatch.md`, `agents/invocation-paths.md`.

### Agent bridge — `~/.claude/architecture/agents/bridge-protocol.md`

- Inbound: `~/.claude/agents/memory-agent.md`, `~/.claude/agents/defrag-agent.md`, `~/.claude/agents/arch-implementer.md`, `~/.claude/agents/agent-skill-creator.md`, `~/.claude/agents/coach-agent.md` (all five inherit the universal Bridge protocol section — revised 2026-05-17 by the interview-first pivot: items 4 + 5 removed, item 3 rewritten as fallback hierarchy); `~/.claude/architecture/agents/built.md` (universal-protocol note); `~/.claude/architecture/agents/dispatch.md` (default-dispatch-path note); `~/.claude/architecture/hooks/registry.md` (cross-references both bridge hooks); `~/.claude/skills/dispatch-protocol/SKILL.md` (default-path note); `~/.claude/skills/bridge-dispatch/SKILL.md` (full reference); `~/.claude/skills/build-interview/SKILL.md` (Step 0 of `/build-pipeline`; populates the `interview:` block Item 3 consults first); `~/.claude/skills/build-pipeline/SKILL.md` (Step 0 entry); `~/.claude/CLAUDE.md` (Sub-agent roster note); `~/Desktop/claude-workspace/dispatch-pads/README.md`. Added 2026-05-17 as Unit 1 of the agent-bridge build; revised 2026-05-17 by the interview-first pivot (`~/Desktop/claude-workspace/plans/2026-05-17-001-feat-interview-first-pivot-plan.md`).

### Memory canon — `~/.claude/architecture/memory/{schema,overview,capture-rules,cleaning-rules,categories,agent-charter,persisted-output-failsafe}.md`

- `schema.md`: CLAUDE.md (memory vs context), `agents/memory-agent.md`, `agents/arch-implementer.md`, `skills/jot`, `skills/dedupe-memory`, `hooks/single-page-rule.sh` (rule citation).
- `capture-rules.md`: CLAUDE.md (procedure references), `skills/jot`, `skills/route-memory`, `skills/dedupe-memory`.
- `agent-charter.md`: `agents/memory-agent.md` (charter source — phased loop locked 2026-05-12), `~/.claude/scripts/memory-agent-daily.sh` (cron-prompt charter pointer), `hooks/memory-agent-handoff-check.sh` (enforces phased loop).
- `cleaning-rules.md`: `agents/memory-agent.md` (Phase 3 TTL rules, Phase 5 orphan + pairwise-consistency rules), `skills/dedupe-memory`.
- `persisted-output-failsafe.md`: CLAUDE.md § "Memory vs context" (pointer). New 2026-05-03 — extracted from inline CLAUDE.md prose during the coherence pass (Unit 8); documents the chunk-read fallback for when a SessionStart hook overflows the inline budget.

### Permissions canon — `~/.claude/architecture/permissions/{allow,deny,ask,evolution-protocol,pre-approved-categories}.md`

- `allow.md` / `deny.md` / `ask.md`: `~/.claude/settings.json` (canonical source — these mirror it).
- `evolution-protocol.md`: CLAUDE.md (procedure references), `hooks/settings-mirror-reminder.sh` (rule citation in additionalContext).
- `pre-approved-categories.md`: CLAUDE.md § "How I work / Predict-and-ask" (rule citation). New 2026-05-03 to resolve the predict-and-ask vs permission-fatigue deadlock.

### Hooks canon — `~/.claude/architecture/hooks/{registry,build-rules}.md`

- `registry.md`: `~/.claude/settings.json` (canonical source — mirrors the `hooks` block), CLAUDE.md (procedure references), `agents/arch-implementer.md` (HK Pass B build target).
- `build-rules.md`: `agents/defrag-agent.md` (Pass B trigger criteria), `agents/arch-implementer.md` (Hook construction step 9 citation), `CLAUDE.md` (How I work § "Evaluate hook necessity during feature work" rule, 2026-05-12), `~/.claude/skills/build-pipeline/SKILL.md` (Hook-evaluation waypoint citations, 2026-05-12).
- `bedtime-lockout.sh`: `~/.claude/settings.json` (hook entry), plus whichever personal-context goal file defines the protocol it enforces.
- `memory-agent-handoff-check.sh` (added 2026-05-12): `~/.claude/settings.json` (PostToolUse hook entry, matcher `Agent`), `~/.claude/agents/memory-agent.md` (enforces phased operating loop), `~/.claude/architecture/memory/agent-charter.md` (codifies phased loop), `~/personal-context/decisions/agent-os/2026-05-12-memory-agent-phased-loop.md`. BRIDGE_MODE response gate added 2026-05-17 (skips PHASE-row check for bridge-mode dispatches).
- `bridge-surface.py` (added 2026-05-17, simplified 2026-05-17 by the interview-first pivot — SessionStart branch + pending-questions detection removed): `~/.claude/settings.json` (UserPromptSubmit chain entry after context-router; SessionStart chain entry was removed), `~/.claude/architecture/agents/bridge-protocol.md` (canonical reference), `~/Desktop/claude-workspace/dispatch-pads/` (read target for the polling logic). Notice-only polling hook; mirrors `cron-catchup-notice.sh` recursion-proof posture per cron-runaway 2026-05-04 lesson. Now does completion + hang detection only.
- `bridge-protocol-check.sh` (added 2026-05-17, simplified 2026-05-17 by the interview-first pivot — dropped questions.md fallback): `~/.claude/settings.json` (PostToolUse:Agent matcher, ordered FIRST in the chain before memory-agent-handoff-check.sh), `~/.claude/architecture/agents/bridge-protocol.md` (validates Item 6 compliance), `~/Desktop/claude-workspace/dispatch-pads/active/{pad-id}/` (read target — checks for return.md presence on BRIDGE_MODE responses; return.md is the only legal completion artifact post-pivot).

### Tool stack canon — `~/.claude/architecture/tool-stack/{custom-skills,ce-skills-curated,life-os-schema,claude-code,compound-engineering,mcp}.md`

- custom-skills.md: CLAUDE.md (procedure references — pitched-skills bench).
- ce-skills-curated.md: CLAUDE.md (procedure references — reach-for CE skills delegation).
- life-os-schema.md: `~/.claude/skills/morning/SKILL.md` Step 4 (canonical Supabase queries + table inventory). Future inbound: `/brief`, life-os Project Agent.
- claude-code.md: no inbound dependents (standalone reference for the primary surface).
- compound-engineering.md: no inbound dependents (standalone reference for the plugin + workspace role).
- mcp.md: no inbound dependents (standalone reference for connected MCP servers).

### Voice canon — `~/personal-context/work-style/voice-canon.md`

- Inbound: CLAUDE.md (banned-patterns section), `~/.claude/agents/{defrag-agent,agent-skill-creator,arch-implementer,memory-agent}.md` (voice anchor), `~/.claude/skills/{jot,morning}/SKILL.md` (voice anchor), `~/.claude/scripts/defrag-agent-weekly.sh` (cron-prompt voice-canon re-read instruction), `~/personal-context/work-style/hard-rules.md` (cross-reference).

### Runners canon — `~/.claude/architecture/runners/{launchd,active}.md`

- Inbound: CLAUDE.md (active scheduled runners pointer), `agents/memory-agent.md` (cron trigger spec), `~/.claude/scripts/README.md` (catchup-notice mechanism reference, added 2026-05-04), `~/personal-context/decisions/agent-os/2026-05-04-cron-runaway-disabled.md` (Path A "BUILT" pointer to runners/active.md § "Catchup-notice mechanism").

### Operational scripts — `~/.claude/scripts/*`

- `runners.conf` (new 2026-05-04): cron registry consumed by the catchup-notice hook. Inbound: `~/.claude/hooks/cron-catchup-notice.sh` (reads), `~/.claude/architecture/runners/active.md` (mechanism docs), `~/.claude/architecture/hooks/registry.md` (hook entry references), `~/.claude/scripts/README.md` (file-table row), `~/personal-context/decisions/agent-os/2026-05-04-cron-runaway-disabled.md` (post-mortem implementation pointer).
- `lib/idempotency.sh`: helper functions sourced by both runner scripts (write side via `mark_success`) and `~/.claude/hooks/cron-catchup-notice.sh` (read side via `is_due_*`). Inbound: `memory-agent-daily.sh`, `defrag-agent-weekly.sh`, `cron-catchup-notice.sh`, `~/.claude/architecture/runners/{active,launchd}.md`, `~/.claude/scripts/README.md`.
- `memory-agent-daily.sh` / `defrag-agent-weekly.sh` (runner bodies): inbound: `~/.claude/architecture/runners/active.md` (manual-only invocation pointer), `~/.claude/scripts/README.md` (file table), `~/.claude/agents/{memory-agent,defrag-agent,arch-implementer}.md` (script-path citations in the agent body's invocation/cadence sections), CLAUDE.md (operating contract bright-line citations inside the runner prompts).

### Identity portfolio — `~/personal-context/`

- Inbound: `~/.claude/hooks/personal-context-{identity,decisions,howiwork,voice,process,life,archindex,shelf,runtime,portfolio}.sh` (SessionStart auto-load, split into 10 hooks 2026-05-03 to fit per-hook inline budget; first 4-hook split overflowed at ~20KB per hook).
- Note: this is the operator-content, not Agent-OS-architecture. Edits don't ripple through the system the way canon edits do — but the hooks cache a session-time snapshot, so the snapshot regenerates on next session.

## Staleness

Update when a canon file moves / is renamed, a new cross-cutting rule spans 2+ files, a canonical home changes, or a new inbound dependent appears.

Trigger: defrag-agent regenerates the dependency graph on every run. Manual updates are acceptable but unnecessary — defrag does the grep and writes the result. Don't update for content changes inside a canon file (that file's owner's job) or new entries inside an existing registry (registry tracks itself).
