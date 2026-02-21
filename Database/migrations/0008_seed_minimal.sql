-- Minimal seed data for local dev (safe to run multiple times)

-- Roles
INSERT INTO website_content.roles (key, name)
VALUES
  ('admin','Admin'),
  ('editor','Editor'),
  ('author','Author'),
  ('viewer','Viewer')
ON CONFLICT (key) DO NOTHING;

-- Permissions (minimal)
INSERT INTO website_content.permissions (key, name)
VALUES
  ('post:create','Create Post'),
  ('post:edit','Edit Post'),
  ('post:publish','Publish Post'),
  ('template:edit','Edit Template'),
  ('product:manage','Manage Products')
ON CONFLICT (key) DO NOTHING;

-- Map admin role -> permissions
INSERT INTO website_content.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM website_content.roles r
JOIN website_content.permissions p ON TRUE
WHERE r.key = 'admin'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Create an admin user (password hash is placeholder)
INSERT INTO website_content.users (email, username, password_hash, display_name, is_active, is_verified)
VALUES ('admin@local.dev','admin','CHANGE_ME_HASH','Admin',TRUE,TRUE)
ON CONFLICT (email) DO NOTHING;

-- Assign admin role
INSERT INTO website_content.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM website_content.users u
JOIN website_content.roles r ON r.key='admin'
WHERE u.email='admin@local.dev'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- SEO example
INSERT INTO website_content.seo (title, description)
VALUES ('Caddy Stats','Golf content platform')
ON CONFLICT DO NOTHING;

-- Tags/Categories
INSERT INTO website_content.tags (slug, name)
VALUES ('pga-tour','PGA Tour'), ('betting','Betting')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO website_content.categories (slug, name)
VALUES ('news','News'), ('guides','Guides')
ON CONFLICT (slug) DO NOTHING;

-- Post example
INSERT INTO website_content.posts (author_id, slug, title, excerpt, status, published_at, content_jsonb)
SELECT u.id, 'welcome', 'Welcome to Caddy Stats', 'First post.', 'published', now(),
       '{"blocks":[{"type":"paragraph","text":"Hello world"}]}'::jsonb
FROM website_content.users u
WHERE u.email='admin@local.dev'
ON CONFLICT (slug) DO NOTHING;

-- Attach taxonomy
INSERT INTO website_content.post_tags (post_id, tag_id)
SELECT p.id, t.id
FROM website_content.posts p
JOIN website_content.tags t ON t.slug='pga-tour'
WHERE p.slug='welcome'
ON CONFLICT (post_id, tag_id) DO NOTHING;

INSERT INTO website_content.post_categories (post_id, category_id)
SELECT p.id, c.id
FROM website_content.posts p
JOIN website_content.categories c ON c.slug='news'
WHERE p.slug='welcome'
ON CONFLICT (post_id, category_id) DO NOTHING;

-- Products / License / Purchase example
INSERT INTO website_content.products (slug, name, description, product_type, price_cents, currency, status)
VALUES ('starter-template','Starter Template','A starter layout template.','template',1999,'USD','active')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO website_content.licenses (product_id, license_key, max_activations)
SELECT pr.id, 'LIC-LOCAL-0001', 1
FROM website_content.products pr
WHERE pr.slug='starter-template'
ON CONFLICT (license_key) DO NOTHING;

INSERT INTO website_content.purchases (buyer_id, product_id, license_id, amount_cents, currency, provider, provider_ref, status)
SELECT u.id, pr.id, l.id, 1999, 'USD', 'manual', 'seed-order-1', 'paid'
FROM website_content.users u
JOIN website_content.products pr ON pr.slug='starter-template'
JOIN website_content.licenses l ON l.license_key='LIC-LOCAL-0001'
WHERE u.email='admin@local.dev'
ON CONFLICT DO NOTHING;
