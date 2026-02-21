1) Folder Map (Design System Package)

src/design-system/
  index.ts
  tokens/
  styles/
  icons/
  primitives/
  layout/
  navigation/
  content/
  blocks/
  charts/
  tables/
  ads/
  feedback/
  auth/
  seo/
  data/
  hooks/
  utils/
  placeholders/
  providers/
  types/


---

2) Tokens + Styles (Foundational)

/tokens

colors.ts (theme tokens, semantic colors)

typography.ts (font stacks, sizes, weights)

spacing.ts (scale)

radii.ts (corner scale)

shadows.ts (elevation)

breakpoints.ts (responsive)

zIndex.ts

motion.ts (durations/easing)

ads.ts (slot sizes, responsive rules)


/styles

globals.css

theme.css (CSS variables)

print.css (article print mode)

prose.css (article typography + table styles)

utilities.css (small cross-cutting utilities)



---

3) Icons System

/icons

Icon.tsx (single wrapper component)

iconMap.ts (name → svg component)

types.ts (IconName union)


Icon sets (minimum list)

Navigation: home, archive, search, tag, category, menu, close

Content: article, author, calendar, clock, link, externalLink, bookmark, share

Data/analytics: chart, table, trendUp, trendDown, sparkline

Golf: trophy, flag, pin, tee, golfBall, course, leaderboard

UI: sun, moon, info, warning, error, success, spinner

Commerce/monetization: ad, star, lock, unlock, gift


(Implement as inline SVG or lucide-react wrapper—either way, use the Icon abstraction.)


---

4) Primitives (Reusable UI Atoms)

/primitives

Button.tsx (variants, sizes, loading)

IconButton.tsx

Link.tsx (internal/external smart link)

Badge.tsx

Pill.tsx

Chip.tsx

Card.tsx

Divider.tsx

Separator.tsx

Avatar.tsx

Tooltip.tsx

Popover.tsx

DropdownMenu.tsx

Dialog.tsx

Drawer.tsx (mobile menus/filters)

Tabs.tsx

Accordion.tsx

Toast.tsx

Progress.tsx

Spinner.tsx

Skeleton.tsx (base skeleton)

Kbd.tsx (keyboard hints)

CopyButton.tsx (copy-to-clipboard)

VisuallyHidden.tsx (a11y helper)



---

5) Layout System (20/50/30 + Responsive)

/layout

AppShell.tsx (root shell: header/footer/grid)

Container.tsx (max width, padding)

Grid203050.tsx (desktop 3-col grid)

Stack.tsx (vertical spacing wrapper)

Cluster.tsx (inline spacing wrapper)

Sticky.tsx (sticky wrapper)

Section.tsx (page sections w/ title + actions)

PageHeader.tsx (title, subtitle, meta, actions)

Surface.tsx (background variants)

Aside.tsx (right/left panel wrappers)



---

6) Navigation + Site Chrome

/navigation

Header.tsx

Footer.tsx

TopNav.tsx

MobileNavDrawer.tsx

LeftRailNav.tsx (categories, sections)

RightRail.tsx (trending + ads container)

Breadcrumbs.tsx

Pagination.tsx

SearchBar.tsx

FilterBar.tsx

ThemeToggle.tsx

UserMenu.tsx (future auth)

SiteLogo.tsx



---

7) Content Components (Editorial Building Blocks)

/content

ArticleCard.tsx (variants: hero, standard, compact)

ArticleMeta.tsx (date, read time, views)

AuthorCard.tsx

CategoryBadge.tsx

TagList.tsx

FeaturedImage.tsx

ReadingProgressBar.tsx

ShareBar.tsx

BookmarkButton.tsx (future)

RelatedArticles.tsx

TrendingList.tsx

NewsletterCTA.tsx (monetization)

InlineDisclosure.tsx (affiliate/ad disclosure)

ContentGate.tsx (paywall placeholder)

SponsorBadge.tsx



---

8) Blocks System (EditorJS / Article Renderer)

/blocks (each block = JSON → React component)

BlockRenderer.tsx (switch by block type)

blocks.types.ts (discriminated unions)

blocks.registry.ts (type → component map)


Core article blocks

BlockHeading.tsx

BlockParagraph.tsx

BlockList.tsx

BlockQuote.tsx

BlockImage.tsx (caption + lazy loading)

BlockGallery.tsx

BlockDivider.tsx

BlockCallout.tsx (info/warn/pro tip)

BlockCode.tsx (syntax highlight wrapper)

BlockTable.tsx (simple HTML table)

BlockEmbed.tsx (YouTube/Twitter/etc - sanitized)

BlockHTML.tsx (SANITIZED; strict allowlist)

BlockCTA.tsx (newsletter/promo)

BlockAdSlot.tsx (inline ad injection)

BlockInternalLink.tsx (related link highlight)


