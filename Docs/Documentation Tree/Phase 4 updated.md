# PHASE 4 – FRONTEND UI BASE SYSTEM (React + Vite + TanStack)

**Purpose:** Ship a production-grade frontend foundation: design system + app shell + composable grid + core views + typed data layer.

**Legend:** `[x]` = complete · `[-]` = scaffolded / partial · `[ ]` = not started

---

## 4.0 Frontend Foundations

### 4.0.1 Confirm core libs wired

- [x] React + Vite + TypeScript
- [x] TanStack Query (QueryClient + retry/staleTime defaults)
- [x] React Router v6 (route map)
- [x] GraphQL client wrapper (`graphql-request` + auth header injection)
- [x] REST client wrapper (`lib/api.ts` fetch helper + base URL)

### 4.0.2 App providers (global wiring)

- [x] QueryProvider (TanStack QueryClient, retry/staleTime policy)
- [x] ThemeProvider (light/dark + localStorage persistence)
- [x] ToastProvider (minimal notifications)
- [x] ErrorBoundary (global + per-route boundary)

### 4.0.3 Global app shell + routing layout

- [x] AppShell (Header + Footer + content container)
- [x] RouteLayout (layout switching per page)
- [x] NotFound route
- [x] ErrorRoute (friendly error screen)

### 4.0.4 Environment + endpoint config

- [x] `VITE_API_HTTP_URL` (REST base URL)
- [x] `VITE_API_GRAPHQL_URL` (GraphQL endpoint)
- [x] Build-time env validation (fails fast in dev if vars missing)

### 4.0.5 Shared types layer (Phase 4 scope only)

- [x] `Post`, `PostListItem` (`types/post.ts`)
- [x] `User`, `UserRole`, `AuthState` (`types/user.ts`)
- [-] `Author`, `Tag`, `Category`, `SeoMeta` (partial stubs)
- [x] Block base types for renderer (minimal)
- [x] `StatsDTO` for one REST demo endpoint (proof-of-pattern)

### 4.0.6 Route map (Phase 4)

- [x] `/` (Home — boot-check view)
- [x] `/archive`
- [x] `/post/:slug`
- [x] `/about`
- [x] `/contact` (UI-only unless backend exists)
- [x] `/directory` (Strik3Zone)

---

## 4.1 Design System (Tokens → Theme → Primitives)

### 4.1.1 Token system

- [x] Colors (brand / neutrals / semantic)
- [x] Typography scale (h1–h6, body, micro)
- [x] Spacing scale (4 / 8 / 12 / 16 / 24 / 32 …)
- [x] Radii + shadows
- [x] Z-index layers
- [x] Breakpoints

### 4.1.2 Theme engine (light/dark)

- [x] Tailwind `darkMode: 'class'` strategy configured
- [x] System preference detection + localStorage persistence
- [x] Theme toggle component (`ThemeToggle`)
- [x] Full token set applied via CSS vars / Tailwind config

### 4.1.3 Icon system

- [x] Icon wrapper + `iconMap`
- [x] Baseline icon set: nav, content, UI states, golf, monetization

### 4.1.4 Base UI primitives (must-have)

- [x] Button (variants: primary / ghost / outline + loading state)
- [x] Badge / Pill
- [x] Input / Textarea
- [x] Select / Dropdown
- [x] Dialog / Drawer
- [x] Tooltip / Popover
- [x] Card
- [x] Skeleton
- [x] Spinner
- [x] EmptyState / ErrorState components

---

## 4.2 Composable Flex/Grid Layout System

### 4.2.1 Grid primitives (design-system)

- [x] Grid container: supports columns 1 | 2 | 3 | 6 | 12
- [x] GridItem (span / start / rowSpan / order)
- [x] Responsive columns via breakpoint props (sm / md / lg)

### 4.2.2 Layout recipes (reusable compositions)

- [x] OneColumnStack (12)
- [x] TwoColumnSplit (6/6, 8/4)
- [x] ThreeColumn (4/4/4)
- [x] SixCardGrid (2×6)
- [x] HeroPlusGrid (8 + 4 stack → then grid)

### 4.2.3 Section wrapper

- [x] `Section` (title + actions + grid + optional "View all" link)

---

## 4.3 Universal Site Chrome (Header / Footer + Rails + Ad Zones)

### 4.3.1 Header (global)

- [x] Logo + brand link (basic)
- [-] Primary nav (Home / Archive / About / Contact) — links not wired
- [x] Theme toggle
- [x] Search trigger placeholder
- [x] Mobile nav drawer

### 4.3.2 Footer (global)

- [-] Footer shell exists (`© Strik3Zone`)
- [x] Category links
- [x] Social links
- [x] Legal / disclaimer
- [x] "Powered by Strik3Zone" backlink

### 4.3.3 Left rail (Nav + Promo Slot)

- [x] Category list / sections (basic)
- [x] Optional promo / ad slot (layout-safe)

### 4.3.4 Right rail (Trending + Social + Ads)

