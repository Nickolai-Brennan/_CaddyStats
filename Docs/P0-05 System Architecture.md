# System Architecture

**Category:** Architecture  
**Project:** Caddy Stats  
**Owner:** Nick  
**Frontend:** React + Tailwind + TanStack  
**Backend:** FastAPI  
**App Data:** GraphQL  
**Golf Data:** PostgreSQL  

---

## Purpose

Define the end-to-end system design for Caddy Stats, including:
- UI rendering + data fetching strategy
- Backend API boundaries
- Separation of app/content data vs golf/stat data
- How GraphQL and PostgreSQL interact

---

## High-Level Architecture

### Core Principle
- **GraphQL is the interface for all app/site data** (posts, users, templates, editor blocks, SEO meta, media, etc.)
- **PostgreSQL is the source of truth for golf/stat data** (players, tournaments, course history, betting odds, projections, etc.)
- FastAPI owns both:
  - GraphQL server (for app data)
  - REST endpoints (for heavy stats queries when needed)

---

## System Components

### Frontend (React + Tailwind + TanStack)
Responsibilities:
- Render the 3 primary views:
  - Magazine Home
  - Archive/List View
  - Post/Article View
- Provide editor UI for post creation
- Fetch data via:
  - **TanStack Query + GraphQL client** for app content
  - **TanStack Query + REST** for stats-heavy endpoints (optional but recommended)

Key libraries:
- TanStack Query (caching/invalidation)
- TanStack Table (archive view + stat tables)
- Tailwind (design system + layout)

---

### Backend (FastAPI)
Responsibilities:
- Serve GraphQL API for app/site data
- Serve REST endpoints for large stats payloads
- Handle auth, RBAC, logging, rate limits
- Join app content with golf data where needed (server-side composition)

---

## Data Separation Model

### App Data (GraphQL Layer)
**Stored in the “App DB” (PostgreSQL schema or separate database).**

Examples:
- Users / Roles
- Posts / Slugs / Categories / Tags
- Post templates
- Post blocks (editor content JSON)
- SEO metadata
- Media library entries
- Revisions / drafts / publish state

GraphQL handles:
- CRUD
- filtering
- searching
- pagination
- auth rules

---

### Golf Data (PostgreSQL “Golf DB”)
**Stored in PostgreSQL optimized for analytics and performance.**

Examples:
- golfers
- tournaments
- courses
- historical_results
- odds (normalized providers)
- projections
- derived tables / views / materialized views

Access patterns:
- “Read heavy”
- Requires indexes + views + materialized refresh strategy

---

## API Surface

### GraphQL (App API)
Primary usage:
- site content rendering
- editor + templates
- SEO meta + routing
- content discovery (archive filters)

Example operations:
- Query posts, tags, categories
- Mutation create/update post
- Mutation publish post
- Query templates
- Query author pages

---

### REST (Stats API) — Recommended for performance
Primary usage:
- high volume stats payloads
- leaderboard data
- trend tables
- projections
- course history bundles

Example endpoints:
- GET /api/stats/leaderboard?tournamentId=...
- GET /api/stats/player-trends?golferId=...
- GET /api/stats/course-history?courseId=...
- GET /api/stats/projections?tournamentId=...

Reason:
GraphQL is great for app data, but large analytical payloads often perform better as REST (caching + simpler response shapes + fewer resolver joins).

---

## Request Flow

### 1) Home / Magazine View
Frontend:
- GraphQL: featured posts + recent posts + categories + trending tags
Backend:
- GraphQL resolves app content
Optional:
- REST call for live leaderboard widget if included

### 2) Archive / List View
Frontend:
- GraphQL: post list + filters (category/tag/date)
- TanStack Table renders table
Optional:
- REST: “Top stats this week” widgets

### 3) Post / Article View
Frontend:
- GraphQL: post content + blocks + template + SEO meta
Backend:
- If blocks include stat embeds, backend resolves:
  - REST call(s) to stats endpoints
  - or server-side hydration into block payload

---

## Stats Embed Strategy (Important)

Posts can contain blocks like:

- StatTableEmbed { queryId, params }
- ChartEmbed { datasetId, options }
- OddsEmbed { market, tournamentId }

Resolution options:
1. **Client-side resolution**
   - Post loads, then stat blocks fetch their data
   - Pros: fast to build, flexible
   - Cons: more requests per page

2. **Server-side hydration (preferred for SEO/performance)**
   - Backend expands block placeholders into real data before returning post
   - Pros: fewer requests, faster render, better UX
   - Cons: more backend complexity

Recommended:
- Start with client-side resolution
- Upgrade high-traffic templates to server-hydrated blocks later

---

## Database Strategy Options

### Option A (Simple): One Postgres instance, two schemas
- app_schema.*
- golf_schema.*

Pros:
- easiest deployment
- single connection + backups
Cons:
- must enforce schema boundaries carefully

### Option B (Clean): Separate databases
- caddystats_app_db
- caddystats_golf_db

Pros:
- stronger isolation + performance scaling
Cons:
- more infra overhead

---

## Caching

### Frontend
- TanStack Query caches GraphQL and REST responses
- Invalidate on:
  - publish/update post
  - template changes
  - tag/category changes

### Backend
- Use HTTP caching headers for REST stats endpoints
- Materialized views for heavy queries
- Optional Redis later for:
  - leaderboard hot caches
  - rate limiting counters
  - session caching

---

## Security + Permissions

- JWT auth
- RBAC:
  - Admin
  - Editor
  - Contributor
- Draft vs Published content:
  - Public routes only show Published
  - Draft visible to authorized roles only

---

## Implementation Checklist

- [ ] Define app DB schema (content + editor blocks + seo meta)
- [ ] Define golf DB schema (players/events/courses/results/odds/projections)
- [ ] Implement GraphQL (app data) in FastAPI
- [ ] Implement REST endpoints (stats heavy)
- [ ] Implement post block embed resolution strategy
- [ ] Add caching + invalidation rules
- [ ] Add RBAC and publish workflow

---
