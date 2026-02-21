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
- [ ] ToastProvider (minimal notifications)
- [ ] ErrorBoundary (global + per-route boundary)

### 4.0.3 Global app shell + routing layout

- [x] AppShell (Header + Footer + content container)
- [ ] RouteLayout (layout switching per page)
- [ ] NotFound route
- [ ] ErrorRoute (friendly error screen)

### 4.0.4 Environment + endpoint config

- [x] `VITE_API_HTTP_URL` (REST base URL)
- [x] `VITE_API_GRAPHQL_URL` (GraphQL endpoint)
- [ ] Build-time env validation (fails fast in dev if vars missing)

### 4.0.5 Shared types layer (Phase 4 scope only)

- [x] `Post`, `PostListItem` (`types/post.ts`)
- [x] `User`, `UserRole`, `AuthState` (`types/user.ts`)
- [-] `Author`, `Tag`, `Category`, `SeoMeta` (partial stubs)
- [ ] Block base types for renderer (minimal)
- [ ] `StatsDTO` for one REST demo endpoint (proof-of-pattern)

### 4.0.6 Route map (Phase 4)

- [x] `/` (Home — boot-check view)
- [ ] `/archive`
- [ ] `/post/:slug`
- [ ] `/about`
- [ ] `/contact` (UI-only unless backend exists)
- [ ] `/directory` (Strik3Zone)

---

## 4.1 Design System (Tokens → Theme → Primitives)

### 4.1.1 Token system

- [ ] Colors (brand / neutrals / semantic)
- [ ] Typography scale (h1–h6, body, micro)
- [ ] Spacing scale (4 / 8 / 12 / 16 / 24 / 32 …)
- [ ] Radii + shadows
- [ ] Z-index layers
- [ ] Breakpoints

### 4.1.2 Theme engine (light/dark)

- [x] Tailwind `darkMode: 'class'` strategy configured
- [x] System preference detection + localStorage persistence
- [x] Theme toggle component (`ThemeToggle`)
- [ ] Full token set applied via CSS vars / Tailwind config

### 4.1.3 Icon system

- [ ] Icon wrapper + `iconMap`
- [ ] Baseline icon set: nav, content, UI states, golf, monetization

### 4.1.4 Base UI primitives (must-have)

- [ ] Button (variants: primary / ghost / outline + loading state)
- [ ] Badge / Pill
- [ ] Input / Textarea
- [ ] Select / Dropdown
- [ ] Dialog / Drawer
- [ ] Tooltip / Popover
- [ ] Card
- [ ] Skeleton
- [ ] Spinner
- [ ] EmptyState / ErrorState components

---

## 4.2 Composable Flex/Grid Layout System

### 4.2.1 Grid primitives (design-system)

- [ ] Grid container: supports columns 1 | 2 | 3 | 6 | 12
- [ ] GridItem (span / start / rowSpan / order)
- [ ] Responsive columns via breakpoint props (sm / md / lg)

### 4.2.2 Layout recipes (reusable compositions)

- [ ] OneColumnStack (12)
- [ ] TwoColumnSplit (6/6, 8/4)
- [ ] ThreeColumn (4/4/4)
- [ ] SixCardGrid (2×6)
- [ ] HeroPlusGrid (8 + 4 stack → then grid)

### 4.2.3 Section wrapper

- [ ] `Section` (title + actions + grid + optional "View all" link)

---

## 4.3 Universal Site Chrome (Header / Footer + Rails + Ad Zones)

### 4.3.1 Header (global)

- [x] Logo + brand link (basic)
- [-] Primary nav (Home / Archive / About / Contact) — links not wired
- [x] Theme toggle
- [ ] Search trigger placeholder
- [ ] Mobile nav drawer

### 4.3.2 Footer (global)

- [-] Footer shell exists (`© Strik3Zone`)
- [ ] Category links
- [ ] Social links
- [ ] Legal / disclaimer
- [ ] "Powered by Strik3Zone" backlink

### 4.3.3 Left rail (Nav + Promo Slot)

- [ ] Category list / sections (basic)
- [ ] Optional promo / ad slot (layout-safe)

### 4.3.4 Right rail (Trending + Social + Ads)

- [ ] TrendingList component
- [ ] SocialEmbeds placeholder
- [ ] NewsletterCTA card
- [ ] AdSlot stack

### 4.3.5 20/50/30 responsive system

- [ ] Desktop grid: 20 / 50 / 30
- [ ] Tablet: collapse left rail (0 / 70 / 30)
- [ ] Mobile: stacked (header → content → rails)

---

## 4.4 Content Components (Posts / Magazine)

### 4.4.1 ArticleCard (variants)

