---
description: Executive briefing — single-repo or cross-project CEO dashboard (local git + Vercel + Supabase + Cloudflare)
allowed-tools: Bash(~/.claude/commands/brief.sh), mcp__claude_ai_Vercel__list_projects, mcp__claude_ai_Vercel__list_deployments, mcp__claude_ai_Vercel__list_teams, mcp__claude_ai_Supabase__list_projects, mcp__claude_ai_Supabase__list_organizations, mcp__claude_ai_Supabase__get_advisors, mcp__claude_ai_Cloudflare_Developer_Platform__accounts_list, mcp__claude_ai_Cloudflare_Developer_Platform__workers_list
---

!`~/.claude/commands/brief.sh`

---

**If MODE is SINGLE-REPO**, ignore all MCP steps. Produce a briefing with exactly these sections:

1. **Branch status** — one line: branch, ahead/behind upstream, clean or dirty.
2. **In flight** — 3-6 bullets on what the staged + unstaged changes actually *do*, grouped by apparent intent, not by file. Skip lockfiles and pure formatting unless they're the whole point.
3. **Open questions** — things that look half-finished or risky: TODOs, missing tests, debug prints, commented-out code, conflict markers, same file in both staged and unstaged.
4. **Recommended next action** — one sentence.

Under 200 words total. No preamble.

---

**If MODE is OUTER-LEVEL**, first fetch remote state. In a SINGLE message, call these in parallel (read-only, no writes ever):

- `mcp__claude_ai_Vercel__list_projects` (limit 20)
- `mcp__claude_ai_Supabase__list_projects`
- `mcp__claude_ai_Cloudflare_Developer_Platform__accounts_list`

Then, in a second parallel batch, for each remote project whose name plausibly matches a local repo (see correlation rule), fetch:
- `mcp__claude_ai_Vercel__list_deployments` (limit 3, newest first) for the matched Vercel project
- `mcp__claude_ai_Supabase__get_advisors` (type: `security`) for the matched Supabase project
- `mcp__claude_ai_Cloudflare_Developer_Platform__workers_list` once, for the active account

If any MCP call errors or is unauthorized, note it briefly under the relevant section — do not abort.

**Correlation rule:** match local repo name to remote project name case-insensitively after stripping these suffixes from both sides: `-app`, `-web`, `-site`, `-frontend`, `-backend`, `-api`, `-v2`, `-v3`. A match is good if the normalized strings are equal OR one contains the other.

Produce a briefing with exactly these sections (omit any that would be empty except #1 and #7):

1. **In flight** — local dirty repos + any Vercel deploys building or failed in last 24h. One line per row: `repo — branch (dirty N) — intent guess — deploy: <state>` (drop deploy clause if no match).
2. **Unpushed** — repos ahead of upstream locally; `repo — N ahead — last commit subject`.
3. **Production health** — Supabase security advisors (highest severity first), Vercel deploy failures not in #1, Cloudflare Worker anomalies.
4. **Recently shipped** — clean local + commit OR successful deploy within last 14 days.
5. **Idle** — local repos with no commits in 30+ days. Names only, comma-separated.
6. **Untracked deploys** — active Vercel/Supabase/CF projects with no matching local repo.
7. **Recommended next action** — one sentence: which project to open first and why.

Under 300 words total. No preamble. Sort #1 and #4 by recency.
