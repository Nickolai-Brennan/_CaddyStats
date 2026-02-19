
📘 PHASE 0 – FOUNDATION & DOCUMENTATION PROMPT

Prompt:

> Act as a technical product architect and documentation lead.
Build complete foundational documentation for the project "Caddy Stats" under Strik3Zone.

Generate the following documents in production-ready Markdown format:

README.md

PROJECT_OVERVIEW.md

PRODUCT_VISION.md

USER_PERSONAS.md

TECH_STACK.md

SYSTEM_ARCHITECTURE.md

DATABASE_SCHEMA.md

API_SPECIFICATION.md

UI_UX_DESIGN_SYSTEM.md

SEO_STRATEGY.md

AI_PROMPT_LIBRARY.md

DEPLOYMENT_GUIDE.md

ADMIN_WORKFLOW.md

FOLDER_STRUCTURE.md


Each document must:

Be structured with clear headers

Include purpose, scope, and implementation notes

Map directly to folders, APIs, or database objects

Reflect React + Vite + TanStack + FastAPI + Strawberry + PostgreSQL


No fluff. No marketing copy. Technical and executable.




---

📘 PHASE 1 – FOLDER & ENVIRONMENT SETUP PROMPT

> Act as a DevOps + Full Stack setup engineer.
Create the complete folder and environment setup for Caddy Stats.

Generate:

Backend FastAPI scaffold

Frontend Vite + React scaffold

Dockerfiles (frontend + backend)

docker-compose.yml

.env.example

Initial GraphQL schema placeholder

Database connection modules


Follow best practices:

Separate content + stats DB schemas

Production-safe Docker builds

Role-ready backend structure

TanStack Query pre-configured


Ensure the system boots locally via Docker without errors.




---

📘 PHASE 2 – DATABASE DEVELOPMENT PROMPT

> Act as a PostgreSQL data architect.

Design and output full SQL migration files for:

Content schema (CMS, users, posts, templates, seo, revisions)

Stats schema (golfers, tournaments, projections, betting_odds, salary, views)


Include:

UUID primary keys

JSONB where flexibility is required

Proper indexing strategy

Materialized views for projections

Full-text search (tsvector)

Triggers for updated_at


Output:

Structured migration files

Performance considerations

Example seed scripts


Prioritize query speed for betting_edge_view and leaderboard_view.




---

📘 PHASE 3 – BACKEND CORE PROMPT

> Act as a FastAPI + Strawberry GraphQL backend architect.

Build:

GraphQL schema types and resolvers

Post CRUD with draft/publish workflow

Role-based access control (admin/editor/contributor)

Revision tracking

Slug generator

REST endpoints for stats

JWT auth

Upload endpoint


Ensure:

Proper dependency injection

Clean service layer separation

Logging + error handling

Production-safe settings loader


Output structured code blocks per file.




---

📘 PHASE 4 – FRONTEND BASE SYSTEM PROMPT

> Act as a senior frontend architect.

Build the full UI base system:

20/50/30 responsive layout

Magazine home view

Archive table view (TanStack)

Article view

Header + Footer

Sidebar (ads + trending)

Dark mode system

GraphQL + REST hooks


Use:

React + TypeScript

TanStack Query

Component abstraction


Prioritize clean component hierarchy and reusability.




---

📘 PHASE 5 – BLOG EDITOR SYSTEM PROMPT

> Act as a rich text editor system architect.

Design a block-based blog editor with:

JSON storage format

Drag-and-drop blocks

Code block

HTML block

Markdown support

Table builder

Chart embed (REST-bound)

Stat query embed

Media upload

SEO panel

Slug preview

Autosave + revisions


Output:

Folder structure

Block registry design

Rendering engine

Integration with backend mutations


It must not degrade into a plain textarea.




---

📘 PHASE 6 – TEMPLATES SYSTEM PROMPT

> Act as a structured publishing system designer.

Build a template blueprint engine:

Tournament Preview template

Player Deep Dive template

Betting Card template

Fantasy Salary template

Data Breakdown template


Templates must:

Pre-populate structured block JSON

Include placeholders

Inject default SEO

Apply default tags/categories


Ensure templates do not retroactively change old posts.




---

📘 PHASE 7 – SEO & META ENGINEERING PROMPT

> Act as a technical SEO engineer.

Implement:

Dynamic title/meta injection

OpenGraph + Twitter Cards

JSON-LD Article schema

Sitemap auto-generation

Robots.txt

Category/tag/author landing pages

Internal linking engine


Ensure:

Drafts are noindex

Canonical URLs enforced

Lighthouse score >90

Core Web Vitals optimized





---

📘 PHASE 8 – AI & MCP PROMPT

> Act as an AI systems architect.

Build:

Prompt injection system

Stats → AI grounding layer

Tournament preview generator

Betting edge explanation engine

Player momentum summarizer

SEO headline optimizer

Newsletter generator

Model accuracy analyzer


Ensure:

No hallucinated stats

All outputs reference injected data

Token logging + usage tracking

Admin AI controls





---

📘 PHASE 9 – HOSTING & INFRASTRUCTURE PROMPT

> Act as a DevOps production engineer.

Design production deployment:

Managed Postgres

SSL

Reverse proxy

CI/CD pipeline

Backup strategy

Monitoring & alerting

Security hardening


Ensure:

GraphQL playground disabled in prod

Rate limiting active

Docker optimized

Rollback strategy documented





---

📘 PHASE 10 – ADMIN & ANALYTICS PROMPT

> Act as an operations dashboard architect.

Build:

Admin panel layout

Post management

Template management

Media library

User management

Traffic dashboard

Betting ROI tracker

Model accuracy dashboard


Ensure:

Role-gated admin routes

CSV export capability

Audit logging





---

📘 PHASE 11 – API INTEGRATIONS PROMPT

> Act as an integration systems engineer.

Implement:

DataGolf ingestion pipeline

Live odds ingestion

Email provider sync

Stripe subscription webhooks

Social share integration

Analytics provider integration


Include:

Retry logic

Health check endpoints

Normalization layer

Failure logging


No direct API responses should bypass normalization.




---

📘 PHASE 12 – SCALE & EXPANSION PROMPT

> Act as a scalability architect.

Design:

Redis caching layer

Premium dashboard expansion

Course database explorer

Historical trend explorer

PWA support

Multi-author expansion

Edge caching via CDN


Ensure:

API latency <100ms cached

Horizontal scalability ready

Monetization dashboards functional





---

📘 PHASE X – BUSINESS PROMPT

> Act as a founder + business strategist.

Build:

Revenue model

Subscription tier definitions

Affiliate strategy

Editorial calendar

KPI dashboard

Break-even model

12-month revenue projection

Legal compliance checklist


Tie all technical systems back to monetization impact.




---