✅ New 2️⃣ PHASE 2 – WEBSITE DATABASE + GRAPHQL (NO GOLF STATS)

2.0 Database Architecture & Conventions (Website Only)

[ ] 2.0.1 DB layout

[ ] Single Postgres cluster

[ ] Single database (ex: caddystats)

[ ] Single schema: website_content


[ ] 2.0.2 Naming conventions

[ ] tables: snake_case plural

[ ] columns: snake_case

[ ] PK: id UUID DEFAULT gen_random_uuid()

[ ] FK: <table>_id


[ ] 2.0.3 Standard columns

[ ] created_at TIMESTAMPTZ DEFAULT now()

[ ] updated_at TIMESTAMPTZ maintained by trigger

[ ] deleted_at TIMESTAMPTZ NULL (soft delete standard)

[ ] optional is_deleted BOOLEAN DEFAULT false


[ ] 2.0.4 JSONB policy

[ ] posts.content_jsonb stores editor blocks

[ ] templates.content_jsonb

[ ] revisions.snapshot_jsonb

[ ] GIN indexes only where queried


[ ] 2.0.5 Migration strategy

[ ] SQL migrations stored in /database/migrations

[ ] numbering 0000_..., 0001_...

[ ] optional .down.sql for content tables (recommended)


[ ] 2.0.6 Bootstrap scripts

[ ] 0000_extensions.sql (pgcrypto)

[ ] 0001_create_schema.sql (website_content)

[ ] 0002_triggers.sql (updated_at function)




---

2.1 Website DB Schema (Core Tables)

2.1.1 Auth + RBAC

[ ] users

[ ] roles

[ ] permissions

[ ] user_roles

[ ] role_permissions

[ ] auth support fields: password hash, verified flags, status


2.1.2 CMS Content

[ ] posts

[ ] pages

[ ] templates

[ ] workflow: draft → review → published → archived

[ ] featured_image support

[ ] slug uniqueness + publish timestamp consistency


2.1.3 Taxonomy

[ ] tags

[ ] categories (hierarchy via parent_id)

[ ] post_tags

[ ] post_categories


2.1.4 SEO Layer

[ ] seo (reusable object)

[ ] posts.seo_id, pages.seo_id, templates.seo_id


2.1.5 Revisions + Comments

[ ] revisions (entity_type/entity_id + snapshot_jsonb)

[ ] comments (status + moderation)


2.1.6 Media / Uploads

[ ] media_assets (storage_provider, bucket, key, url)

[ ] asset_links (optional: where-used tracking)


2.1.7 Navigation

[ ] nav_menus

[ ] nav_items (parent_id tree + sort_order)


2.1.8 Marketplace (Docs/Templates Store)

[ ] products

[ ] licenses

[ ] purchases

[ ] provider placeholders (stripe/paddle/manual)


2.1.9 Analytics Events (Basic)

[ ] events (pageview, click, purchase, search)

[ ] minimal fields + future expansion



---

2.2 Performance Layer (Indexes + Search)

[ ] 2.2.1 Index pack

[ ] all FK columns

[ ] slug indexes (unique)

[ ] partial indexes for published content


[ ] 2.2.2 Full-text search

[ ] posts.search_vector + GIN

[ ] products.search_vector + GIN


[ ] 2.2.3 JSONB indexing

[ ] only add GIN if filtering/searching inside JSONB


[ ] 2.2.4 Validation queries

[ ] EXPLAIN ANALYZE for list pages + search




---

2.3 GraphQL Website Contract (Schema-First)

2.3.1 Types

[ ] User, Role, Permission

[ ] Post, Page, Template, Block

[ ] Tag, Category

[ ] SEO, Revision, Comment

[ ] MediaAsset

[ ] NavMenu, NavItem

[ ] Product, License, Purchase

[ ] Event


2.3.2 Pagination / Filtering / Sorting

[ ] Relay Connection/Edge/PageInfo

[ ] filter inputs for major lists (status, tagIds, categoryIds, authorId)

[ ] sort inputs (created_at, updated_at, published_at)


2.3.3 Queries

[ ] viewer

[ ] users

[ ] posts, pages, products, templates

[ ] searchPosts, searchProducts

[ ] navMenu(slug)


2.3.4 Mutations (CRUD + Workflow)

[ ] auth: signUp, signIn, refreshToken, signOut

[ ] posts: createPost, updatePost, publishPost, archivePost

[ ] templates: createTemplate, updateTemplate, publishTemplate

[ ] blocks: addBlock, reorderBlocks (if normalized blocks table is used)

[ ] uploads: uploadAssetReference (metadata record only)

[ ] commerce: createPurchase, verifyLicense


2.3.5 RBAC Enforcement

[ ] permission keys like post:publish, template:edit

[ ] resolver guards: viewer role + permission checks



---

2.4 External Stats API Integration (No Local Stats DB)

[ ] Create services/stats_api_client

[ ] GraphQL curated fields (thin gateway only)

[ ] featuredEdges(tournamentId)

[ ] leaderboard(tournamentId)

[ ] tournamentCard(tournamentId)


[ ] timeouts, caching hooks (Redis later), rate-limit handling



---

2.5 Seeds + Developer Experience

[ ] minimal seed set for website_content

[ ] 1 admin user, roles/permissions

[ ] 2 posts, 1 page, 1 nav menu

[ ] 2 products + 1 license


[ ] migration runner command

[ ] docker-compose local bootstrap to auto-run migrations

[ ] smoke test: GraphQL schema loads and basic CRUD works



---

If you want the next output, tell me “generate Phase 2 migrations” and I’ll produce the exact ordered SQL files:

0000_extensions.sql

0001_create_schema.sql

0002_triggers.sql

0003_auth_rbac.sql

0004_cms_content.sql

0005_taxonomy_seo.sql

0006_media_nav_marketplace.sql

0007_search_indexes.sql

0008_seed_minimal.sql