- [x] TrendingList component
- [x] SocialEmbeds placeholder
- [x] NewsletterCTA card
- [x] AdSlot stack

### 4.3.5 20/50/30 responsive system

- [x] Desktop grid: 20 / 50 / 30
- [x] Tablet: collapse left rail (0 / 70 / 30)
- [x] Mobile: stacked (header → content → rails)

---

## 4.4 Content Components (Posts / Magazine)

### 4.4.1 ArticleCard (variants)

- [x] Hero / standard / compact
- [x] Title, excerpt, category/tags, author/date, optional image

### 4.4.2 HeroStoryBlock

- [x] Featured hero (span-based)
- [x] Secondary strip / list

### 4.4.3 AuthorCard

- [x] Avatar, bio, socials (optional), author page link placeholder

### 4.4.4 PostMetaBar

- [x] Publish date
- [x] Read time estimate
- [x] Share buttons placeholder

### 4.4.5 BreakingTicker (marquee)

- [x] Placeholder headlines feed
- [x] Later: live tournaments / scores

---

## 4.5 Block Rendering System (Minimal, Non-Editor)

### 4.5.1 Block contract (Phase 4)

- [-] `BlockRenderer` stub exists (`editor/BlockRenderer.tsx`) — returns `null`
- [x] Registry map + dispatch to block components
- [x] Unknown block fallback (never crashes)

### 4.5.2 Supported blocks (Phase 4 minimum)

- [x] Heading, Paragraph, List, Quote
- [x] Image (caption)
- [x] Divider
- [x] Code (simple)
- [x] Embed (sanitised placeholder)

> Full EditorJS + advanced blocks belong to Phase 5.

---

## 4.6 Views (Pages)

### 4.6.1 Home View `/`

- [-] Route wired (boot-check placeholder rendered)
- [x] BreakingTicker
- [x] HeroStoryBlock
- [x] Recent posts grid (uses grid recipes)
- [x] Rails + Ad slots

### 4.6.2 Archive View `/archive`

- [x] Route created
- [x] TanStack table (server-param ready)
- [x] Search + filters (category / tag)
- [x] Sorting + pagination
- [x] Loading / empty / error states

### 4.6.3 Article View `/post/:slug`

- [x] Route created
- [x] Title + featured image
- [x] PostMetaBar
- [x] BlockRenderer output
- [x] AuthorCard
- [x] Right rail: trending / related placeholder + ads

### 4.6.4 Static Views

- [x] `/about` (content + Strik3Zone tie-in)
- [x] `/contact` (UI-only; submit later unless endpoint exists)
- [x] `/directory` (Strik3Zone product cards + links)

---

## 4.7 Data Fetching Layer (TanStack Query + GraphQL / REST)

### 4.7.1 Query key standards + caching policy

- [x] Central `queryKeys` map
- [x] Stale time rules (content vs stats)
- [-] Retry rules (QueryClient defaults set to `retry: 1`)

### 4.7.2 GraphQL hooks (content)

- [x] `usePosts({ limit, offset })` — basic
- [x] `usePosts({ q, category, tag, page, pageSize, sort })` — full filter API
- [x] `usePostBySlug(slug)`
- [x] `useTags()`
- [x] `useCategories()`
- [x] `useTrending()`

### 4.7.3 REST hooks (proof-of-pattern)

- [x] `useLeaderboard(tournamentId)` — hook scaffolded
- [x] Demo component: renders leaderboard as a table/card with loading / empty / error

### 4.7.4 Error handling

- [x] Unified error normalisation
- [x] Toasts for non-blocking errors

### 4.7.5 Cache + stale time policy

- [x] Content queries: stale after 60 s
- [x] Stats queries: stale after 30 s

---

## 4.8 SEO + A11y Baseline

### 4.8.1 SEO head plumbing

- [x] `SeoHead` component (title / meta / OG / Twitter / canonical)
- [x] Article JSON-LD placeholder

### 4.8.2 Accessibility baseline

- [x] Skip-to-content link
- [x] Focus rings + keyboard nav
- [x] Dialog / drawer focus trap

---

## 4.9 Phase 4 Validation Gate (Ship Criteria)

- [x] AppShell renders with Header / Footer + rails
- [x] 20/50/30 responsive layout works across breakpoints
- [x] Dark mode persists across refresh
- [-] Home pulls posts from GraphQL and renders grid layouts
- [-] Archive table sorts / filters / paginates (server-param ready)
- [-] Article view loads by slug and renders blocks safely
- [x] One REST demo component renders successfully
- [x] Loading / empty / error states exist everywhere
- [x] SEO head renders correct meta on article route
- [x] Commit checkpoint: `"Phase 4 – Frontend Base Ready"`

---

## Intentionally Deferred Out of Phase 4

- Full editor + templates system → **Phase 5**
- Full stats suite (projections, betting edges, player trends) → **Phase 6+**
- Contact form submission + spam protection → later (unless endpoint exists)
