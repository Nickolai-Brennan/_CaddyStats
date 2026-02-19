# UI/UX Design System – Caddy Stats

Frontend: React + Vite + TypeScript  
UI: Tailwind  
Data UI: TanStack Query + TanStack Table

This document defines the visual + component system for Caddy Stats.
It is a build contract: tokens → components → layouts → templates.

---

# 1️⃣ Design Principles (Executable)

1. Information density without clutter
2. Tables and charts are first-class citizens
3. Consistent layout across Home / Archive / Article
4. Fast perceived load (skeleton states + progressive hydration)
5. Mobile-first, then expand
6. Accessibility AA minimum

---

# 2️⃣ Layout System

## 2.1 Canonical Grid (Desktop)

Primary layout for magazine/blog view:

- Left rail: 20% (Ads / promos / tools)
- Middle:   50% (Content feed / article)
- Right:    30% (Social, trending, widgets)

Implementation:
- CSS grid
- Responsive breakpoints collapse rails

Mapping:
frontend/src/layouts/
- MainLayout.tsx
- MagazineLayout.tsx
- ArticleLayout.tsx

---

## 2.2 Breakpoints

Tailwind breakpoints used:
- sm: 640
- md: 768
- lg: 1024
- xl: 1280
- 2xl: 1536

Rules:
- <lg: rails collapse beneath content
- <md: single column stack
- mobile: sticky header, no sticky sidebars

---

## 2.3 Sticky Rules

Allowed sticky elements:
- Header (global)
- Article sidebar (desktop only)
- Table header row (archive)

Implementation:
- position: sticky
- top offset equals header height token

---

# 3️⃣ Brand Tokens (Tailwind)

Location:
frontend/src/styles/globals.css
frontend/tailwind.config.js

## 3.1 Colors (Token Names)

Base tokens (do not hardcode hex in components):

--cs-bg
--cs-surface
--cs-surface-2
--cs-text
--cs-text-muted
--cs-border
--cs-accent
--cs-accent-2
--cs-success
--cs-warning
--cs-danger

Rules:
- components consume semantic tokens
- dark mode swaps tokens only

---

## 3.2 Typography

Fonts:
- Display: Barlow Condensed (headlines, numbers)
- Body: Inter (paragraphs, UI labels)

Scale (Tailwind mapping):
- Display H1: text-4xl lg:text-5xl font-semibold tracking-tight
- H2: text-2xl lg:text-3xl font-semibold
- H3: text-xl font-semibold
- Body: text-base leading-7
- Small: text-sm leading-6
- Micro: text-xs uppercase tracking-wide

Rules:
- Headlines max 2 lines in cards
- Numbers use tabular-nums for tables

---

## 3.3 Spacing & Radius

Spacing:
- Use Tailwind spacing scale only (2, 3, 4, 6, 8, 10, 12, 16)

Radius:
- Cards: rounded-2xl
- Buttons/inputs: rounded-xl
- Chips/badges: rounded-full

Shadow:
- Cards: shadow-sm
- Elevated: shadow-md

---

# 4️⃣ Component System

Directory:
frontend/src/components/

Structure:
- components/ui (primitives)
- components/layout (header/footer/sidebar/ticker)
- components/article (article-specific)
- components/stats (tables/widgets)
- components/charts (chart wrappers)

---

## 4.1 UI Primitives (components/ui)

### Button
File:
components/ui/Button.tsx

Variants:
- primary
- secondary
- ghost
- destructive

Sizes:
- sm
- md
- lg

Rules:
- consistent padding per size
- focus-visible ring required
- disabled states required

---

### Card
File:
components/ui/Card.tsx

Rules:
- always uses surface token
- default padding p-4
- supports header/body/footer slots

---

### Badge
File:
components/ui/Badge.tsx

Variants:
- neutral
- success
- warning
- danger
- accent

Use cases:
- confidence tier
- status labels
- tag chips

---

### Input
File:
components/ui/Input.tsx

Rules:
- consistent label + error slot
- aria-invalid support

---

## 4.2 Layout Components (components/layout)

