---
name: Permissions — ask list
description: Every-time prompt entries. the operator approves each call individually.
type: registry
canonical: false
owner: chief-of-staff
last_verified: 2026-05-09
---

# Ask (every-time prompt)

| Category | Entries |
| --- | --- |
| Git remote | `git push`, `git reset --hard`, `git clean` (`git merge` / `git rebase` moved to `allow` 2026-05-07 — local-only, push gate still catches remote impact) |
| GitHub PR / issue mutations | `gh pr create/merge/close`, `gh issue close` |
| Package installs | `npm install`, `npm install -g`, `pip install`, `brew install` |
| Supabase MCP writes | `apply_migration`, `execute_sql`, `delete_branch`, `deploy_edge_function` |
| Supabase MCP writes (local stdio) | Same 4 write tools mirrored under `mcp__supabase__*` prefix (added 2026-05-09 — local stdio Supabase MCP. Server-side `--read-only` flag also blocks these by default; drop the flag at `claude mcp add` time to enable per-call ask-gated writes.) |
| Cloudflare MCP writes | `d1_database_delete`, `d1_database_query`, `kv_namespace_delete`, `r2_bucket_delete`, `hyperdrive_config_delete` |
| Vercel MCP | `deploy_to_vercel` |

## Other settings (top-level keys)

- `enabledPlugins`: compound-engineering only
- `skipAutoPermissionPrompt`: true (startup permission prompt suppressed)
- `theme`: `dark-ansi`
- `autoUpdates`: true
- `includeCoAuthoredBy`: true
