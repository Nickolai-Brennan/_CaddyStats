-- =========================
-- Minimal seed data for developer bootstrap
-- 1 admin user, roles/permissions, 2 posts, 1 page, 1 nav menu, 2 products + 1 license
-- =========================

-- Roles -------------------------------------------------------------------
INSERT INTO website_content.roles (id, key, name, description) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin',  'Administrator', 'Full access to all resources'),
    ('00000000-0000-0000-0000-000000000002', 'editor', 'Editor',        'Can create and publish content'),
    ('00000000-0000-0000-0000-000000000003', 'author', 'Author',        'Can create drafts and submit for review'),
    ('00000000-0000-0000-0000-000000000004', 'viewer', 'Viewer',        'Read-only access')
ON CONFLICT (key) DO NOTHING;

-- Permissions -------------------------------------------------------------
INSERT INTO website_content.permissions (id, key, name, description) VALUES
    ('10000000-0000-0000-0000-000000000001', 'post:create',      'Create Posts',      'Create new posts'),
    ('10000000-0000-0000-0000-000000000002', 'post:publish',     'Publish Posts',     'Publish posts to public'),
    ('10000000-0000-0000-0000-000000000003', 'post:archive',     'Archive Posts',     'Archive existing posts'),
    ('10000000-0000-0000-0000-000000000004', 'template:edit',    'Edit Templates',    'Edit content templates'),
    ('10000000-0000-0000-0000-000000000005', 'template:publish', 'Publish Templates', 'Publish templates to public'),
    ('10000000-0000-0000-0000-000000000006', 'user:manage',      'Manage Users',      'Manage users and role assignments'),
    ('10000000-0000-0000-0000-000000000007', 'media:upload',     'Upload Media',      'Upload media assets'),
    ('10000000-0000-0000-0000-000000000008', 'commerce:manage',  'Manage Commerce',   'Manage products, licenses, and purchases')
ON CONFLICT (key) DO NOTHING;

-- Admin gets all permissions ----------------------------------------------
INSERT INTO website_content.role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000001', id
FROM website_content.permissions
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Editor gets content permissions -----------------------------------------
INSERT INTO website_content.role_permissions (role_id, permission_id) VALUES
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000004'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000005'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000007')
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Author gets create-only permissions -------------------------------------
INSERT INTO website_content.role_permissions (role_id, permission_id) VALUES
    ('00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000007')
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Admin user ---------------------------------------------------------------
-- NOTE: password_hash below is a bcrypt placeholder — replace with a real hash before production.
-- To generate: SELECT crypt('your_password', gen_salt('bf', 12));
INSERT INTO website_content.users (id, email, username, password_hash, display_name, is_active, is_verified) VALUES
    (
        '20000000-0000-0000-0000-000000000001',
        'admin@caddystats.local',
        'admin',
        '$2a$12$placeholderHashReplaceBeforeProductionXXXXXXXXXXXXXXXXX',
        'CaddyStats Admin',
        TRUE,
        TRUE
    )
ON CONFLICT (email) DO NOTHING;

INSERT INTO website_content.user_roles (user_id, role_id) VALUES
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001')
ON CONFLICT (user_id, role_id) DO NOTHING;

-- SEO objects -------------------------------------------------------------
INSERT INTO website_content.seo (id, title, description) VALUES
    ('30000000-0000-0000-0000-000000000001', 'Welcome to CaddyStats', 'The home of golf analytics and content.'),
    ('30000000-0000-0000-0000-000000000002', 'About CaddyStats',      'Learn about the CaddyStats platform.')
ON CONFLICT DO NOTHING;

-- Posts -------------------------------------------------------------------
INSERT INTO website_content.posts
    (id, author_id, slug, title, excerpt, status, published_at, seo_id)
VALUES
    (
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        'welcome-to-caddystats',
        'Welcome to CaddyStats',
        'An introduction to the CaddyStats platform.',
        'published',
        now(),
        '30000000-0000-0000-0000-000000000001'
    ),
    (
        '40000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000001',
        'getting-started-golf-analytics',
        'Getting Started with Golf Analytics',
        'Your first steps toward data-driven golf insights.',
        'published',
        now(),
        NULL
    )
ON CONFLICT (slug) DO NOTHING;

-- Page --------------------------------------------------------------------
INSERT INTO website_content.pages
    (id, author_id, slug, title, status, published_at, seo_id)
VALUES
    (
        '50000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        'about',
        'About',
        'published',
        now(),
        '30000000-0000-0000-0000-000000000002'
    )
ON CONFLICT (slug) DO NOTHING;

-- Nav menu ----------------------------------------------------------------
INSERT INTO website_content.nav_menus (id, slug, name) VALUES
    ('60000000-0000-0000-0000-000000000001', 'primary', 'Primary Navigation')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO website_content.nav_items (menu_id, label, href, sort_order) VALUES
    ('60000000-0000-0000-0000-000000000001', 'Home',  '/',      1),
    ('60000000-0000-0000-0000-000000000001', 'Blog',  '/blog',  2),
    ('60000000-0000-0000-0000-000000000001', 'About', '/about', 3),
    ('60000000-0000-0000-0000-000000000001', 'Store', '/store', 4);

-- Products ----------------------------------------------------------------
INSERT INTO website_content.products
    (id, slug, name, description, product_type, price_cents, currency, status, published_at)
VALUES
    (
        '70000000-0000-0000-0000-000000000001',
        'caddystats-pro-template',
        'CaddyStats Pro Template',
        'A professional dashboard template for golf analytics.',
        'template',
        4900,
        'USD',
        'active',
        now()
    ),
    (
        '70000000-0000-0000-0000-000000000002',
        'caddystats-starter-template',
        'CaddyStats Starter Template',
        'Get started quickly with this free starter template.',
        'template',
        0,
        'USD',
        'active',
        now()
    )
ON CONFLICT (slug) DO NOTHING;

-- License for the starter product (free) ----------------------------------
INSERT INTO website_content.licenses
    (id, product_id, license_key, status)
VALUES
    (
        '80000000-0000-0000-0000-000000000001',
        '70000000-0000-0000-0000-000000000002',
        'STARTER-FREE-0001',
        'active'
    )
ON CONFLICT (license_key) DO NOTHING;
