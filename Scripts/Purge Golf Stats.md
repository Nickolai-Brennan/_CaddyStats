---

## 2) `docs/GOLF_STATS_PURGE.md`

```md
# Golf Stats Purge Plan (Repo + DB)

Goal: Ensure this repo contains NO golf stats database objects, migrations, schema types, or code modules other than an optional external Stats API client.

---

## A) Repo Purge (Files + Imports)

### A1) Search + delete golf-stats folders/modules
Common offenders to delete or refactor:
- backend/db/stats.py
- backend/services/stats/*
- any folder named: stats, golf, betting, datagolf, odds, leaderboard
- any old migration files referencing golf_stats schema or stats entities

### A2) Global search for forbidden tokens
Run from repo root:

```bash
# ripgrep is ideal
rg -n "golf_stats|leaderboard|tournament|strokes_gained|betting|odds|datagolf" .

# also check schema aliases from older work
rg -n "schema:\s*stats|schema:\s*content|golf data|warehouse" .

If matches exist:

If it’s DB related → delete/replace with website_content only

If it’s API related → ensure it’s ONLY in stats_api_client and thin resolvers


A3) Remove old references in code

Remove any SQLAlchemy metadata with schema="golf_stats"

Remove GraphQL types/queries/mutations for stats

Remove REST endpoints for stats in this repo (unless it’s a proxy to external API)


A4) Package hygiene

Remove unused dependencies added for stats ETL (pandas, numpy, etc.) if not needed

Remove cron/worker jobs that refresh stats materialized views (no longer applicable)



---

B) DB Purge (Postgres)

B1) Drop schema if it exists (SAFE + explicit)

Only run if you accidentally created it in this database:

DROP SCHEMA IF EXISTS golf_stats CASCADE;

B2) Confirm it’s gone

\dn

B3) Confirm there are no stats tables lingering elsewhere

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('website_content','public')
ORDER BY table_schema, table_name;

Expected: no rows.


---

C) Migration Cleanup

C1) Ensure migrations folder is webapp-only

Migrations should only contain:

extensions / schema / triggers

website_content tables

website_content indexes/search

seeds


C2) Remove any legacy stats migrations

Delete any file that creates:

golf_stats schema

golfers/tournaments/odds/etc tables

stats views/materialized views



---

D) Prevent Regression (Guardrails)

D1) CI “stats-free” check

Add a simple CI step that fails if forbidden tokens appear:

rg -n "golf_stats|strokes_gained|betting_odds|datagolf|leaderboard_entries" . && exit 1 || exit 0

D2) DB smoke test

On CI, after migrations:

assert golf_stats schema does not exist:


SELECT to_regnamespace('golf_stats') IS NULL AS golf_stats_absent;

Expected: true.


---

E) Final Purge Gate

✅ Purge is complete when:

rg finds no forbidden tokens (except optional stats_api_client)

database contains no golf_stats schema

migrations contain only website_content objects

GraphQL contract contains no golf stats types/queries by default


---

## If you want it automated
If you paste your repo root paths (backend/frontend folders), I can give you a **single “purge script”** (bash + PowerShell) that:
- runs the `rg` scans,
- removes known folders,
- and prints a final “PASS/FAIL” report.
