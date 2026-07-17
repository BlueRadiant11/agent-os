---
name: MCP integrations
description: MCP servers connected to Claude.ai. Read-only by default; mutations gated.
type: registry
canonical: true
owner: chief-of-staff
last_verified: 2026-05-09
---

# MCP integrations

## Connected to Claude.ai (OAuth, single-tenant per connection)

Cloudflare Developer Platform, Google Drive, Vercel, Supabase, IDE diagnostics. Tool prefix: `mcp__claude_ai_*`.

## Local stdio (added 2026-05-09)

- **Supabase (local stdio)** — `claude mcp add supabase --scope user` writes to `~/.claude.json`. Server: `@supabase/mcp-server-supabase@latest`. Single PAT covers every Supabase org the operator's account belongs to (Project Alpha + command-center / life-os today). Resolves the single-tenant limitation of the claude.ai connector. Tool prefix: `mcp__supabase__*`. The `--read-only` server flag is the writability switch — drop it at `claude mcp add` time to enable writes (then permissions/ask.md gates per-call).

## Considered and skipped

- **Local stdio Vercel MCP (skipped 2026-05-09)** — claude.ai Vercel connector already shows all relevant teams; no single-tenancy gap to close. No official `@vercel/mcp-server` exists — only `@vercel/mcp-adapter` (which is for hosting MCPs ON Vercel, not accessing Vercel API). All third-party Vercel MCPs (`@robinson_ai_systems/vercel-mcp`, `vercel-mcp`, etc.) are unvetted and would receive a Vercel API token. Current write surface via MCP (`deploy_to_vercel` + dev preview toolbar mutations) is thin and either unused (push-to-main is the deploy) or low-stakes. Re-evaluate if the claude.ai connector starts dropping, a real Vercel write workflow emerges, or Vercel ships an official local MCP.

## Permission posture

Mutating MCP calls are gated in `permissions/ask.md` (Supabase writes for both prefixes, Cloudflare writes, Vercel deploy, Cloudflare `d1_database_query`). Read-only MCP calls — list / get / search / read patterns across all connected servers — are explicitly listed in `permissions/allow.md` (added 2026-05-07 for the claude.ai prefix; mirrored 2026-05-09 for the local stdio Supabase prefix). Two deliberate exclusions on the claude.ai side: Vercel `web_fetch_vercel_url` (arbitrary URL fetch through auth) and Cloudflare `set_active_account` (state-mutating in session) — both fall through to the harness default prompt.

## Planned expansion

Parked 2026-05-03 (Agent OS shipped to maintenance). Idea: broaden the MCP roster to expand Agent OS capability surface. Specific targets TBD — pick when a real capability gap surfaces during Project Alpha work, not preemptively.

Detail: `~/personal-context/decisions/agent-os/2026-05-03-agent-os-maintenance.md` § "MCP / external-connections expansion."

## Open

- Any other AI tools used regularly (ChatGPT, Gemini, OpenCode, Cursor, etc.)?
- Preferred surface for which tasks?
