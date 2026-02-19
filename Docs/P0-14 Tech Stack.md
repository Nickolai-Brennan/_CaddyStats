# Tech Stack – Caddy Stats

Parent Company: Strik3Zone
Project: Caddy Stats
System Type: Analytics Media Platform
Architecture Model: Dual-Layer (Content + Analytics)

---

# 1️⃣ High-Level Architecture

Frontend:
React + Vite + TypeScript

Backend:
FastAPI + Strawberry GraphQL

Analytics API:
FastAPI REST Endpoints

Database:
PostgreSQL (Dual Schema Strategy)

Infrastructure:
Docker + NGINX + Managed PostgreSQL + CDN

AI:
Structured prompt injection layer (stat-grounded)

---

# 2️⃣ Frontend Stack

Directory:
frontend/

---

## Core Framework

- React 18+
- Vite (build tool)
- TypeScript (strict mode enabled)

Reason:
Fast dev server + typed architecture + scalable UI.

---

## State & Data Fetching

- TanStack Query (server-state caching)
- TanStack Table (analytics tables)

Rules:
- No raw fetch calls in components
- All API logic abstracted in src/api/ or src/graphql/

---

## Routing

- React Router

Structure:
- routes.tsx defines all routes
- No inline route definitions in components

---

## Styling

- Tailwind CSS
- Token-based theming
- CSS variables for dark mode

Rules:
- No inline hex colors
- Use semantic tokens only

---

## Charting

- Lightweight chart library (e.g. Recharts or similar)

Rules:
- Charts wrapped in typed components
- No direct chart library usage in views

---

## Editor

- Custom block-based editor
- JSONB block storage
- Drag-and-drop block architecture

Directory:
frontend/src/editor/

---

# 3️⃣ Backend Stack

Directory:
backend/

---

## Framework

- FastAPI

Responsibilities:
- Serve GraphQL endpoint
- Serve REST analytics endpoints
- Handle authentication
- Handle rate limiting
- Log all requests

---

## GraphQL

- Strawberry GraphQL

Used For:
- Posts
- Authors
- Templates
- Categories
- Tags
- SEO
- Revisions

Not used for:
- Heavy analytics payloads

---

## REST Layer

FastAPI routers in:
backend/app/api/

Used For:
- Leaderboard
- Projections
- Betting edges
- Player trends
- Course history

Reason:
Better performance for large payloads.

---

## Authentication

- JWT (stateless)
- Role-based permissions

Roles:
- Admin
- Editor
- Contributor
- (Future) Analyst

Files:
backend/app/auth/

---

## ORM / DB Access

- SQLAlchemy (recommended)
- Alembic for migrations (app_schema)

Rules:
- No raw SQL in route handlers
- Heavy queries moved to views

---

# 4️⃣ Database Stack

PostgreSQL 14+

Strategy:
Single instance
Two schemas:

- app_schema
- golf_schema

---

## app_schema

Handles:
- Users
- Posts
- Revisions
- SEO metadata
- Tags
- Categories
- Templates

Accessed via:
GraphQL only

---

## golf_schema

Handles:
- Golfers
- Tournaments
- Results
- Projections
- Betting odds
- Fantasy scoring

Accessed via:
REST endpoints

---

## Performance Strategy

- Composite indexes
- GIN indexes on JSONB
- Materialized views for heavy aggregation
- Query plan review before production

Target:
<150ms standard API response

---

# 5️⃣ Infrastructure Stack

---

## Containerization

Docker:

- frontend.Dockerfile
- backend.Dockerfile
- nginx.conf
- docker-compose.yml

---

## Reverse Proxy

NGINX

Routes:
- / → frontend
- /graphql → backend
- /api → backend

---

## CDN

Used For:
- Static assets
- Images
- Public REST endpoints (short TTL)

---

## Database Hosting

Managed PostgreSQL

Requirements:
- Automated backups
- SSL enforced
- Connection pooling

---

# 6️⃣ AI Stack

AI is not core runtime infrastructure.

AI layer operates via:

- Prompt injection service
- Structured stat payload
- Logged outputs

Future:
ai_explanation_service.py

Rules:
- No hallucinated stats
- Must reference injected JSON
- Log prompt + model version

---

# 7️⃣ Dev Tooling

Frontend:
- ESLint
- Prettier
- TypeScript strict mode

Backend:
- Black formatter
- isort
- mypy (optional)
- pytest

Database:
- Alembic
- SQL migration versioning

---

# 8️⃣ Security Baseline

- JWT auth
- Rate limiting middleware
- Sanitized HTML
- Restricted CORS
- No GraphQL playground in production
- Environment variable isolation
- SSL required

---

# 9️⃣ Observability

Backend:
- Structured logging
- Request timing
- Error logs

Database:
- Slow query logging enabled

Frontend:
- Error boundary
- Performance monitoring (future)

---

# 🔟 Scaling Path

Phase 1:
Single container backend

Phase 2:
Horizontal scaling backend replicas

Phase 3:
Redis caching
Read replicas
Premium API isolation

---

# 11️⃣ Non-Negotiable Stack Rules

1. GraphQL for content only.
2. REST for stats only.
3. No stat calculations in frontend.
4. No business logic inside route files.
5. All heavy queries in views or materialized views.
6. No feature without folder mapping.
7. No untyped frontend data.
8. No production without SSL.
9. No AI output without logging.
10. No schema change without migration.

---

# Stack Summary

Frontend:
React + Vite + TanStack + Tailwind

Backend:
FastAPI + Strawberry

Database:
PostgreSQL (Dual Schema)

Infra:
Docker + NGINX + CDN

AI:
Stat-grounded explanation layer
