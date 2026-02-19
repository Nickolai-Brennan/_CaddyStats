# User Personas – Caddy Stats

Parent Company: Strik3Zone  
Product: Caddy Stats  
System Type: Analytics Media Platform  

This document defines primary user segments and maps each to:

- Required database objects
- Required API endpoints
- Required frontend components
- Conversion triggers
- Retention mechanics

---

# Persona 1 – The Sports Bettor

Profile:
- Follows PGA Tour weekly
- Places tournament outrights and matchup bets
- Consumes odds + projection comparisons
- Values transparency and edge validation

---

## Primary Goals

- Identify positive expected value bets
- Compare market odds vs projection
- Validate model accuracy history
- Track ROI over time

---

## Pain Points

- Narrative-only betting articles
- No confidence transparency
- No historical accuracy validation
- Manual odds comparison across books

---

## System Dependencies

Database:
- golf_schema.projections
- golf_schema.betting_odds
- betting_edge_view
- model_accuracy_log (future)

API:
- GET /api/betting-edges
- GET /api/projections
- GET /api/leaderboard

Frontend:
- BettingCardTemplate.tsx
- Edge ranking table (TanStack)
- Confidence badge component
- ROI tracking chart

Admin:
- ROI logging table
- Model accuracy dashboard

---

## Conversion Triggers

- Edge ranking transparency
- Confidence tier display
- Historical ROI proof
- Early release betting cards (premium)

---

## Monetization Path

Free:
- Basic projections
- Limited edge visibility

Premium:
- Full betting edge ranking
- Model confidence tier
- Historical ROI dashboard
- Early access release

---

# Persona 2 – The DFS Player

Profile:
- Plays DraftKings / FanDuel PGA DFS
- Salary cap constrained
- Values leverage + ownership trends

---

## Primary Goals

- Identify value plays
- Compare salary vs projection
- Find low-ownership leverage
- Evaluate course fit

---

## Pain Points

- Projection lists without salary context
- No ownership trend tracking
- Lack of rolling form integration
- Manual spreadsheet workflows

---

## System Dependencies

Database:
- golf_schema.salary_cap_values
- golf_schema.fantasy_scoring
- rolling_form_view
- course_history_view

API:
- GET /api/projections
- GET /api/player-trends
- GET /api/course-history

Frontend:
- FantasyTemplate.tsx
- Salary delta table
- Ownership leverage badge
- Rolling form line chart

---

## Conversion Triggers

- Salary-adjusted value rankings
- Ownership projection integration
- Leverage scoring
- CSV export (premium feature)

---

## Monetization Path

Free:
- Basic projection + salary table

Premium:
- Advanced leverage scoring
- Ownership projection
- CSV downloads
- Advanced dashboard access

---

# Persona 3 – The Fantasy Season Player

Profile:
- Plays season-long fantasy golf
- Focused on weekly form and course fit
- Less betting oriented, more trend-focused

---

## Primary Goals

- Evaluate weekly momentum
- Analyze course history
- Identify consistency trends

---

## Pain Points

- Static player bios
- No structured course performance view
- No consistency scoring

---

## System Dependencies

Database:
- rolling_form_view
- course_history_view
- historical_results
- player_round_stats

API:
- GET /api/player-trends
- GET /api/course-history
- GET /api/leaderboard

Frontend:
- PlayerDeepDiveTemplate.tsx
- Rolling form chart
- Course history table
- Consistency badge component

---

## Conversion Triggers

- Visual rolling form charts
- Consistency scoring system
- Course fit metric
- Weekly ranking movement summary

---

## Monetization Path

Free:
- Basic player trends

Premium:
- Advanced consistency scoring
- Advanced course fit model
- Weekly tier ranking

---

# Persona 4 – Premium Analytics Subscriber

Profile:
- Advanced bettor or DFS grinder
- Wants downloadable data
- Expects transparency + model versioning

---

## Primary Goals

- Access full projection model
- Compare model versions
- Download structured datasets
- Track accuracy trends

---

## Pain Points

- Opaque projection systems
- No backtesting access
- No model confidence history

---

## System Dependencies

Database:
- model_versions
- projection_runs
- model_accuracy_metrics
- premium_usage_logs
- subscriber_accounts

API:
- GET /api/premium/projections
- GET /api/premium/historical-model
- GET /api/premium/roi-analysis

Frontend:
- /dashboard route
- Accuracy trend graph
- Model comparison panel
- CSV download feature

---

## Conversion Triggers

- Transparent accuracy dashboard
- Model version comparison
- Downloadable structured projections
- Member-only projection confidence tier

---

# Persona Interaction Flow

## Entry Point

Search → SEO cluster → Article Template  
or  
Newsletter link → Tournament Preview  

---

## Engagement Layer

Stat embeds  
Interactive tables  
Trend charts  
Internal linking  

---

## Retention Layer

Newsletter funnel  
Premium teaser modules  
Edge ranking visibility restrictions  
Accuracy transparency  

---

# Cross-Persona Overlap

All personas require:

- Fast stat loading
- Structured projection display
- Mobile responsiveness
- Clear confidence signaling
- Transparent data sourcing

System rule:
Performance and clarity are conversion drivers.

---

# System Implications

Database:
All stat views must be indexed and precomputed.

Backend:
REST endpoints must be optimized for high-read loads.

Frontend:
Templates must support dynamic stat injection.

SEO:
Each persona corresponds to content cluster:
- Betting cluster
- DFS cluster
- Player profile cluster
- Course analysis cluster

---

# Strategic Insight

Personas are not just marketing categories.

They directly determine:

- Required database tables
- Required API endpoints
- Required UI components
- Premium feature gating
- Model transparency standards
