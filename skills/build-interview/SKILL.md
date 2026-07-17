---
name: build-interview
description: Step 0 of /build-pipeline — front-loads design questions the operator would otherwise be asked mid-build. CoS composes this skill in the main session before dispatching agent-skill-creator. Runs 6 universal AskUserQuestion rounds for skills (8 for agents), returns a structured YAML interview block that CoS includes as the leading YAML block of the dispatch prompt to agent-skill-creator. The block travels with the dispatch so downstream pipeline steps (/ce:brainstorm, /ce:plan, /ce:work) can consult it as the first-step fallback. Use when /build-pipeline triggers, when the operator approves a build, or when refreshing interview-context for an in-flight build.
argument-hint: "<build candidate description — one-paragraph spec>"
---

# /build-interview

CoS-composed skill. You run in the main session — `AskUserQuestion` only surfaces here, never inside a dispatched sub-agent. The interview happens *before* `agent-skill-creator` is dispatched; its output is a YAML block CoS includes as the leading content of the dispatch prompt (post-2026-05-19 bridge-protocol simplification — pad infrastructure removed, prompt is the only context channel).

The point: front-load every design question downstream agents would otherwise ask the operator mid-build. the operator answers 6 rounds (skills) or 8 (agents) up-front; the agent runs uninterrupted.

Origin: `~/Desktop/claude-workspace/brainstorms/2026-05-17-interview-first-pivot-requirements.md`. Plan: `~/Desktop/claude-workspace/plans/2026-05-17-001-feat-interview-first-pivot-plan.md`.

## When this runs

- **Auto:** Step 0 of `/build-pipeline`. The pipeline reads this skill before dispatching `agent-skill-creator`.
- **Manual:** the operator can invoke directly to refresh interview-context for an in-flight build, or to draft a build's interview-context without immediately running the pipeline.

## Input

A one-paragraph spec describing the build candidate. Comes from the operator's approval message, or from CoS's pitch-and-confirm exchange.

If invoked with no argument, ask the operator: "what are we building?" — one line, then continue.

## Procedure

### Step 1 — Classify: skill or agent?

Read the spec. Decide whether it describes a **skill** (invocable verb, stateless, returns once) or an **agent** (continuously running or trigger-driven orchestrator, composes skills, maintains memory).

If the spec is unambiguous, state the classification in one line and proceed. If ambiguous, ask the operator:

```
question: "Is this a skill or an agent?"
header: "Type"
options:
  - "Skill — invocable verb, returns once"
  - "Agent — orchestrator, composes skills, may run autonomously"
```

Skills get 6 universals. Agents get 8.

### Step 2 — Run the universals

One `AskUserQuestion` call per universal. Each question presents 2–4 options + auto-"Other" for free-text override. Record the operator's selection plus any "Other" override text.

Per-question option matrices below. The skill SHOULD NOT improvise options on the fly — these are the canonical sets resolved during `/ce:plan` (origin: `2026-05-17-001-feat-interview-first-pivot-plan.md` § OQ3).

#### 1. Purpose

```
question: "One-line purpose — what does this <skill|agent> do?"
header: "Purpose"
options:
  - "Capture / route information (jot-shaped)"
  - "Audit / sweep state (defrag-shaped)"
  - "Compose other skills or agents (chief-of-staff-shaped)"
  - "Produce a digest (morning-shaped)"
```

Record: the option label + any free-text override appended in parens.

#### 2. Triggers

```
question: "How is it invoked?"
header: "Trigger"
options:
  - "Slash command only (e.g., /jot)"
  - "Slash command + natural-language phrases (e.g., /coach + 'coach me')"
  - "Natural-language only (e.g., 'morning brief')"
  - "Composed by another agent / skill (not user-facing)"
```

#### 3. Output shape

```
question: "What does it produce, and in what format?"
header: "Output"
options:
  - "Punch-list (SHIPPED / BLOCKED / QUEUED / NOTICED)"
  - "Structured digest (named sections, e.g., WINS / EDGES / REFLECTION)"
  - "Single-line confirmation ('done', 'jotted', etc.)"
  - "Approval digest (propose-then-ask; writes after the operator approves)"
```

#### 4. Scope in

```
question: "What's explicitly in scope?"
header: "Scope-in"
options:
  - "Single file or surface"
  - "One domain (memory layer / agent roster / hooks / etc.)"
  - "Cross-cutting (multiple domains)"
  - "Project-specific (Project Alpha / Life OS / Agent OS)"
```

#### 5. Scope out

```
question: "What's explicitly OUT of scope? (bright-line guard against drift)"
header: "Scope-out"
options:
  - "No write actions (read-only proposals only)"
  - "No external sends (drafts only, never sends)"
  - "No destructive ops (never delete / overwrite without approval)"
  - "No yours-forever zones (no customer / hiring / strategic decisions)"
```

Multi-select is acceptable — if the operator wants multiple guards, capture all selected as a comma-separated string.

#### 6. Patterns to mirror

This question's options are **dynamically derived** at runtime, not from a static table.

1. Extract keywords from the build spec (top 3–5 nouns + verbs).
2. Walk `~/.claude/skills/` and `~/.claude/agents/` (frontmatter `description` fields).
3. Find up to 3 candidates with the highest keyword overlap with the spec.
4. Present those 3 as options.

If the keyword scan returns nothing useful (truly novel build), present generic placeholders:

```
question: "Which existing skill or agent sets the closest precedent for this build?"
header: "Patterns"
options:
  - "None — novel build (no close precedent)"
  - "<dynamic candidate 1>"
  - "<dynamic candidate 2>"
  - "<dynamic candidate 3>"
```

