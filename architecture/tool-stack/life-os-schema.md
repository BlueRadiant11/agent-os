---
name: Life OS schema
description: EXAMPLE public-schema reference for a personal-tracker Supabase project (replace with your own schema mirror). Read before any Life OS Supabase query so consumers don't burn round-trips on schema discovery.
type: reference
canonical: true
owner: chief-of-staff
last_verified: 2026-05-07
---

# Life OS schema (Supabase)

Project ID: `YOUR_SUPABASE_PROJECT_ID`. All tables in `public`. Read-only by default; writes gated in `permissions/ask.md`.

Read this file first when querying Life OS. Do not call `list_tables` / `information_schema.columns` on every run.

## Tables

### goals
| column | type | notes |
| --- | --- | --- |
| id | text | primary key |
| title | text | |
| description | text | |
| deadline | date | nullable; the date the goal is due |
| category | text | free-form bucket |
| done | boolean | true when complete (no separate status enum) |
| milestones | jsonb | array of milestone objects |
| created_at | timestamptz | |

### habits
| column | type | notes |
| --- | --- | --- |
| id | text | primary key |
| name | text | habit name |
| log | jsonb | **array of ISO date strings** (`["2026-04-29", ...]`); each element is one log day |
| pillar | text | life pillar tag |
| created_at | timestamptz | |

### moods
| column | type | notes |
| --- | --- | --- |
| id | text | primary key |
| rating | integer | 1–5 (verify range; observed 3–4) |
| note | text | nullable |
| date | date | the day the mood is for |
| time_of_day | text | `morning` / `general` / etc. |
| created_at | timestamptz | |

### tasks
| column | type | notes |
| --- | --- | --- |
| id | text | primary key |
| text | text | task body |
| due | date | nullable |
| priority | text | |
| category | text | |
| done | boolean | |
| recurrence | text | |
| status | text | |
| pillar | text | |
| created_at | timestamptz | |

### events
| column | type | notes |
| --- | --- | --- |
| id | text | primary key |
| title | text | |
| date | date | |
| time | text | |
| description | text | |
| created_at | timestamptz | |

### notes
| column | type | notes |
| --- | --- | --- |
| id | text | primary key |
| text | text | |
| tag | text | |
| date | date | |
| created_at | timestamptz | |

### people
| column | type | notes |
| --- | --- | --- |
| id | text | primary key |
| name | text | |
| birthday | date | |
| frequency | integer | days between intended contact |
| last_contact | date | |
| notes | text | |
| pillar | text | |
| created_at | timestamptz | |

### sleep_data
| column | type | notes |
| --- | --- | --- |
| day | date | **primary key** — the morning the sleep ended (Oura `day` field) |
| bedtime_start | timestamptz | when the operator got into bed |
| bedtime_end | timestamptz | when they woke up |
| latency_seconds | integer | minutes-to-fall-asleep × 60. **Diagnostic metric for the sleep protocol.** |
| total_sleep_seconds | integer | actual sleep, not time in bed |
| efficiency | integer | percent (0–100) of time-in-bed actually asleep |
| average_hrv | float | autonomic recovery signal |
| sleep_score | integer | Oura's composite score (0–100) |
| deep_sleep_seconds | integer | nullable |
| rem_sleep_seconds | integer | nullable |
| source | text | `'oura'` or `'manual'` (CHECK constraint enforced) |
| raw_json | jsonb | full Oura payload for re-derivation |
| created_at | timestamptz | |
| updated_at | timestamptz | |

Populated by Vercel cron `/api/cron/oura-sync` daily at 12:00 UTC (8am EDT). Idempotent on `day` PK — same day re-syncs overwrite. See life-os repo CLAUDE.md § "Sleep Integration (Oura)" for the full pipeline.

## Canonical queries — `/morning` Step 4

Goals due in the next 14 days (incl. up to 3 days overdue):
```sql
SELECT title, deadline, deadline - CURRENT_DATE AS days_left
FROM goals
WHERE done = false
  AND deadline IS NOT NULL
  AND deadline - CURRENT_DATE BETWEEN -3 AND 14
ORDER BY deadline ASC;
```

Mood entries since the window:
```sql
SELECT date, rating, time_of_day, LEFT(COALESCE(note,''), 80) AS note
FROM moods
WHERE date >= '<window-start>'
ORDER BY date DESC, created_at DESC;
```

Habits logged in the window (counts the date strings inside the `log` jsonb array):
```sql
SELECT name,
       (SELECT COUNT(*)
          FROM jsonb_array_elements_text(log) AS dt
         WHERE dt::date >= '<window-start>') AS days_logged_in_window,
       jsonb_array_length(log) AS total_logs
FROM habits
ORDER BY days_logged_in_window DESC, name;
```

Promotion rule: any goal with `deadline - CURRENT_DATE < 3` promotes to BLOCKED ON YOU per `/morning` Step 4.

Last night's sleep + 7-day median latency (sleep protocol diagnostic):
```sql
WITH last_night AS (
  SELECT day, bedtime_start, bedtime_end, latency_seconds,
         total_sleep_seconds, efficiency, average_hrv, sleep_score, source
  FROM sleep_data
  ORDER BY day DESC
  LIMIT 1
),
recent AS (
  SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY latency_seconds) AS p50_latency_seconds
  FROM sleep_data
  WHERE day < CURRENT_DATE
    AND day >= CURRENT_DATE - 7
    AND latency_seconds IS NOT NULL
)
SELECT
  (SELECT row_to_json(ln) FROM last_night ln) AS last_night,
  (SELECT p50_latency_seconds FROM recent) AS latency_p50_7d;
```

Promotion rules consumed by `/morning` Step 4:
- Last night's sleep onset latency > p50 + 10 min → WHERE YOU'RE SLIPPING (coach push voice).
- Last night record exists with `source = 'oura'` → NOTICED bullet (one-line summary).
- No record for last night (no Oura sync, no manual log) → NOTICED bullet (`sleep: no record for last night — ring not synced or not worn`).

## Coaching queries — `/morning` Step 4 (WHERE YOU'RE SLIPPING)

Habits dropped (no log entry in the last 3+ consecutive days):
```sql
WITH last_logs AS (
  SELECT name,
         pillar,
         (SELECT MAX(dt::date) FROM jsonb_array_elements_text(log) AS dt) AS last_logged
  FROM habits
)
SELECT name, pillar, last_logged,
       CURRENT_DATE - last_logged AS days_since
FROM last_logs
WHERE last_logged IS NULL
   OR last_logged <= CURRENT_DATE - 3
ORDER BY days_since DESC NULLS LAST;
```

Goals slipping (deadline 4–7 days out — complement to the <72h BLOCKED ON YOU promotion above so the two windows don't overlap):
```sql
SELECT title, deadline,
       deadline - CURRENT_DATE AS days_left
FROM goals
WHERE done = false
  AND deadline IS NOT NULL
  AND deadline - CURRENT_DATE BETWEEN 4 AND 7
ORDER BY deadline ASC;
```

These feed the WHERE YOU'RE SLIPPING section per `/morning` Step 9. Each row becomes one coach-push line in the brief; voice rules in `/morning` SKILL.md § Step 9.

## Drift detection

If a query against this schema fails with `relation "X" does not exist` or `column "X" does not exist`, the schema has drifted. Re-introspect with `mcp__supabase__execute_sql` (local stdio, preferred) or `mcp__claude_ai_Supabase__execute_sql` (claude.ai connector) against `information_schema.columns`, update this file, bump `last_verified`. Do not silently rewrite the consumer's query.
