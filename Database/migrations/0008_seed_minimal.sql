-- 0008_seed_minimal.sql
-- Minimal seed: 1 admin user, roles/permissions, 2 posts, 1 page, 1 nav menu, 2 products + 1 license

SET search_path TO website_content;

-- Roles -------------------------------------------------------------------
INSERT INTO roles (id, name, description) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin',  'Full access to all resources'),
    ('00000000-0000-0000-0000-000000000002', 'editor', 'Can create and publish content'),
    ('00000000-0000-0000-0000-000000000003', 'viewer', 'Read-only access');

-- Permissions -------------------------------------------------------------
INSERT INTO permissions (id, key, description) VALUES
    ('10000000-0000-0000-0000-000000000001', 'post:create',      'Create posts'),
    ('10000000-0000-0000-0000-000000000002', 'post:publish',     'Publish posts'),
    ('10000000-0000-0000-0000-000000000003', 'post:archive',     'Archive posts'),
    ('10000000-0000-0000-0000-000000000004', 'template:edit',    'Edit templates'),
    ('10000000-0000-0000-0000-000000000005', 'template:publish', 'Publish templates'),
    ('10000000-0000-0000-0000-000000000006', 'user:manage',      'Manage users and roles'),
    ('10000000-0000-0000-0000-000000000007', 'media:upload',     'Upload media assets'),
    ('10000000-0000-0000-0000-000000000008', 'commerce:manage',  'Manage products and purchases');

-- Admin gets all permissions ----------------------------------------------
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000001', id FROM permissions;

-- Editor gets content permissions -----------------------------------------
INSERT INTO role_permissions (role_id, permission_id) VALUES
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000004'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000005'),
    ('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000007');

-- Admin user (password: admin_seed_password — change before production!) -
-- Hash generated with: SELECT crypt('admin_seed_password', gen_salt('bf'));
INSERT INTO users (id, email, password_hash, display_name, is_verified, status) VALUES
    (
        '20000000-0000-0000-0000-000000000001',
        'admin@caddystats.local',
        '$2a$10$placeholder_hash_change_in_production_xxxxxxxxxxxxxx',
        'CaddyStats Admin',
        true,
        'active'
    );

INSERT INTO user_roles (user_id, role_id) VALUES
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001');

-- SEO objects -------------------------------------------------------------
INSERT INTO seo (id, meta_title, meta_description) VALUES
    ('30000000-0000-0000-0000-000000000001', 'Welcome to CaddyStats', 'The home of golf analytics and content.'),
    ('30000000-0000-0000-0000-000000000002', 'About CaddyStats',      'Learn about the CaddyStats platform.');

-- Posts -------------------------------------------------------------------
INSERT INTO posts (id, author_id, title, slug, excerpt, status, published_at, seo_id) VALUES
    (
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        'Welcome to CaddyStats',
        'welcome-to-caddystats',
        'An introduction to the CaddyStats platform.',
        'published',
        now(),
        '30000000-0000-0000-0000-000000000001'
    ),
    (
        '40000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000001',
        'Getting Started with Golf Analytics',
        'getting-started-golf-analytics',
        'Your first steps toward data-driven golf insights.',
        'published',
        now(),
        NULL
    );

-- Page --------------------------------------------------------------------
INSERT INTO pages (id, author_id, title, slug, status, published_at, seo_id) VALUES
    (
        '50000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        'About',
        'about',
        'published',
        now(),
        '30000000-0000-0000-0000-000000000002'
    );

-- Nav menu ----------------------------------------------------------------
INSERT INTO nav_menus (id, name, slug) VALUES
    ('60000000-0000-0000-0000-000000000001', 'Primary Navigation', 'primary');

INSERT INTO nav_items (menu_id, label, url, sort_order) VALUES
    ('60000000-0000-0000-0000-000000000001', 'Home',  '/',        1),
    ('60000000-0000-0000-0000-000000000001', 'Blog',  '/blog',    2),
    ('60000000-0000-0000-0000-000000000001', 'About', '/about',   3),
    ('60000000-0000-0000-0000-000000000001', 'Store', '/store',   4);

-- Products ----------------------------------------------------------------
INSERT INTO products (id, name, slug, description, price_cents, currency, status) VALUES
    (
        '70000000-0000-0000-0000-000000000001',
        'CaddyStats Pro Template',
        'caddystats-pro-template',
        'A professional dashboard template for golf analytics.',
        4900,
        'USD',
        'active'
    ),
    (
        '70000000-0000-0000-0000-000000000002',
        'CaddyStats Starter Template',
        'caddystats-starter-template',
        'Get started quickly with this free starter template.',
        0,
        'USD',
        'active'
    );

-- License for the starter product (free) ----------------------------------
INSERT INTO licenses (id, product_id, key, status) VALUES
    (
        '80000000-0000-0000-0000-000000000001',
        '70000000-0000-0000-0000-000000000002',
        'STARTER-FREE-0001',
        'active'
    );