### Header
File:
components/layout/Header.tsx

Includes:
- logo
- nav
- search
- account menu

Behavior:
- sticky top
- compact on scroll (future enhancement)

---

### Footer
File:
components/layout/Footer.tsx

Includes:
- site links
- Strik3Zone directory link
- legal

---

### Sidebar (Left Rail)
File:
components/layout/Sidebar.tsx

Contains:
- ads
- newsletter CTA
- premium CTA
- featured tools

---

### Social Rail (Right Rail)
File:
components/layout/SocialRail.tsx (or SidebarRight.tsx)

Contains:
- trending posts
- trending tags
- social embeds

---

### Ticker
File:
components/layout/Ticker.tsx

Purpose:
- scrolling headline ticker
- optional live leaderboard headline

Data:
- GraphQL: top headlines
- REST: leaderboard summary (optional)

---

## 4.3 Article Components (components/article)

### ArticleCard
Card used in lists.

Props:
- title
- slug
- author
- date
- excerpt
- tags
- image

Rules:
- title clamp
- excerpt clamp
- tag chips max 3 shown

---

### AuthorCard
Shown on article page under title.

Props:
- author info
- social links
- credentials (future)

---

### RelatedPosts
Shows contextual internal links.

Rule:
- must bias same category + shared tags

---

## 4.4 Stats Components (components/stats)

### LeaderboardTable
TanStack Table wrapper.

Rules:
- sticky header on desktop
- sortable columns
- pagination or virtual scroll if large

---

### PlayerTrendTable
Used in player deep dive and trends pages.

---

### ProjectionTable
Used in tournament preview and dashboard.

---

## 4.5 Charts (components/charts)

Chart wrappers must:
- accept typed datasets
- use responsive containers
- render skeleton on load
- never block page render

Charts:
- LineChart.tsx (rolling form)
- BarChart.tsx (category comparison)
- Heatmap.tsx (betting edges)

---

# 5️⃣ View Templates & UX Rules

Directory:
frontend/src/views/
frontend/src/templates/

## 5.1 Home (Magazine View)

Composition:
- Hero story
- Recent story list
- Category sections
- Ticker
- Sidebar ads
- Social/trending

Files:
views/home/HomePage.tsx
layouts/MagazineLayout.tsx

---

## 5.2 Archive (List View)

Composition:
- Filter bar
- Search
- Table list (TanStack)
- Pagination

Files:
views/archive/ArchivePage.tsx

---

## 5.3 Article View

Composition:
- Title + meta
- Author card
- Block renderer
- Sticky sidebar (top stories / ads)
- Related posts

Files:
views/article/ArticlePage.tsx
layouts/ArticleLayout.tsx
editor/BlockRenderer.tsx

---

# 6️⃣ Editor UI Guidelines

Directory:
frontend/src/editor/

Rules:
- block toolbar visible on focus
- drag handle on block hover (desktop)
- slash command menu support
- live SEO preview panel
- autosave drafts (future)

Blocks must render with:
- consistent spacing between blocks
- max content width token
- sanitized HTML output

---

# 7️⃣ Accessibility Standards

Minimum:
- WCAG AA for contrast
- keyboard navigable menus
- focus-visible outlines
- skip-to-content link
- aria labels on icon buttons
- table headers properly labeled

---

# 8️⃣ Loading States & Perceived Performance

Rules:
- skeleton UI for cards/tables
- optimistic updates on editor save
- progressive hydration for stat embeds

TanStack Query:
- staleTime tuned per endpoint
- keepPreviousData for archive paging

---

# 9️⃣ Implementation Checklist (Phase Gate)

- [ ] Define Tailwind tokens in config
- [ ] Create UI primitives (Button/Card/Badge/Input)
- [ ] Implement layouts (Main/Magazine/Article)
- [ ] Implement view shells (Home/Archive/Article)
- [ ] Implement table wrappers (Leaderboard/Projections)
- [ ] Implement editor block renderer styling
- [ ] Add accessibility baseline (focus/aria)
- [ ] Add skeleton loading components
