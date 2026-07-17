---
name: build-pipeline
description: Designated build path for new skills and sub-agents in the Agent OS. Use when Chief of Staff is about to propose or dispatch a skill / agent build, when deciding whether something should be a skill or an agent, or when the agent-skill-creator agent needs the canonical loop. Step 0 is `/build-interview` (CoS runs in the main session, captures the operator's answers to 6 universals for skills / 8 for agents); downstream steps compose the compound-engineering plugin (`/ce:brainstorm` → `/ce:plan` → `/ce:work` → `/ce:compound`) plus design-pass and verification waypoints for agents. Interview-first pivot 2026-05-17 — agents never resurface questions mid-build; they consult interview-context, then `~/personal-context/`, then infer, then decide (logged as FINDING in `return.md`).
---

# /build-pipeline

The verb-of-record for adding new skills and sub-agents to the Agent OS. CoS reads this when about to pitch a build candidate, when the operator approves one, or when dispatching `agent-skill-creator`.

*Trivial-skill carve-out: build-pipeline is a meta-procedural docs-skill (no execution surface), zero design decisions distinct from the documented loop. Brainstorm + plan skipped per Path A § Trivial-skill carve-out (`~/.claude/agents/agent-skill-creator.md:46`). Approved by the operator 2026-05-02.*

## Step 0 — Interview (front-load every design question)

**Pivot 2026-05-17.** Every build begins with `/build-interview` in CoS's main session — not inside `agent-skill-creator`. `AskUserQuestion` only surfaces in the main thread; the interview happens before dispatch.

`/build-interview` runs **6 universal AskUserQuestion rounds for skills** (purpose, triggers, output shape, scope in, scope out, patterns to mirror, failure mode) **or 8 for agents** (universals + trust tier + tool access). Output is a fenced YAML `interview:` block. CoS pastes the block as the leading content of the dispatch prompt to `agent-skill-creator` (after the `BRIDGE_PAD_PATH: inline` sentinel line). The block travels with the dispatch — downstream agents read it from the prompt as the first lookup for every design question. **Native Claude Code architecture only** — no pad construction, no briefing.md file; the Agent tool's `prompt` parameter is the entire context channel post-2026-05-19 bridge-protocol simplification.

**The interview always runs.** Even for trivial-skill carve-outs (one-line shims, stable upstream APIs) — the interview is cheap and produces an audit-trail. No "skip if spec is crisp" carve-out exists for the interview.

See `~/.claude/skills/build-interview/SKILL.md` for the canonical option matrix and procedure.

## Fallback hierarchy (the canonical contract for every downstream agent)

When `/ce:brainstorm`, `/ce:plan`, or `/ce:work` (running inside `agent-skill-creator`) needs to answer a design question, the agent consults sources in this order:

1. **Interview-context** in the dispatch prompt's leading fenced YAML block (populated by `/build-interview`). Most specific — the operator just answered this for this exact build.
2. **`~/personal-context/`** direct match. General preferences, persistent across builds.
3. **Inference from `~/personal-context/`** patterns. Look at how the operator's other skills/agents handle similar concerns; pick the most consistent option.
4. **Agent's own judgment.** Truly novel design choice with no signal. Make a call, document it as a FINDING in `return.md` so the operator reviews post-build.

**No escalation to the operator mid-build.** The bridge protocol's question-asking infrastructure (items 4 + 5, `questions.md` / `answers.md` / `.seen-questions`, the SessionStart branch of `bridge-surface.py`) was removed 2026-05-17 per the pivot brainstorm at `~/Desktop/claude-workspace/brainstorms/2026-05-17-interview-first-pivot-requirements.md`. Canonical contract lives at `~/.claude/architecture/agents/bridge-protocol.md` § Item 3.

the operator reviews agent-judgment findings post-build via `return.md`. The interview is the up-front input channel; `return.md` FINDINGS is the post-completion input channel.

## Skill vs. agent — when to recommend which

- **Skill** = an invocable verb. User or another agent calls it; it executes once and returns. Stateless. *e.g.* `/jot`, `/morning`, `/dispatch-protocol`.
- **Agent** = a continuously running or trigger-driven orchestrator. Composes skills, decides what to invoke when, maintains memory, may run autonomously without user input. *e.g.* memory-agent (daily cron), defrag-agent (weekly audit).

Default to recommending a **skill** unless the work specifically needs autonomy or state persistence — those are the agent signals.

## Designated build path — skills

When the operator approves a skill, follow this loop using the compound-engineering plugin. **Every step is mandatory for any non-trivial skill.** The loop is the rigor; bypassing it degrades quality. Step 0 (`/build-interview`, above) has already run in CoS's main session; downstream steps consume interview-context via the leading YAML block of the dispatch prompt.

1. **`/ce:brainstorm`** (consumes interview-context) — explore what the skill should do, edge cases, integration points. Even with a clear spec, the brainstorm catches things the spec missed and produces an artifact in `claude-workspace/brainstorms/`. Resolve design questions via the fallback hierarchy above — never escalate to the operator.
2. **`/ce:plan`** — produce a structured plan doc in `claude-workspace/plans/`.
3. **Hook-evaluation waypoint** — evaluate whether the skill introduces a drift-risk surface that warrants a hook. See § "Hook-evaluation waypoint" below for the procedure.
4. **`/ce:work <plan-path>`** — execute the plan: write the SKILL.md, references, supporting files. If a hook was approved at step 3, it ships in the same atomic delivery.
5. Invoke the skill once to validate; iterate if needed.
6. **`/ce:compound`** — capture any non-obvious lesson into the project's `docs/solutions/` (or `claude-workspace/context/lessons.md` for cross-project lessons).

**Trivial-skill carve-out (rare):** a single-purpose wrapper / one-line shim with zero design decisions and a stable upstream API can shortcut to direct authoring. The default is full loop; the shortcut needs explicit justification per build. The hook-evaluation waypoint still applies to trivial-skill carve-outs — record `no drift-risk surfaces` explicitly rather than skipping the question.

## Designated build path — agents

**Every step is mandatory.** Agents are persona-bearing artifacts with charter, scope, trust tier, and composition rules — there's no "the spec is crisp" shortcut for them. Step 0 (`/build-interview`, above) has already run with **8 universals** (universals + trust tier + tool access); downstream steps consume interview-context via the leading YAML block of the dispatch prompt.

1. **`/ce:brainstorm`** (consumes interview-context) — explore the agent's role, triggers, inputs / outputs, what it owns vs. recommends, where it sits in the trust-tier model. Produces a brainstorm artifact. Resolve design questions via the fallback hierarchy above — never escalate to the operator.
2. Apply the **`agent-native-architecture`** skill — design pattern verification (composability, agent-as-first-class-citizen, action / context parity).
3. **`/ce:plan`** — produce the plan doc in `claude-workspace/plans/`.
4. **Hook-evaluation waypoint** — evaluate whether the agent introduces a drift-risk surface that warrants a hook. Agents are the highest-leverage surface for this evaluation; long-running tasks, multi-agent handoffs, and silent phase-skip are common drift patterns. See § "Hook-evaluation waypoint" below for the procedure.
5. **`/ce:work <plan-path>`** — author the agent file (Markdown + frontmatter), tools, composing skills, cron / trigger configuration. If a hook was approved at step 4, it ships in the same atomic delivery.
6. **`agent-native-reviewer`** agent — verifies the final cut. Treat as default, not optional.
7. Trigger the agent once to validate; iterate.
8. **`/ce:compound`** — capture lessons.

Same compound-engineering loop as skills, with three mandatory extra waypoints (`agent-native-architecture` for design, hook-evaluation for enforcement, `agent-native-reviewer` for verification). **No shortcuts.**

## Hook-evaluation waypoint

Fires after the plan is finalized, before implementation code is written. Output is one of three states — `proposal`, `none`, or `deferred` — and is recorded in the plan doc before `/ce:work` begins.

**Step 1.** Walk the drift-risk surface list at `~/.claude/architecture/hooks/build-rules.md` § "Drift-risk surfaces to evaluate." For each surface, ask: "does the planned skill / agent introduce this kind of failure mode?"

**Step 2.** For each surface that fires, produce a HOOK PROPOSAL using the format at `~/.claude/architecture/hooks/build-rules.md` § "How to propose."

**Step 3.** Present the proposal(s) to the operator inline before dispatching `/ce:work`. Three legal outcomes:

- `proposal` — the operator approves the hook spec. The hook ships in the same atomic delivery as the skill / agent. `/ce:work` includes the hook script + settings.json wire + hook-registry mirror in its work.
- `none` — no drift-risk surfaces identified. Record `Hook-evaluation: none — <one-line rationale>` in the plan doc and proceed.
- `deferred` — surface(s) identified but the operator defers the hook build (acceptable risk, low priority, build cost not justified yet). Record `Hook-evaluation: deferred — <surface> — <one-line rationale>` in the plan doc AND drop a row into `~/Desktop/hooks-audit.md` so defrag's Pass B picks it up on the next audit.

**Silent skip is not a legal outcome.** The waypoint produces one of the three states explicitly. Skipping it without record is a build-pipeline violation, surfaceable by Defrag (Signal A — documented rule with no enforcement) or by agent-native-reviewer at the verification step.

The waypoint is the build-time counterpart to Defrag's Pass B (audit-time). The two paths catch drift at different points in the feature lifecycle.

## Proactive recommendation policy

CoS watches for build candidates continuously and pitches them — does not build without approval.

**Triggers for a skill recommendation:**

- A recurring manual task done 2+ times (the third time you do something by hand, surface it).
- A multi-step workflow with stable shape and clear inputs / outputs.
- A pain point or friction the operator explicitly names.
- A pattern that matches an entry in the proposed bench (`~/.claude/architecture/tool-stack/custom-skills.md` → "Candidates").

**Triggers for an agent recommendation:**

- A skill candidate keeps surfacing the same upstream pattern that needs autonomy (e.g., `/morning` is useful, but it should fire automatically — that's the Memory Agent signal).
- A planned roster agent's preconditions are met (e.g., enough Life OS habit data accumulated → Coach Agent worth building).
- A persistent role across sessions that no current skill or human cycle is filling.

**Recommendation format (one-liner, not a pitch):**

> **Skill candidate:** `/<name>` — <one-sentence purpose>. Build it? Y/N.

> **Agent candidate:** `<name>` — <one-sentence purpose>. Trigger: <when it fires>. Build it? Y/N.

Don't stack candidates. One at a time, fired when the trigger lands. If the operator says no, drop it; if yes, queue or build per his instruction. Never auto-build.

## Trust tier on launch

New agents start at Tier 1 (Operator-directed) by default per `~/.claude/architecture/agents/invocation-paths.md`; graduation criteria are not yet codified — track in `decisions/agent-os/` when defined.

## Where build artifacts land

- Brainstorms: `~/Desktop/claude-workspace/brainstorms/<YYYY-MM-DD>-<slug>-requirements.md`
- Plans: `~/Desktop/claude-workspace/plans/<YYYY-MM-DD>-<NNN>-feat-<slug>-plan.md`
- Skill body: `~/.claude/skills/<name>/SKILL.md`
- Agent body: `~/.claude/agents/<name>.md`
- Lesson (cross-project): `~/Desktop/claude-workspace/context/lessons.md`
- Lesson (project-specific): `<project>/docs/solutions/<category>/<slug>-<date>.md`

## Existing build agent

`agent-skill-creator` (`~/.claude/agents/agent-skill-creator.md`) is the agent that runs this pipeline on CoS handoff. When the operator approves a build, dispatch `agent-skill-creator` with the spec; the agent walks the loop above.
