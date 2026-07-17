---
name: Permissions evolution protocol
description: When to propose moving entries between allow / deny / ask. Source-of-truth rule (settings.json wins on disagreement).
type: process
canonical: true
owner: chief-of-staff
last_verified: 2026-05-03
---

# Evolution protocol — when to propose moving entries

Permissions evolve based on observed usage and observed risk. Chief of Staff watches and proposes changes; the operator approves before any settings.json edit.

## Move from Ask → Allow when

- The same `ask` prompt has been approved ≥3 times without rollback or regret.
- The blast radius is local-only (no shared state, no money, no external messaging).
- Prompt fatigue is the failure mode (the operator approves reflexively).
- *Surface as:* "**Permission promotion candidate:** `<command>` — approved 4 times, no rollbacks, local scope. Move from `ask` to `allow`? Y/N."

## Move from Allow → Ask when

- The auto-approved command caused harm or surprise even once.
- A new context emerged where the same command has different implications.
- *Surface as:* "**Permission demotion:** `<command>` — caused `<incident>`. Move from `allow` to `ask`. Confirming."

## Move to Deny when

- A command had a clearly bad outcome and the operator would never want to run it again from this account.
- *Surface as:* "**Permission deny candidate:** `<command>` — caused `<incident>`. Lock to `deny`? Y/N."

## Add a new entry when

- A new tool / MCP / command lands and its risk shape is known. Default to `ask` unless it's clearly safe.
- **Default new entries land in `ask`, not `allow`.** Earn allow status through observed behavior.

## Pre-approved categories vs allow.md

`pre-approved-categories.md` (sibling file) and `allow.md` enforce different layers of the same gate. `allow.md` lists tool-call patterns the harness auto-approves; `pre-approved-categories.md` lists *kinds of work* CoS may undertake without asking. Both must clear for an autonomous action to proceed: a pre-approved category whose tool calls aren't on `allow.md` still hits a permission prompt; a tool call on `allow.md` whose work category isn't pre-approved still surfaces to the operator. The same evolution rules above apply to `pre-approved-categories.md` — promote when a category gets approved 3+ times without rollback; demote on harm or surprise.

## Source-of-truth rule

When this section disagrees with `~/.claude/settings.json`, **settings.json wins** because that's what actually enforces. Update this section after editing settings.json, not the other way around.

The `~/.claude/hooks/settings-mirror-reminder.sh` hook (added 2026-05-02) emits a systemMessage on every settings.json edit reminding to mirror in the registry.
