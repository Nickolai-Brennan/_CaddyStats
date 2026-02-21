-- Database/validation/performance_queries.sql
-- Run these with EXPLAIN ANALYZE to verify query plans use indexes.
-- All queries must show index scans (not sequential scans) on large tables.

-- -----------------------------------------------------------------------
-- 1. Published posts list (uses idx_posts_status_published_at)
-- -----------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT p.id, p.slug, p.title, p.status, p.published_at
FROM website_content.posts p
WHERE p.status = 'published'
  AND p.is_deleted = false
ORDER BY p.published_at DESC
LIMIT 20;

-- -----------------------------------------------------------------------
-- 2. Full-text search on posts (uses idx_posts_search_vector GIN)
-- -----------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT p.id, p.slug, p.title,
       ts_rank(p.search_vector, to_tsquery('english', 'golf & tournament')) AS rank
FROM website_content.posts p
WHERE p.search_vector @@ to_tsquery('english', 'golf & tournament')
  AND p.is_deleted = false
ORDER BY rank DESC
LIMIT 20;

-- -----------------------------------------------------------------------
-- 3. Posts by tag (uses post_tags FK index + tag lookup)
-- -----------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT p.id, p.slug, p.title
FROM website_content.posts p
JOIN website_content.post_tags pt ON pt.post_id = p.id
JOIN website_content.tags t ON t.id = pt.tag_id
WHERE t.slug = 'tournament-preview'
  AND p.is_deleted = false
ORDER BY p.published_at DESC
LIMIT 20;

-- -----------------------------------------------------------------------
-- 4. Single post by slug (uses posts_slug_key unique index)
-- -----------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT p.id, p.slug, p.title, p.status, p.content_jsonb
FROM website_content.posts p
WHERE p.slug = 'my-post-slug'
  AND p.is_deleted = false;

-- -----------------------------------------------------------------------
-- 5. User roles and permissions lookup (uses FK indexes)
-- -----------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT u.id, u.email, r.key AS role_key, perm.key AS perm_key
FROM website_content.users u
JOIN website_content.user_roles ur ON ur.user_id = u.id
JOIN website_content.roles r ON r.id = ur.role_id
JOIN website_content.role_permissions rp ON rp.role_id = r.id
JOIN website_content.permissions perm ON perm.id = rp.permission_id
WHERE u.id = 'a0000000-0000-0000-0000-000000000001'::uuid;

-- -----------------------------------------------------------------------
-- 6. Full-text search on products (uses idx_products_search_vector GIN)
-- -----------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT pr.id, pr.slug, pr.name
FROM website_content.products pr
WHERE pr.search_vector @@ to_tsquery('english', 'caddy')
  AND pr.status = 'active'
LIMIT 20;

-- -----------------------------------------------------------------------
-- 7. Nav menu with items (uses nav_items.menu_id FK index)
-- -----------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT m.id, m.slug, m.name, ni.label, ni.href, ni.sort_order
FROM website_content.nav_menus m
JOIN website_content.nav_items ni ON ni.menu_id = m.id
WHERE m.slug = 'main-nav'
ORDER BY ni.sort_order ASC;