- [ ] Hero / standard / compact
- [ ] Title, excerpt, category/tags, author/date, optional image

### 4.4.2 HeroStoryBlock

- [ ] Featured hero (span-based)
- [ ] Secondary strip / list

### 4.4.3 AuthorCard

- [ ] Avatar, bio, socials (optional), author page link placeholder

### 4.4.4 PostMetaBar

- [ ] Publish date
- [ ] Read time estimate
- [ ] Share buttons placeholder

### 4.4.5 BreakingTicker (marquee)

- [ ] Placeholder headlines feed
- [ ] Later: live tournaments / scores

---

## 4.5 Block Rendering System (Minimal, Non-Editor)

### 4.5.1 Block contract (Phase 4)

- [-] `BlockRenderer` stub exists (`editor/BlockRenderer.tsx`) — returns `null`
- [ ] Registry map + dispatch to block components
- [ ] Unknown block fallback (never crashes)

### 4.5.2 Supported blocks (Phase 4 minimum)

- [ ] Heading, Paragraph, List, Quote
- [ ] Image (caption)
- [ ] Divider
- [ ] Code (simple)
- [ ] Embed (sanitised placeholder)

> Full EditorJS + advanced blocks belong to Phase 5.

---

## 4.6 Views (Pages)

### 4.6.1 Home View `/`

- [-] Route wired (boot-check placeholder rendered)
- [ ] BreakingTicker
- [ ] HeroStoryBlock
- [ ] Recent posts grid (uses grid recipes)
- [ ] Rails + Ad slots

### 4.6.2 Archive View `/archive`

- [ ] Route created
- [ ] TanStack table (server-param ready)
- [ ] Search + filters (category / tag)
- [ ] Sorting + pagination
- [ ] Loading / empty / error states

### 4.6.3 Article View `/post/:slug`

- [ ] Route created
- [ ] Title + featured image
- [ ] PostMetaBar
- [ ] BlockRenderer output
- [ ] AuthorCard
- [ ] Right rail: trending / related placeholder + ads

### 4.6.4 Static Views

- [ ] `/about` (content + Strik3Zone tie-in)
- [ ] `/contact` (UI-only; submit later unless endpoint exists)
- [ ] `/directory` (Strik3Zone product cards + links)

---

## 4.7 Data Fetching Layer (TanStack Query + GraphQL / REST)

### 4.7.1 Query key standards + caching policy

- [ ] Central `queryKeys` map
- [ ] Stale time rules (content vs stats)
- [-] Retry rules (QueryClient defaults set to `retry: 1`)

### 4.7.2 GraphQL hooks (content)

- [x] `usePosts({ limit, offset })` — basic
- [ ] `usePosts({ q, category, tag, page, pageSize, sort })` — full filter API
- [ ] `usePostBySlug(slug)`
- [ ] `useTags()`
- [ ] `useCategories()`
- [ ] `useTrending()`

### 4.7.3 REST hooks (proof-of-pattern)

- [x] `useLeaderboard(tournamentId)` — hook scaffolded
- [ ] Demo component: renders leaderboard as a table/card with loading / empty / error

### 4.7.4 Error handling

- [ ] Unified error normalisation
- [ ] Toasts for non-blocking errors

### 4.7.5 Cache + stale time policy

- [ ] Content queries: stale after 60 s
- [ ] Stats queries: stale after 30 s

---

## 4.8 SEO + A11y Baseline

### 4.8.1 SEO head plumbing

- [ ] `SeoHead` component (title / meta / OG / Twitter / canonical)
- [ ] Article JSON-LD placeholder

### 4.8.2 Accessibility baseline

- [ ] Skip-to-content link
- [ ] Focus rings + keyboard nav
- [ ] Dialog / drawer focus trap

---

## 4.9 Phase 4 Validation Gate (Ship Criteria)

- [ ] AppShell renders with Header / Footer + rails
- [ ] 20/50/30 responsive layout works across breakpoints
- [x] Dark mode persists across refresh
- [ ] Home pulls posts from GraphQL and renders grid layouts
- [ ] Archive table sorts / filters / paginates (server-param ready)
- [ ] Article view loads by slug and renders blocks safely
- [ ] One REST demo component renders successfully
- [ ] Loading / empty / error states exist everywhere
- [ ] SEO head renders correct meta on article route
- [ ] Commit checkpoint: `"Phase 4 – Frontend Base Ready"`

---

## Intentionally Deferred Out of Phase 4

- Full editor + templates system → **Phase 5**
- Full stats suite (projections, betting edges, player trends) → **Phase 6+**
- Contact form submission + spam protection → later (unless endpoint exists)
