📘 README.md

# Caddy Stats

Parent Company: Strik3Zone  
Owner: Nick  
Stack: React + Vite + TanStack + FastAPI + Strawberry GraphQL + PostgreSQL  

---

# 1. Project Definition

Caddy Stats is a structured golf analytics publishing system built as a scalable SaaS-grade media platform.

It consists of:

1. Editorial content engine
2. PostgreSQL-backed golf analytics database
3. GraphQL application API
4. REST analytics API
5. Block-based editor with stat embedding
6. SEO automation engine
7. AI-assisted publishing layer

This is not a basic blog.  
It is a modular analytics infrastructure.

---

# 2. System Architecture Overview

Full documentation: `/docs/SYSTEM_ARCHITECTURE.md`

Core principle:

GraphQL → All app/site data  
REST → All stats-heavy queries  
PostgreSQL → Source of truth  

Schemas:
- app_schema (content system)
- golf_schema (analytics engine)

---

# 3. Repository Structure

See `/docs/FOLDER_STRUCTURE.md`

## Root

caddystats/ ├── frontend/ ├── backend/ ├── database/ ├── docs/ ├── scripts/ ├── docker/ ├── docker-compose.yml ├── .env.example └── README.md

---

## Frontend

Location: `/frontend`

Responsibilities:
- Render UI
- Fetch GraphQL data
- Fetch REST stats
- Cache via TanStack Query
- Provide editor interface
- Render templates

Key directories:

src/ app/ layouts/ views/ components/ editor/ graphql/ hooks/ styles/ utils/

---

## Backend

Location: `/backend`

Responsibilities:
- Serve GraphQL API (content)
- Serve REST endpoints (stats)
- Handle JWT auth
- Enforce RBAC
- Hydrate stat embed blocks
- Manage revision tracking

Key directories:

app/ graphql/ api/ services/ models/ auth/ middleware/

---

## Database

Location: `/database`

Schemas:

app_schema:
- users
- roles
- posts
- revisions
- templates
- seo_meta
- tags
- categories

golf_schema:
- golfers
- tournaments
- courses
- event_stats
- projections
- betting_odds
- fantasy_scoring

Includes:
- indexed tables
- materialized views
- performance views

---

# 4. Data Flow

## Home View
Frontend → GraphQL → posts  
Optional → REST → leaderboard widget  

## Article View
Frontend → GraphQL → post + blocks  
Stat blocks → REST calls  

## Admin Editor
Frontend → GraphQL mutations  
Backend → revision tracking  

---

# 5. API Boundaries

## GraphQL (App API)

Handles:
- Post CRUD
- Template CRUD
- Author CRUD
- SEO injection
- Draft / Publish
- Tag filtering
- Search

Location:
`/backend/app/graphql/`

---

## REST (Stats API)

Handles:
- Leaderboards
- Projections
- Player trends
- Betting edges
- Course history

Location:
`/backend/app/api/`

Reason:
Large analytical payloads perform better with REST + caching.

---

# 6. Authentication & Security

Authentication:
- JWT Bearer tokens

Roles:
- Admin
- Editor
- Contributor

Security Features:
- Rate limiting middleware
- Sanitized HTML rendering
- Role-based access to drafts
- GraphQL playground disabled in production
- Secrets never logged

---

# 7. Caching Strategy

Frontend:
- TanStack Query cache
- Invalidation on publish/update

Backend:
- HTTP cache headers
- Materialized views for projections
- Optional Redis (Phase 12)

Performance Targets:
- <150ms API local
- <100ms cached endpoint
- Indexed foreign keys on all high-read tables

---

# 8. Editor System

Location:
`/frontend/src/editor/`

Features:
- Block-based system
- Markdown support
- Chart blocks
- Stat embed blocks
- Table builder
- Internal link selector
- SEO preview
- Slug auto-generation
- Revision history

Blocks stored as:
JSONB in `app_schema.posts.blocks`

---

# 9. SEO Infrastructure

Automated at publish:

- Title tag injection
- Meta description
- OpenGraph
- Twitter Cards
- JSON-LD Article schema
- Sitemap auto-generation
- Canonical URLs
- Breadcrumb schema

Location:
`/frontend/src/utils/seo.ts`

---

# 10. AI Integration

AI must:

- Never hallucinate stats
- Only use injected structured data
- Log model explanation reasoning
- Separate narrative vs computed values

Prompt library located at:
`/docs/AI_PROMPT_LIBRARY.md`

Future:
- Accuracy tracking system
- Projection confidence scoring

---

# 11. Local Development

## Prerequisites

- Docker
- Node 18+
- Python 3.11+

---

## Setup

1. Clone repository

2. Copy environment file

cp .env.example .env

3. Start containers

docker compose up --build

---

## Services

Frontend:
http://localhost:5173

Backend:
http://localhost:8000

GraphQL:
http://localhost:8000/graphql

Postgres:
localhost:5432

---

# 12. Environment Variables

See `.env.example`

Required:

DATABASE_URL_APP
DATABASE_URL_GOLF
JWT_SECRET
CORS_ORIGINS
ENVIRONMENT

Never commit real secrets.

---

# 13. Deployment Overview

Production includes:

- Frontend container
- Backend container
- Managed PostgreSQL
- NGINX reverse proxy
- SSL termination
- CDN
- Nightly backups
- Centralized logging

See `/docs/DEPLOYMENT_GUIDE.md`

---

# 14. Build Order (Mandatory)

1. Documentation
2. Folder Structure
3. Database Schema
4. Backend Core
5. Frontend Layout
6. Post CRUD
7. Editor
8. Templates
9. SEO Layer
10. Hosting
11. AI
12. Scaling

No phase skipping.

---

# 15. Contribution Rules

Every feature must map to:
- A document
- A folder
- A database object
- An API endpoint

If it does not map — it does not exist.

All schema changes require:
- SQL migration
- Index review
- Performance check

---

# 16. Performance & Scale Philosophy

- Data-first
- Indexed queries
- Materialized analytics
- Modular templates
- Future premium dashboard ready
- Multi-author ready
- AI-improvable aarchitecture
