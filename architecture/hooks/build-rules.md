---
name: Hook build rules
description: When to build a hook (proactive recommendation rule). Two trigger paths — Chief of Staff proposes, or defrag-agent surfaces a Pass B finding (two signal classes: documented rules with no enforcement + observed drift behaviors).
type: process
canonical: true
owner: chief-of-staff
last_verified: 2026-05-12
---

# When to build a hook

Two trigger paths.

## Chief of Staff proposes when

- A real enforcement gap is observed (something risky got through the permission layer).
- Adding the entry to `ask` or `deny` doesn't solve it because the risk is content-shaped, not name-shaped.
- The cost of building (one bash script + settings.json wiring) is justified by the risk avoided.

## Defrag-agent surfaces when

Two signal classes trigger Pass B findings.

**Signal A — Documented rule, no mechanical enforcement.** A behavioral rule in canon (CLAUDE.md, agent files, skill files, registry files, memory files) is documented as load-bearing but relies on the model remembering. Pattern shapes: "always X before Y," "whenever X, do Y," "after editing X, mirror in Y," "never X without Y."

**Signal B — Observed drift, no enforcement.** An agent, skill, or workflow exhibited a behavior in recent runs that diverged from its spec — silent job/phase skip, missing post-condition, repeated tool call with different args after failure, mid-task context-compaction without state checkpoint, sub-agent returning without invoking the verification step its prompt requires, canonical-file edit without `last_verified` bump. The drift is observable in session transcripts even when no rule is yet documented.

For Signal B, Defrag has a two-fold job: surface the drift (so the documented rule can land if it's missing) AND propose the hook (so the rule has teeth before the next slip).

Both signal types produce findings in the HK category with `hook spec:` blocks detailed enough that arch-implementer can build without a round-trip. The detection rubric — concrete signals, diagnostic questions, and propose templates — lives in `~/.claude/agents/defrag-agent.md` § "Pass B detection rubric."

the operator approves the finding ID; arch-implementer builds the script + wires settings.json + mirrors the hook registry in one atomic flow per `~/.claude/agents/arch-implementer.md` § "Hook construction (HK Pass B findings)."

## Build-time evaluation during feature work

Triggers BEFORE the build, not after. Before writing implementation code for any new feature, agent, skill, hook, or tool integration, the building agent (Chief of Staff, agent-skill-creator, or Claude executing a build directly) evaluates: does this introduce a drift-risk surface that warrants a hook?

The evaluation fires when:

- A new agent or skill is being designed (any phase of `/build-pipeline`).
- A new tool integration or external system is being added.
- A new workflow that crosses multiple agents or sessions is being defined.
- An existing feature is being extended with side-effect-bearing behavior (writes, sends, mutations).

### Drift-risk surfaces to evaluate

For each surface, ask: "is the failure mode silent? would I notice if this didn't fire correctly?" Silent-failure paths are the strongest hook candidates.

1. **Long-running tasks** — agents or skills that span many tool calls; risk: silent job/phase skip, retry loop, mid-task drift.
2. **Multi-agent handoffs** — outputs from one agent consumed by another; risk: finding-ID loss, paraphrasing, scope creep.
3. **Tool calls with side effects** — Edit / Write / Bash mutations / MCP writes / Supabase writes / sends; risk: action lands without expected post-condition (registry mirror, last_verified bump, approval gate).
4. **Context-heavy operations** — anything where compaction could fire mid-task; risk: in-flight state lost without re-injection.
5. **Bright-line approvals** — push / send / spend; risk: rule documented but enforcement is model-trust.
6. **Sub-agent invocations** — risk: agent skips charter step or skill composition silently.
7. **Canonical-file edits** — risk: doc-vs-reality drift without a downstream sweep.
8. **Pattern-based rules in canon** — "always X before Y," "after X, mirror in Y"; risk: model-memory enforcement only.

### How to propose

When a drift-risk surface fires, propose the hook BEFORE writing the feature's implementation. Format:

```
HOOK PROPOSAL — <one-line surface description>

  rationale: <one sentence — what fails silently without this>
  hook spec:
    event: <PostToolUse | PreToolUse | Stop | UserPromptSubmit | SessionStart | SubagentStop | PreCompact | Notification>
    matcher: <tool name(s) or empty>
    path filter: <if relevant>
    script behavior: <one paragraph — what to verify, what to surface>
    script path: ~/.claude/hooks/<name>.sh
  verify by: <reproducible command>

  Approve hook build? (y / edit / skip — feature proceeds without enforcement)
```

If the operator approves, the hook is built as part of the feature's atomic delivery. If skipped, the feature ships without enforcement and the surface is recorded for future re-evaluation (drop into `~/.claude/architecture/hooks/audit-2026-05-12.md` or surface at next defrag run).

This path is the build-time counterpart to Defrag's Pass B (audit-time). Both feed the same hook-build pipeline; they catch drift at different points in the lifecycle. For builds going through `/build-pipeline`, the evaluation is a mandatory phase — see `~/.claude/skills/build-pipeline/SKILL.md` § "Hook-evaluation waypoint."

## Each path produces a the operator-gated hook build

All three paths (CoS proposes, Defrag surfaces, build-time evaluation) feed the same approval flow. The audit-fix loop makes Pass B routine; build-time evaluation makes proactive enforcement routine; ad-hoc CoS proposals remain for in-the-moment gaps the other two haven't caught yet.

## What hooks can do that permissions can't

| Capability | Permissions | Hooks |
| --- | --- | --- |
| Block by command name pattern | Yes | Yes |
| Block by command argument content | No | Yes |
| Block by file content | No | Yes |
| Inject confirmation flow with custom logic | No | Yes |
| Log tool calls for audit | No | Yes |
| Rate-limit specific commands | No | Yes |
