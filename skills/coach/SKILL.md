---
name: coach
description: Weekly Sunday-evening interpretive coaching ritual. Use when the operator types `/coach`, "coach me", "coach session", "weekly review", or asks for the Sunday week-close interpretive digest. Composes the `coach-agent` sub-agent which reads Life OS + identity portfolio for the past 7 days and returns a WINS / EDGES / REFLECTION digest in the DeMello+Robbins voice (encouragement + sober-honesty registers). Distinct from `/morning` — `/morning` bites daily with dark humor, `/coach` buttresses weekly with evidence-anchored recognition + protocol-break naming. v1 is Operator-directed only; no autonomous trigger.
argument-hint: "[optional: focus <area>]"
---

# /coach

The weekly Sunday-evening invocation surface for `coach-agent`. the operator types `/coach`; you dispatch the agent and surface its digest.

## When this skill fires

Trigger phrases (any of):

- `/coach`
- "coach me"
- "coach session"
- "weekly review"
- "what does the data say this week"
- "Sunday digest"

Default cadence: weekly Sunday-evening (per the sleep protocol's wind-down ramp). Skipping a Sunday is allowed; no penalty. Mid-week invocations are not the design — the past-7-days window is calibrated for Sunday-evening reading. If the operator invokes mid-week without explicit reason, gently note the cadence mismatch once and ask whether to run anyway or defer to Sunday. Don't second-guess after the once.

## What this skill does

Dispatches the `coach-agent` sub-agent (`~/.claude/agents/coach-agent.md`) via the Agent tool. `coach-agent` reads its operating loop on every run (per its persona), queries Life OS + identity portfolio for the past 7 days, applies the active-growth-edges priority + notable-signal threshold, generates the WINS / EDGES / REFLECTION digest, watches for the `capture:` gate phrase during the conversation, and returns the rendered digest.

The agent does the substantive work. This skill is the invocation handoff — trigger-phrase mapping, optional argument parsing, dispatch.

## Optional argument

`/coach focus: <area>` — overrides `coach-agent`'s default active-growth-edges priority for a single session. Examples:

- `/coach focus: exam` — Coach weights study habit + study consistency first
- `/coach focus: relationships` — Coach weights people contact frequency first
- `/coach focus: sleep` — Coach weights sleep protocol metrics first

Without an argument, `coach-agent` uses its standard priority order (active growth edges first per `~/personal-context/identity.md` § "Active growth edges", with `~/.claude/CLAUDE.md` § "Priority ranking" as fallback).

Argument parsing: case-insensitive; `focus:` prefix optional (`/coach exam` works the same as `/coach focus: exam`). Pass the parsed area to `coach-agent` as a one-line context note in the dispatch prompt.

## Dispatch

Use the Agent tool with `subagent_type: coach-agent`. Pass the focus argument if provided. `coach-agent` runs synchronously; surface its returned digest as the response.

The agent persona handles its own voice gate, output format, and `capture:` gate. Do not editorialize the digest, do not paraphrase, do not add wrap-up commentary. Pass through verbatim.

## What this skill does NOT do

- **Does not duplicate `coach-agent`'s workflow.** The agent is the actor; this skill is the verb.
- **Does not run daily.** That's `/morning`'s job. `/coach` is weekly Sunday-evening only.
- **Does not bite.** Dark-humor coach-push lives in `/morning`'s WHERE YOU'RE SLIPPING. Coach buttresses with encouragement + sober-honesty.
- **Does not write to canon, Supabase, or external services.** `coach-agent` only drafts `/jot` content via the explicit `capture: ...` gate; `/jot`'s own approval flow handles any actual write.
- **Does not chain into other skills.** No auto-invocation of `/morning`, `/jot`, `/route-memory`, `/dedupe-memory`. The only composition path is `coach-agent` → `/jot` (gated).

## Bright lines

Inherits all bright lines from `~/.claude/CLAUDE.md`:

- Truth above all. If Life OS data is sparse or the agent surfaces a data-hygiene observation, pass that through honestly.
- No push, send, spend, or external writes.
- No git commits, no Supabase writes, no canon edits.
- No fabricated observations — `coach-agent` enforces this internally; if you see what looks like a fabricated WIN or EDGE in the returned digest, surface as a build issue rather than passing through.

## Verbosity

Surface the agent's digest verbatim. Default response shape is the WINS / EDGES / REFLECTION block. No preamble like "Here's your Coach session:" — just the digest.

If the agent returned a sparse-data fallback (no surface met threshold), surface that as-is. The user reads it and reacts.
