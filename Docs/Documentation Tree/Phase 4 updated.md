PHASE 4 – FRONTEND UI BASE SYSTEM (React + Vite + TanStack)

Purpose: Ship a production-grade frontend foundation: design system + app shell + composable grid + core views + typed data layer.


---

4.0 Frontend Foundations

4.0.1 Confirm core libs wired

React + Vite + TypeScript

TanStack Query (QueryClient + defaults)

React Router v6 (route map + lazy routes)

GraphQL client wrapper (typed request)

REST client wrapper (fetch wrapper, base URL, headers)


4.0.2 App providers (global wiring)

QueryProvider (TanStack QueryClient, retry/staleTime policy)

ThemeProvider (light/dark + persistence)

ToastProvider (minimal notifications)

ErrorBoundary (global + per-route boundary)


4.0.3 Global app shell + routing layout

AppShell (Header + Footer + content container)

RouteLayout (layout switching per page)

NotFound route

ErrorRoute (friendly error screen)


4.0.4 Environment + endpoint config

VITE_API_BASE_URL (REST)

VITE_GQL_ENDPOINT (GraphQL)

Build-time env validation (fails fast in dev)


4.0.5 Shared types layer (Phase 4 scope only)

Post, Author, Tag, Category, SeoMeta, Pagination

Block base types for renderer (minimal)

StatsDTO for one REST demo endpoint (proof-of-pattern)


4.0.6 Route map (Phase 4)

/ (Home)

/archive

/post/:slug

/about

/contact (UI-only unless backend exists)

/directory (Strik3Zone)



---

4.1 Design System (Tokens → Theme → Primitives)

4.1.1 Token system

Colors (brand/neutrals/semantic)

Typography scale (h1–h6, body, micro)

Spacing scale

Radii + shadows

Z-index layers

Breakpoints


4.1.2 Theme engine (light/dark)

Tailwind dark strategy (or CSS vars)

System preference detection

Persist preference (localStorage)

Theme toggle component


4.1.3 Icon system

Icon wrapper + iconMap

Baseline icon set: nav, content, UI states, golf, monetization


4.1.4 Base UI primitives (must-have)

Button (variants + loading)

Badge / Pill

Input / Textarea

Select (or dropdown)

Dialog / Drawer

Tooltip / Popover

Card

Skeleton

Spinner

EmptyState / ErrorState components



---

4.2 Composable Flex/Grid Layout System (Drop-in Blocks + Cards)

4.2.1 Grid primitives (design-system)

Grid container: supports columns 1 | 2 | 3 | 6 | 12

GridItem (span/start/rowSpan/order)

Responsive columns via breakpoint props (sm/md/lg)


4.2.2 Layout recipes (reusable compositions)

OneColumnStack (12)

TwoColumnSplit (6/6, 8/4)

ThreeColumn (4/4/4)

SixCardGrid (2x6)

HeroPlusGrid (8 + 4 stack → then grid)


4.2.3 Section wrapper

Section (title + actions + grid + optional “View all” link)


Outcome: Any page can “drop in” content blocks/cards without custom layout code.


---

4.3 Universal Site Chrome (Header/Footer + Rails + Ads Zones)

4.3.1 Header (global)

Logo + brand link

Primary nav (Home/Archive/About/Contact)

Theme toggle

Search trigger placeholder (no full search yet)

Mobile nav drawer


4.3.2 Footer (global)

Category links

Social links

Legal / disclaimer

“Powered by Strik3Zone” backlink


4.3.3 Left rail (Nav + Promo Slot)

Category list / sections (basic)

Optional promo/ad slot (layout-safe)


4.3.4 Right rail (Trending + Social + Ads)

TrendingList

SocialEmbeds placeholder

NewsletterCTA card

AdSlot stack


4.3.5 20/50/30 responsive system

Desktop: 20 / 50 / 30

Tablet: collapse left rail (0 / 70 / 30)

Mobile: stacked (header → content → rails)



---

4.4 Content Components (Posts / Magazine)

4.4.1 ArticleCard (variants)

Hero / standard / compact

Title, excerpt, category/tags, author/date, optional image


4.4.2 HeroStoryBlock

Featured hero (span-based)

Secondary strip/list


4.4.3 AuthorCard

Avatar, bio, socials (optional), author page link placeholder


4.4.4 PostMetaBar

Publish date

Read time estimate

Share buttons placeholder


4.4.5 BreakingTicker (marquee)

Placeholder headlines feed

Later: live tournaments/scores



---

4.5 Block Rendering System (Minimal, Non-Editor)

4.5.1 Block contract (Phase 4)

BlockRenderer with registry map

Unknown block fallback (never crashes)


4.5.2 Supported blocks (Phase 4 minimum)

Heading, Paragraph, List, Quote

Image (caption)

Divider

Code (simple)

Embed (sanitized placeholder)


(Full EditorJS + advanced blocks belong to Phase 5.)


---

4.6 Views (Pages)

4.6.1 Home View / (Magazine)

BreakingTicker

HeroStoryBlock

Recent posts grid (uses Grid recipes)

Rails + Ad slots


4.6.2 Archive View /archive (TanStack Table)

TanStack table (server-param ready)

Search + filters (category/tag)

Sorting + pagination

Loading/empty/error states


4.6.3 Article View /post/:slug

Title + featured image

PostMetaBar

BlockRenderer output

AuthorCard

Right rail: trending/related placeholder + ads


4.6.4 Static Views

/about (content + Strik3Zone tie-in)

/contact (UI-only; submit later unless endpoint exists)

/directory (Strik3Zone product cards + links)



---

4.7 Data Fetching Layer (TanStack Query + GraphQL/REST)

4.7.1 Query key standards + caching policy

Central queryKeys

Stale time rules (content vs stats)

Retry rules


4.7.2 GraphQL hooks (content)

usePosts({ q, category, tag, page, pageSize, sort })

usePostBySlug(slug)

useTags()

useCategories()

useTrending()


4.7.3 REST hooks (proof-of-pattern only)

Implement one REST hook + demo component:

useLeaderboard() or useCourseHistory()


Display as a small table/card with loading/empty/error


4.7.4 Error handling

Unified error normalization

Toasts for non-blocking errors



---

4.8 SEO + A11y Baseline (Base System Only)

4.8.1 SEO head plumbing

SeoHead component (title/meta/OG/Twitter/canonical)

Article JSON-LD placeholder


4.8.2 Accessibility baseline

Skip-to-content

Focus rings + keyboard nav

Dialog/drawer focus trap



---

4.9 Phase 4 Validation Gate (Ship Criteria)

AppShell renders with Header/Footer + rails

20/50/30 responsive layout works across breakpoints

Dark mode persists across refresh

Home pulls posts from GraphQL and renders grid layouts

Archive table sorts/filters/paginates (server-param ready)

Article view loads by slug and renders blocks safely

One REST demo component renders successfully

Loading/empty/error states exist everywhere

SEO head renders correct meta on article route

Commit checkpoint: “Phase 4 – Frontend Base Ready”



---

What was intentionally deferred out of Phase 4

Full editor + templates system (Phase 5)

Full stats suite: projections, betting edges, player trends (Phase 6+)

Contact form submission + spam protection (later unless endpoint exists)


If you want, I’ll also rewrite this into a copy/paste Markdown doc formatted like your master control files (with checkboxes + acceptance criteria per item).
