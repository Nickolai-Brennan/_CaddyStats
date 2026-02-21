Connect to Phase 3 backend contracts
Follow the documented design system
Be performance-first
Be Connect
Be scalable for premium dashboards


Below is a production-grade Phase 4 prompt — not generic. This is architect-level and aligned with your stack and scale goals.


---

📘 PHASE 4 – FRONTEND BASE SYSTEM (PRODUCTION PROMPT)

🎯 ROLE

Act as:

Senior React + TypeScript Architect

TanStack Query + Table Specialist

Performance Engineer

UI System Designer

SEO-aware Frontend Engineer


You are building the foundational UI system for Caddy Stats, a production golf analytics platform under Strik3Zone.

This is not a demo blog. This is a scalable analytics publishing platform.


---

🧭 OBJECTIVE

Build the entire frontend base system that will support:

Editorial content

Data-driven golf analytics

Premium dashboards (future)

Monetized ad placements

AI-injected components

SEO-optimized article rendering


This phase establishes:

Layout system

Routing

Core views

Reusable UI architecture

Data hooks

Theming system

Performance baseline



---

🏗 ARCHITECTURE REQUIREMENTS

1️⃣ Layout System

Implement a fully responsive:

20 / 50 / 30 Grid Layout

20% – Left Sidebar (Navigation / categories)

50% – Main Content

30% – Right Sidebar (Trending + Ads + Widgets)


Behavior:

Desktop: 3-column grid

Tablet: 2-column (collapse left nav)

Mobile: Single column stack

Sticky header

Sticky right sidebar

Fluid max-width container (1280px cap)


Must use:

CSS Grid (preferred)

Utility-first system (Tailwind)



---

2️⃣ Required Core Views

A. Magazine Home View

Hero Featured Article

Secondary story grid

“Trending Now” block

Live tournament ticker (top marquee)

Ad injection zones

Lazy-loaded article cards


Performance target:

Lighthouse 90+

Largest Contentful Paint < 2.5s



---

B. Archive View (Table-Based)

Must use:

TanStack Table

Server-side pagination

Sorting

Column filtering

Category filters (PGA, LIV, DFS, Betting, Equipment)

Search input with debounced API call


Table columns:

Title

Author

Category

Publish Date

Reading Time

View Count


Future ready for:

Premium filter gates



---

C. Article View

Requirements:

SEO-ready semantic markup

H1, structured headings

Author card component

Published / updated timestamps

Render EditorJS blocks (JSON → components)

Data tables via TanStack Table

Inline charts placeholder component

Ad injection zones

Internal link component

Related articles block

Sticky sidebar


Must support:

Dark mode

Embedded stats blocks

Structured data injection (schema-ready)



---

3️⃣ Core Components to Build

Layout Components

/components/layout/
  AppLayout.tsx
  Header.tsx
  Footer.tsx
  SidebarLeft.tsx
  SidebarRight.tsx
  Container.tsx

View Components

/views/
  HomeView.tsx
  ArchiveView.tsx
  ArticleView.tsx

Content Components

/components/content/
  ArticleCard.tsx
  AuthorCard.tsx
  TrendingList.tsx
  AdSlot.tsx
  CategoryBadge.tsx
  LiveTicker.tsx

Data Components

/hooks/
  useArticles.ts
  useArticle.ts
  useCategories.ts
  useTrending.ts

All data must use:

TanStack Query

Strict TypeScript interfaces

Error + loading states

Retry logic

Caching strategy



---

4️⃣ Data Integration

Frontend must integrate with:

FastAPI REST endpoints (stats)

Strawberry GraphQL (content)


Separate:

/lib/graphqlClient.ts

/lib/restClient.ts


All hooks must:

Be typed

Support optimistic updates (future)

Handle auth headers

Respect role-based UI rendering



---

5️⃣ Dark Mode System

Implement:

Theme context provider

Tailwind dark class strategy

System preference detection

Persistent localStorage setting

Toggle in header


All components must:

Use design tokens

Avoid hardcoded colors



---

6️⃣ Routing

Use:

React Router v6


Routes:

/
 /archive
 /article/:slug
 /category/:slug

Must support:

Dynamic SEO meta injection (helmet or custom)

404 view

Lazy route loading



---

7️⃣ Performance Requirements

Code splitting

Suspense boundaries

Image lazy loading

Memoized components

Avoid unnecessary re-renders

Tree-shakeable structure



---

8️⃣ SEO Requirements

Must include:

Dynamic title + meta

OpenGraph tags

Twitter cards

Structured data placeholders

Canonical URLs



---

9️⃣ Security & Production Rules

No GraphQL playground exposure

Sanitize any HTML block rendering

Prevent XSS via block renderer

Handle 401 / 403 gracefully

Role-based component visibility



---

📦 REQUIRED OUTPUT FORMAT

When implementing:

1. Overview


2. Component Hierarchy Diagram


3. Folder Structure


4. Full File Code (separated by file path)


5. Type Definitions


6. Hook Architecture


7. Validation Checklist


8. Performance Checklist


9. Monetization Alignment Notes




---

🚫 DO NOT

Build inline spaghetti components

Mix data fetching in UI files

Hardcode API URLs

Ignore loading states

Use any-any types

Skip type safety

Skip folder clarity



---

📈 SCALE MINDSET

This frontend must support:

Premium dashboards later

AI content blocks

Paywalled articles

Interactive golf data tables

Multi-author scaling

10x traffic growth


Build it like a SaaS foundation — not a blog theme.


---

If you’d like, I can now:

Convert this into a reusable /docs/PHASE_4_FRONTEND.md

Or execute it in MODE: ARCHITECT → ENGINEER

Or tighten it further for MCP automation use
