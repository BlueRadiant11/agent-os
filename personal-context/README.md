# personal-context/ — the memory layer

This directory is the Agent OS's persistent memory: who you are, how you work, what you're building, and what you've decided. The system's skills, agents, and SessionStart hooks read from here. Nothing works well until you fill it in.

Every file follows the single-page rule: ≤100 lines, one topic per file, YAML frontmatter with `name`, `description`, `type`, `canonical`, `owner`, `last_verified`.

## Layout

- `identity.md` — who you are. Auto-injected every session.
- `decision-log.md` — life-level decisions (identity/trajectory scale). Auto-injected.
- `how-i-work.md` — validated positive patterns about your working style. Auto-injected.
- `shelf.md` — explicitly paused items with unshelve triggers. Auto-injected.
- `work-style/` — voice canon, hard rules, format rules, coding workflow. Auto-injected.
- `projects/` — one page per project. Read on demand.
- `identity/` — relationships, deeper identity facts. Read on demand.
- `goals/` — one page per active goal or protocol. Read on demand.
- `decisions/` — tactical per-domain decision logs. Read on demand.
- `domain-knowledge/` — reference material about domains you work in. Read on demand.
- `auto-memory/` — feedback and correction entries routed by /jot.

Each subdirectory contains an EXAMPLE file showing the expected shape. Replace the content, keep the structure.
