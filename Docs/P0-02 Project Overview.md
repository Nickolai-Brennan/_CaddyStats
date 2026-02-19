# Project Overview – Caddy Stats

Parent Company: Strik3Zone  
Owner: Nick  
System Type: Analytics Media Platform  
Stack: React + Vite + TanStack + FastAPI + Strawberry GraphQL + PostgreSQL  

---

# 1. Executive Definition

Caddy Stats is a data-first golf analytics publishing platform designed to unify:

- Editorial content
- Structured statistical data
- Betting intelligence
- Fantasy valuation tools
- SEO automation
- AI-assisted narrative generation

It is built as a modular SaaS-grade architecture that separates:

App Data → GraphQL layer  
Golf Data → PostgreSQL analytics layer  

The goal is long-term scalability into premium dashboards and predictive modeling tools.

---

# 2. Problem Statement

Current golf media platforms suffer from:

1. Narrative without structured data  
2. Data without editorial interpretation  
3. Betting insights without transparency  
4. Fantasy analysis without historical validation  
5. Poor SEO architecture for evergreen content  

Caddy Stats solves this by:

- Structuring data at the database level
- Embedding stats directly into editorial blocks
- Tracking model accuracy over time
- Building category + tag-based SEO clusters
- Creating reusable stat-driven templates

---

# 3. Core Product Layers

## Layer 1 – Editorial Content Engine

Location:
- `/frontend/src/editor`
- `/backend/app/graphql`
- `app_schema.posts`

Features:
- Block-based editor
- Revision history
- Draft/publish workflow
- SEO injection
- Template system

---

## Layer 2 – Golf Analytics Database

Location:
- `/database/schemas/golf_schema.sql`

Contains:
- golfers
- tournaments
- courses
- historical_results
- projections
- betting_odds
- fantasy_scoring

Optimized with:
- Composite indexes
- Materialized views
- Read-heavy query design

---

## Layer 3 – Stats Delivery API

REST endpoints:
- /api/leaderboard
- /api/player-trends
- /api/projections
- /api/betting-edges
- /api/course-history

Purpose:
Serve heavy analytical payloads separate from GraphQL.

---

## Layer 4 – SEO & Discoverability Engine

Automates:
- Title/meta injection
- JSON-LD schema
- Canonical URLs
- Sitemap generation
- Category landing pages
- Author pages
- Tag clusters

Location:
- `/frontend/src/utils/seo.ts`
- `/backend/app/services/post_service.py`

---

## Layer 5 – AI-Enhanced Publishing

AI is used for:
- Narrative drafting
- Stat explanation
- Headline optimization
- Newsletter generation
- Accuracy reporting

Constraint:
AI must only operate on injected structured data.

No stat hallucination permitted.

---

# 4. Target User Segments

## 1. Sports Bettor
Needs:
- Projection comparison
- Edge analysis
- Historical ROI transparency

API dependency:
- betting_edge_view
- projections

---

## 2. DFS Player
Needs:
- Salary-adjusted projections
- Ownership leverage insights
- Trend breakdowns

Database dependency:
- salary_cap_values
- fantasy_scoring
- rolling_form_view

---

## 3. Fantasy Season Player
Needs:
- Weekly form trends
- Course fit metrics
- Player consistency scoring

Database dependency:
- rolling_form_view
- course_history_view

---

## 4. Premium Analytics Subscriber (Future Phase)
Needs:
- Dashboard access
- Downloadable data
- Model transparency logs
- Accuracy tracking

Future dependencies:
- Redis cache layer
- Premium API routes
- Subscription middleware

---

# 5. Content Pillars (Database-Backed)

All pillars must map to template types.

## Tournament Preview
- Field strength
- Course fit metrics
- Projection summary
- Betting edge overlay

Template:
`TournamentTemplate.tsx`

---

## Player Deep Dive
- Rolling form
- Course history
- Statistical splits
- Odds movement

Template:
`PlayerDeepDiveTemplate.tsx`

---

## Betting Card Analysis
- Edge ranking
- Model confidence
- Implied probability vs projected probability

Template:
`BettingCardTemplate.tsx`

---

## Fantasy Salary Breakdown
- Salary vs projection delta
- Value ranking
- Ownership leverage

Template:
`FantasyTemplate.tsx`

---

## Data Breakdown Article
- Multi-player comparison tables
- Custom stat embeds
- Chart blocks

Template:
`DataBreakdownTemplate.tsx`

---

# 6. Monetization Model

## Phase 1 – Traffic Acquisition
- SEO-driven article clusters
- Newsletter opt-ins
- Affiliate linking

---

## Phase 2 – Premium Layer
- Member-only projections
- Early betting card releases
- Exclusive dashboards

---

## Phase 3 – Data Products
- CSV downloads
- API access tier
- Projection model subscription

---

# 7. Traffic Acquisition Strategy

## Organic SEO
- Tournament-based evergreen URLs
- Player SEO pages
- Course SEO pages
- Category landing clusters

---

## Newsletter Funnel
Workflow:
1. Article CTA
2. Email capture
3. Weekly analytics summary
4. Premium upgrade funnel

---

## Social Distribution
Auto-generated:
- Betting cards
- Projection highlights
- Momentum charts

---

# 8. 12-Month Execution Plan

## Q1
- Complete database schemas
- Implement GraphQL CRUD
- Launch basic blog + templates

## Q2
- Implement stat embeds
- Add materialized views
- Deploy SEO automation

## Q3
- Introduce premium gating
- Add dashboard framework
- Implement subscription logic

## Q4
- Add AI accuracy tracking
- Expand projections model
- Introduce Redis caching
- Performance hardening

---

# 9. Non-Negotiable System Rules

1. No stat hallucination  
2. Every feature maps to schema or endpoint  
3. Every heavy query must be indexed  
4. GraphQL only for app data  
5. REST only for stats  
6. JSONB used only when flexibility required  
7. Build order must be respected  

---

# 10. Success Metrics

Technical:
- API <150ms
- Lighthouse >90
- Indexed queries on high-read tables

Business:
- Newsletter growth
- Organic ranking growth
- Conversion to premium

Model:
- Projection accuracy logged
- Betting ROI tracked
- Confidence scoring validated