Record: the chosen path (or "none"), plus any "Other" override naming a file the scan missed.

#### 7. Failure mode

```
question: "What happens when the <skill|agent> doesn't apply or hits an error?"
header: "Failure"
options:
  - "Refuse silently and exit (no surfacing)"
  - "Surface refusal to the operator in one line"
  - "Fall back to default behavior (best-effort partial output)"
  - "Compose another skill / agent as fallback"
```

### Step 3 — Agent-only universals (skip if classified as skill)

#### 8. Trust tier

```
question: "Initial trust tier on launch?"
header: "Trust tier"
options:
  - "Operator-directed only (full permissions in scope; no autonomous trigger)"
  - "Autonomous-eligible (graduates after N successful Operator-directed runs)"
  - "Initial Operator-directed, future autonomous candidate (graduation criteria documented)"
```

#### 9. Tool access

```
question: "Which Claude Code tools does the agent get?"
header: "Tools"
options:
  - "Read-only (Read, Grep, Glob, read-only Bash)"
  - "Read + Edit / Write (full file lane, no Bash)"
  - "Full (Read, Edit, Write, Bash, Agent for sub-dispatch)"
  - "Custom — specify in Other"
```

### Step 4 — Emit the interview block

Render the answers as a fenced YAML block matching the canonical schema (origin: pivot plan § OQ1) — exactly this format, fenced with triple backticks so the agent's prompt-parser finds it:

````
```yaml
interview:
  purpose: "<answer + any Other override>"
  triggers: "<answer + any Other override>"
  output_shape: "<answer + any Other override>"
  scope_in: "<answer + any Other override>"
  scope_out: "<answer + any Other override>"
  patterns_to_mirror: "<path or 'none — novel build' + any Other override>"
  failure_mode: "<answer + any Other override>"
  # Agents only:
  trust_tier: "<answer + any Other override>"
  tool_access: "<answer + any Other override>"
```
````

Plus a one-line summary CoS can use when narrating the dispatch:

```
INTERVIEW COMPLETE
  classification: <skill|agent>
  purpose: <one-line>
  patterns_to_mirror: <path>
  next: CoS includes the fenced YAML block as the leading content of the dispatch prompt to agent-skill-creator (after the BRIDGE_PAD_PATH sentinel line).
```

### Step 5 — Hand off

If invoked as Step 0 of `/build-pipeline`, return the fenced YAML block + the one-line summary to the orchestrator (CoS), who immediately dispatches `agent-skill-creator` with the following prompt shape:

```
BRIDGE_PAD_PATH: inline

```yaml
interview:
  <YAML block from Step 4>
```

# Task
<one-paragraph build spec from the operator's approval message>
```

No file write, no pad construction. The YAML block IS the interview-context channel; the agent reads it from the prompt directly. This is the post-2026-05-19 native-architecture flow — the Agent tool's `prompt` parameter is the only context channel; briefing.md / pad infrastructure was removed.

If invoked standalone, print the fenced YAML block + the one-line summary and stop. the operator can paste the block into the dispatch prompt himself or kick off `/build-pipeline` afterward.

## Rules

- **Never run inside a sub-agent.** `AskUserQuestion` only surfaces in CoS's main session.
- **One question at a time, click-through.** No batched multi-question prompts.
- **Never improvise options.** The matrices above are canonical. The "Other" auto-option absorbs novelty.
- **Empty answer allowed only for non-critical questions** (scope_out, failure_mode for trivial-skill carve-outs). Purpose, triggers, output_shape, scope_in, patterns_to_mirror must have a non-empty value.
- **No mid-interview composition.** Don't dispatch sub-agents while running the interview. Save composition for after the block is emitted.
- **Voice:** match `~/.claude/skills/jot/SKILL.md` and `~/.claude/skills/dispatch-protocol/SKILL.md` — terse, procedural, second-person imperative.

## Bright lines

- The interview is **the only legal mid-build escalation channel.** After this step, no agent surfaces questions to the operator — the bridge protocol's question-asking infrastructure was removed 2026-05-17 (items 4 + 5 deleted; `questions.md` / `answers.md` / `.seen-questions` removed from pad anatomy). If a downstream agent needs an answer that interview-context can't provide, it follows the fallback hierarchy: `~/personal-context/` direct match → infer from `~/personal-context/` patterns → agent's own judgment (logged as FINDING in `return.md`).
- the operator reviews agent-judgment findings post-build via `return.md`. The interview is the up-front input channel; `return.md` FINDINGS is the post-completion input channel.

## Cross-references

- **Pivot brainstorm:** `~/Desktop/claude-workspace/brainstorms/2026-05-17-interview-first-pivot-requirements.md`
- **Pivot plan:** `~/Desktop/claude-workspace/plans/2026-05-17-001-feat-interview-first-pivot-plan.md`
- **Build pipeline:** `~/.claude/skills/build-pipeline/SKILL.md` (Step 0 invokes this skill)
- **Bridge protocol (canonical):** `~/.claude/architecture/agents/bridge-protocol.md` (Item 3 = the fallback hierarchy this interview front-loads)
- **agent-skill-creator:** `~/.claude/agents/agent-skill-creator.md` (consumes interview-context via the dispatch prompt's leading YAML block — see Step 5)
- **Bridge-protocol simplification receipt (why interview-context flows via prompt now):** `~/personal-context/decisions/agent-os/2026-05-19-bridge-protocol-simplification.md`