Golf analytics blocks (placeholders now, real later)

BlockLeaderboard.tsx

BlockGolferCard.tsx

BlockCourseCard.tsx

BlockEventSummary.tsx

BlockModelPick.tsx (no tout tone; transparent)

BlockOddsTable.tsx

BlockStatComparison.tsx

BlockSparklineRow.tsx



---

9) Tables (TanStack Table System)

/tables

DataTable.tsx (generic wrapper)

ColumnBuilder.ts (helper)

TableToolbar.tsx (search, filters, column toggle)

TablePagination.tsx

TableEmptyState.tsx

TableErrorState.tsx

TableLoadingState.tsx

CellDate.tsx

CellNumber.tsx

CellBadge.tsx

CellLink.tsx


Table presets

ArchiveArticlesTable.tsx

LeaderboardTable.tsx (future)

OddsTable.tsx (future)

StatsTable.tsx (future)



---

10) Charts (Stubs + Base Wrappers)

/charts

ChartCard.tsx

Sparkline.tsx

LineChart.tsx (wrapper)

BarChart.tsx (wrapper)

ChartEmptyState.tsx

ChartTooltip.tsx


(You can back these with recharts later; keep interfaces stable now.)


---

11) Ads + Monetization Components

/ads

AdSlot.tsx (responsive sizes + lazy)

AdRail.tsx (right sidebar stack)

InlineAd.tsx

SponsoredCard.tsx

AffiliateLink.tsx (disclosure + tracking params)

PromoBanner.tsx

PaywallTeaser.tsx (future)

SubscriptionCTA.tsx (future)



---

12) Feedback + States (UX Quality)

/feedback

EmptyState.tsx

ErrorState.tsx

NotFound.tsx

OfflineBanner.tsx

LoadingOverlay.tsx

InlineMessage.tsx (info/warn/error/success)

FormError.tsx



---

13) Placeholders / Skeleton Library (Speed + Polish)

/placeholders

SkeletonArticleCard.tsx

SkeletonHero.tsx

SkeletonTrending.tsx

SkeletonTable.tsx

SkeletonArticle.tsx

SkeletonSidebar.tsx

Shimmer.tsx (optional)



---

14) SEO Components (Critical for Articles)

/seo

SeoHead.tsx (title/meta/og/twitter/canonical)

JsonLd.tsx (Article schema injection)

BreadcrumbJsonLd.tsx

RobotsMeta.tsx



---

15) Data Layer (Clients + Types + Contracts)

/data

graphqlClient.ts (typed request wrapper)

restClient.ts (fetch wrapper)

endpoints.ts (centralized URLs)

queryKeys.ts (TanStack keys)

normalizers.ts (API → UI shape)

guards.ts (runtime validation)


/types

article.ts

author.ts

category.ts

tag.ts

ad.ts

pagination.ts

api.ts (generic response shapes)

blocks.ts (block unions)

theme.ts



---

16) Hooks (TanStack + UI Behavior)

/hooks/data (TanStack Query)

useArticle(slug)

useArticles(params)

useTrending()

useCategories()

useTags()

useSearchArticles(query)

useArchiveTableState() (server-side table params)

usePrefetchArticle(slug) (hover prefetch)

useMutateBookmark() (future)

useNewsletterSignup() (future)


/hooks/ui

useDarkMode() (system + persisted)

useBreakpoint() (responsive logic)

useDebounce(value, ms)

useLocalStorage(key)

useScrollProgress() (article reading progress)

useSticky() (sticky calculations)

useIntersectionObserver() (lazy blocks/ads)

useCopyToClipboard()



---

17) Providers (App-Wide)

/providers

QueryProvider.tsx

ThemeProvider.tsx

RouterProvider.tsx (if you wrap)

ErrorBoundary.tsx

FeatureFlagsProvider.tsx (future)

AuthProvider.tsx (future)



---

18) Utilities (Quality + Consistency)

/utils

cn.ts (class merge helper)

formatDate.ts

formatNumber.ts

formatReadTime.ts

slugify.ts

safeUrl.ts

sanitizeHtml.ts (for BlockHTML/Embed)

trackEvent.ts (analytics stub)

buildShareUrl.ts

assertNever.ts (discriminated unions)



---

19) Placeholders for Future Systems (Don’t Build Logic Yet)

These are stubs that keep architecture stable:

AuthGate.tsx (role-based UI gating)

PremiumBadge.tsx

FeatureFlag.tsx

ModelDisclaimer.tsx (transparency for projections/picks)

DataFreshness.tsx (last updated timestamps)

Attribution.tsx (data source credits)



---

20) Design System “Index Exports” (DX)

/design-system/index.ts

Export primitives + layout + blocks + hooks + icons
So the app imports from: import { Button, ArticleCard, useArticle, Icon } from "@/design-system";



---
