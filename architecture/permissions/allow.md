---
name: Permissions — allow list
description: Auto-approved entries. Mirror of ~/.claude/settings.json allow array. Settings.json wins on disagreement (source-of-truth rule).
type: registry
canonical: false
owner: chief-of-staff
last_verified: 2026-05-09
---

# Allow (auto-approved, no prompt)

| Category | Entries |
| --- | --- |
| Read-only git | `git status`, `git diff`, `git log`, `git show`, `git branch`, `git blame`, `git stash list`, `git remote -v`, `git ls-files` |
| Git mutations (local) | `git add`, `git commit`, `git config`, `git checkout -b` |
| Git locals (broader) | `git checkout:*`, `git stash:*`, `git restore:*`, `git switch:*`, `git fetch:*`, `git merge:*`, `git rebase:*` (added 2026-05-07 — Tier 1 + Tier 2 widening. `merge` / `rebase` moved from `ask`. Push remains gated; force-push to canon stays on `deny`.) |
| Filesystem reads | `ls`, `pwd`, `which`, `mkdir`, `echo`, `head`, `tail`, `cat`, `grep` (read helpers + compound-chain glue, broadened 2026-05-02) |
| Read-only shell tools | `rg:*`, `fd:*`, `wc:*`, `sort:*`, `uniq:*`, `cut:*`, `diff:*`, `file:*`, `stat:*`, `du:*`, `df:*`, `date:*`, `env:*`, `printenv:*`, `pbcopy`, `pbpaste`, `open:*` (added 2026-05-07 — Tier 1 widening) |
| Text-processing tools | `sed:*`, `awk:*` (added 2026-05-07 — Tier 2 widening; same blast radius as the existing `Edit/Write` grants on the same paths) |
| File ops (broader) | `cp ~/Desktop/**`, `cp ~/.claude/**`, `mv ~/Desktop/**`, `mv ~/.claude/**` (added 2026-05-07 — Tier 2; scoped to paths Edit/Write already covers. Narrow per-subdir `mv` entries above are now redundant but kept for now.) |
| Scoped find | `find ~/.claude:*`, `find ~/Desktop:*` (added 2026-05-02) |
| Process control | `pkill` |
| Versions | `node --version`, `npm --version`, `python --version`, `python3 --version` |
| GitHub CLI | `gh:*` (broadened 2026-05-01 — replaces 6 narrow `gh pr/issue/run` entries; mutating subcommands like `gh pr create/merge/close` and `gh issue close` still gated in `ask`) |
| Local dev | `npm run:*`, `npm test:*`, `npx tsc:*`, `npx vitest:*`, `npx jest:*`, `npx playwright:*` (broadened 2026-05-07 — replaces narrow `npm run dev/build/lint`. Blanket `npx:*` deliberately not added: same supply-chain reasoning as the narrow `agent-browser` install entries.) |
| `agent-browser` install (CE setup) | `Bash(CI=true npm install -g agent-browser*)`, `Bash(agent-browser install*)`, `Bash(npx skills add https://github.com/vercel-labs/agent-browser*)` (added 2026-05-02 — narrow-scoped supply-chain authorization for `/ce:ce-setup` autonomous installs of agent-browser + vercel-labs/agent-browser skill; doesn't widen to `npm install -g *` or `npx skills add *`) |
| Local navigation | `cd:*` (broadened 2026-05-02 from `cd ~/Desktop/*`) |
| File ops in Desktop | `Edit / Write / MultiEdit / NotebookEdit` on `~/Desktop/**` and `~/Desktop/**/.claude/**` |
| Local scripts | `chmod +x ~/Desktop/**`, `bash ~/Desktop/**` |
| `.claude` reads | `Read(~/.claude/**)`, `Bash(ls ~/.claude/**)` (added 2026-05-02) |
| LaunchAgents reads | `Read(~/Library/LaunchAgents/**)`, `Bash(ls ~/Library/LaunchAgents/**)` (added 2026-05-02) |
| launchctl read-only | `launchctl list:*`, `launchctl print:*`, `launchctl print-disabled:*` (added 2026-05-02 — `load / unload / bootstrap / bootout` remain gated) |
| macOS tmpdir reads | `Bash(ls /var/folders/**)`, `Read(/var/folders/**)` (added 2026-05-02) |
| Skills CRUD | `Edit / Write / MultiEdit` on `~/.claude/skills/**`; `Bash(rm)`, `Bash(rm -rf)`, `Bash(mv)` scoped to `~/.claude/skills/**` (added 2026-05-02) |
| Agents CRUD | `Edit / Write / MultiEdit` on `~/.claude/agents/**`; `Bash(rm)`, `Bash(mv)` scoped to `~/.claude/agents/**` (added 2026-05-02) |
| Commands CRUD | `Edit / Write / MultiEdit` on `~/.claude/commands/**`; `Bash(rm)`, `Bash(mv)` scoped to `~/.claude/commands/**` (added 2026-05-02) |
| Hooks CRUD | `Edit / Write / MultiEdit` on `~/.claude/hooks/**`; `Bash(bash ~/.claude/hooks/**)`, `Bash(chmod +x ~/.claude/hooks/**)`, `Bash(rm ~/.claude/hooks/**)` (added 2026-05-02) |
| Architecture CRUD | `Edit / Write / MultiEdit` on `~/.claude/architecture/**`; `Bash(mv)`, `Bash(rm)` scoped to `~/.claude/architecture/**` (added 2026-05-02 — closes arch-implementer cron coverage gap for RG dependency-graph regen and other architecture-scope writes) |
| CLAUDE.md edits | `Edit / Write / MultiEdit` on `~/.claude/CLAUDE.md` (added 2026-05-02 — arch-implementer charter §"CLAUDE.md edits are normal in-scope work" post 2026-05-02 invocation-path revision) |
| settings.json edits | `Edit / Write / MultiEdit` on `~/.claude/settings.json` (added 2026-05-02 — closes SJ-finding cron coverage gap; mirror to permissions/{allow,deny,ask}.md still required by evolution-protocol) |
| Hook-construction tooling | `Bash(jq:*)`, `Bash(printf:*)` (added 2026-05-02) |
| Inbox writes | `Write` and `Edit` on `~/.claude/inbox/**` (added 2026-05-01 for the launchd Memory Agent runner) |
| Personal context writes | `Edit / Write / MultiEdit` on `~/personal-context/**` (added 2026-05-01 for Memory Agent autonomous-write carve-outs) |
| Personal-context reads (audit) | `Read(~/personal-context/**)`, `Bash(find ~/personal-context:*)`, `Bash(grep -rn * ~/personal-context*)` (added 2026-05-07 — closes RG-01 from defrag-agent's 2026-05-07 audit. The 2026-05-01 Edit/Write grants didn't extend to Bash subprocess invocations like grep, so defrag's voice-rule walks across `~/personal-context/` were getting blocked at the path-scope layer despite the unscoped `Bash(grep:*)` allow.) |
| Auto-memory writes | `Edit / Write / MultiEdit` on `~/.claude/projects/-Users-yourname-Desktop/memory/**` (added 2026-05-01) |
| Supabase MCP reads | `list_tables`, `list_branches`, `list_organizations`, `list_projects`, `list_migrations`, `list_extensions`, `list_edge_functions`, `get_advisors`, `get_cost`, `get_edge_function`, `get_logs`, `get_organization`, `get_project`, `get_project_url`, `get_publishable_keys`, `search_docs`, `generate_typescript_types`, `confirm_cost` (added 2026-05-07 — read-only metadata + docs. All writes — `apply_migration`, `execute_sql`, `delete_branch`, `deploy_edge_function` — stay on `ask`.) |
| Supabase MCP reads (local stdio) | Same 18 read tools mirrored under `mcp__supabase__*` prefix (added 2026-05-09 — local stdio Supabase MCP via `claude mcp add supabase --scope user`. Single PAT covers all orgs the operator is a member of including Project Alpha. Tool surface identical to claude.ai connector; only the prefix differs.) |
| Cloudflare MCP reads | `accounts_list`, `d1_database_get`, `d1_databases_list`, `hyperdrive_config_get`, `hyperdrive_configs_list`, `kv_namespace_get`, `kv_namespaces_list`, `r2_bucket_get`, `r2_buckets_list`, `migrate_pages_to_workers_guide`, `search_cloudflare_documentation`, `workers_get_worker`, `workers_get_worker_code`, `workers_list` (added 2026-05-07. `set_active_account` deliberately not added — state-mutating in session. `d1_database_query` stays on `ask` — runs SQL on prod data.) |
| Vercel MCP reads | `check_domain_availability_and_price`, `get_deployment`, `get_deployment_build_logs`, `get_project`, `get_runtime_logs`, `get_toolbar_thread`, `list_deployments`, `list_projects`, `list_teams`, `list_toolbar_threads`, `search_vercel_documentation` (added 2026-05-07. `web_fetch_vercel_url` deliberately not added — fetches arbitrary URLs through Vercel auth, page contents could be sensitive.) |
| Google Drive MCP reads | `download_file_content`, `get_file_metadata`, `get_file_permissions`, `list_recent_files`, `read_file_content`, `search_files` (added 2026-05-07. Writes — `copy_file`, `create_file` — not added.) |
