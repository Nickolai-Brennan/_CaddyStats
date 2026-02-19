# Database Schema – Caddy Stats

Database: PostgreSQL  
Strategy: Dual-schema architecture  

Schemas:
- app_schema  → content + authentication
- golf_schema → analytics + stats engine

Design Goals:
- Read-heavy optimization
- Strict foreign key integrity
- Indexed high-frequency queries
- JSONB only where flexibility required
- No unindexed join paths

---

# 1️⃣ app_schema (Content System)

Purpose:
Handles all site data via GraphQL.

File:
database/schemas/app_schema.sql

---

## 1.1 roles

role_id (PK)
name (UNIQUE)
description
created_at

Index:
UNIQUE(name)

---

## 1.2 users

user_id (PK)
email (UNIQUE)
password_hash
role_id (FK → roles)
is_active
created_at
updated_at

Indexes:
UNIQUE(email)
INDEX(role_id)

---

## 1.3 authors

author_id (PK)
user_id (FK → users)
display_name
bio
avatar_url
twitter_handle
created_at

Indexes:
INDEX(user_id)

---

## 1.4 categories

category_id (PK)
name
slug (UNIQUE)
description
created_at

Indexes:
UNIQUE(slug)

---

## 1.5 tags

tag_id (PK)
name
slug (UNIQUE)
created_at

Indexes:
UNIQUE(slug)

---

## 1.6 posts

post_id (PK)
title
slug (UNIQUE)
excerpt
status (draft, review, published)
author_id (FK → authors)
category_id (FK → categories)
blocks JSONB
published_at
created_at
updated_at

Indexes:
UNIQUE(slug)
INDEX(status)
INDEX(published_at)
INDEX(author_id)
GIN INDEX(blocks)

Notes:
blocks stores editor structure:
- paragraph
- heading
- stat_embed
- chart
- table
- image

JSONB used because block types evolve.

---

## 1.7 post_tags (junction)

post_id (FK → posts)
tag_id (FK → tags)

Composite PK(post_id, tag_id)

Indexes:
INDEX(tag_id)

---

## 1.8 revisions

revision_id (PK)
post_id (FK → posts)
blocks JSONB
editor_id (FK → users)
created_at

Indexes:
INDEX(post_id)

Purpose:
Immutable version history.

---

## 1.9 seo_meta

seo_id (PK)
post_id (FK → posts)
meta_title
meta_description
og_image
canonical_url
json_ld JSONB
created_at

Indexes:
UNIQUE(post_id)

---

## 1.10 media_library

media_id (PK)
file_url
file_type
file_size
uploaded_by (FK → users)
created_at

---

## 1.11 newsletters

newsletter_id (PK)
email (UNIQUE)
is_active
created_at

Index:
UNIQUE(email)

---

# 2️⃣ golf_schema (Analytics Engine)

Purpose:
Structured golf performance + betting + projections.

File:
database/schemas/golf_schema.sql

---

## 2.1 golfers

golfer_id (PK)
name
country
birth_date
handedness
created_at

Index:
INDEX(name)

---

## 2.2 tournaments

tournament_id (PK)
name
season_year
start_date
end_date
course_id (FK → courses)

Indexes:
INDEX(season_year)
INDEX(start_date)

---

## 2.3 courses

course_id (PK)
name
location
par
yardage
created_at

Index:
INDEX(name)

---

## 2.4 historical_results

result_id (PK)
golfer_id (FK → golfers)
tournament_id (FK → tournaments)
finish_position
total_score
round_scores JSONB
strokes_gained_total
created_at

Indexes:
INDEX(golfer_id)
INDEX(tournament_id)
INDEX(golfer_id, tournament_id)

---

## 2.5 event_stats

stat_id (PK)
golfer_id
tournament_id
driving_distance
greens_in_regulation
strokes_gained_off_tee
strokes_gained_approach
strokes_gained_putting
created_at

Indexes:
INDEX(golfer_id)
INDEX(tournament_id)

---

## 2.6 betting_odds

odds_id (PK)
golfer_id
tournament_id
market_type (outright, top10, matchup)
sportsbook
odds_decimal
implied_probability
created_at

Indexes:
INDEX(golfer_id, tournament_id)
INDEX(market_type)

---

## 2.7 projections

projection_id (PK)
golfer_id
tournament_id
model_version
projected_score
win_probability
top10_probability
confidence_score
created_at

Indexes:
INDEX(golfer_id, tournament_id)
INDEX(model_version)

---

## 2.8 fantasy_scoring

fantasy_id (PK)
golfer_id
tournament_id
projected_points
actual_points
salary
value_score
created_at

Indexes:
INDEX(golfer_id, tournament_id)

---

# 3️⃣ Views

Location:
database/views/

---

## leaderboard_view

Aggregates:
- finish position
- strokes gained
- rank movement

---

## rolling_form_view

Aggregates last N events:
- avg finish
- avg strokes gained
- trend delta

---

## betting_edge_view

Calculates:
edge = projected_probability - implied_probability

Indexed on:
tournament_id

---

## course_history_view

Aggregates golfer performance by course_id

---

# 4️⃣ Materialized Views

Location:
database/materialized_views/

---

## leaderboard_mv
## projections_summary_mv
## rolling_form_mv

Refresh Strategy:
- Manual refresh pre-tournament
- Optional scheduled job (cron or Celery)

---

# 5️⃣ Indexing Strategy

Rules:

- All FK columns indexed
- Composite index for frequent joins
- GIN index for JSONB blocks
- No wildcard text scans without index
- Query plan must be reviewed before production

---

# 6️⃣ JSONB Usage Policy

Allowed:
- posts.blocks
- seo_meta.json_ld
- historical_results.round_scores

Not allowed:
Core relational metrics

Reason:
Analytics queries must remain indexable and structured.

---

# 7️⃣ Performance Targets

Local API:
<150ms

Cached REST:
<100ms

Heavy aggregate:
<250ms (materialized)

---

# 8️⃣ Migration Strategy

- Alembic for app_schema
- Versioned SQL files for golf_schema
- No destructive migrations without backup
- Nightly pg_dump in production
