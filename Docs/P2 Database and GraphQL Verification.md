# Phase 2 – Website Database + GraphQL Verification

Owner: Nick  
Project: Caddy Stats  
Schema: website_content  
Golf Stats: External API Only  

---

## 1. Database Verification

### Check schema exists

\dn

Expected:
website_content

---

### Check tables

\dt website_content.*

Expected core groups:

AUTH
- users
- roles
- permissions
- role_permissions
- sessions
- password_resets

CONTENT
- posts
- pages
- templates
- blocks
- revisions
- comments
- categories
- tags
- post_tags
- media_assets
- nav_menus
- nav_items

SEO
- redirects
- slug_history
- sitemap_cache

MONETIZATION
- products
- purchases
- licenses
- plans
- subscriptions
- entitlements

ENGAGEMENT
- saved_posts
- reactions
- notifications
- subscribers
- subscriber_lists
- email_campaigns

ADMIN
- audit_logs
- rate_limits
- ip_blocks

META
- options
- post_meta
- user_meta
- comment_meta
- product_meta

---

### Confirm UUID + timestamps

\d website_content.posts

Expect:
id UUID PK
created_at timestamptz
updated_at timestamptz
trigger: set_updated_at()

---

## 2. Index Verification

Run:

SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'website_content';

Ensure:
- slug unique indexes
- FK indexes
- partial published index
- GIN search indexes

---

## 3. GraphQL Verification

### Health

GET /health
Expect:
{"status":"ok"}

### GraphQL Loads

POST /graphql

Query:

query {
  posts(first: 5) {
    edges {
      node {
        id
        title
        status
      }
    }
  }
}

Should return connection structure.

---

## 4. Publish Workflow Test

1. createPost (draft)
2. publishPost
3. query posts(status: PUBLISHED)

Confirm published_at is set.

---

## 5. No Golf Stats Tables

Run:

SELECT schemaname, tablename
FROM pg_tables
WHERE tablename ILIKE '%golf%';

Expect:
0 rows

---

## 6. Docker Bootstrap

docker compose down -v
docker compose up --build

Expected:
- schema auto-created
- migrations applied
- seed admin user exists
- GraphQL running

---

Phase 2 Complete When:
[ ] DB reproducible
[ ] GraphQL live
[ ] CRUD tested
[ ] No golf stats schema
[ ] Seeds inserted
