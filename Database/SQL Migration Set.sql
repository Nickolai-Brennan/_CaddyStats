Below is a full, webapp-only SQL migration set (no golf stats) for one database with one schema: website_content.

Drop these files into: /database/migrations/ and run in order.


---

/database/migrations/0000_extensions.sql

-- Enables UUID generation + optional citext for email/username

CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS citext;    -- case-insensitive text


---

/database/migrations/0001_create_schema.sql

CREATE SCHEMA IF NOT EXISTS website_content;


---

/database/migrations/0002_triggers.sql

-- updated_at trigger (shared)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Soft delete helper consistency is enforced via CHECK constraints per-table.

-- Search vector trigger (for FTS)
CREATE OR REPLACE FUNCTION website_content.set_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.title,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.excerpt,'')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION website_content.set_product_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.name,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description,'')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


---

/database/migrations/0003_auth_rbac.sql

-- =========================
-- Auth + RBAC
-- =========================

CREATE TABLE IF NOT EXISTS website_content.users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         CITEXT NOT NULL,
  username      CITEXT NULL,
  password_hash TEXT NOT NULL,

  display_name  TEXT NULL,
  avatar_url    TEXT NULL,

  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  is_verified   BOOLEAN NOT NULL DEFAULT FALSE,

  deleted_at    TIMESTAMPTZ NULL,
  is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT users_email_unique UNIQUE (email),
  CONSTRAINT users_username_unique UNIQUE (username),
  CONSTRAINT users_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  )
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'users_set_updated_at') THEN
    CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON website_content.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.roles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT NOT NULL,   -- admin, editor, author, viewer
  name        TEXT NOT NULL,
  description TEXT NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT roles_key_unique UNIQUE (key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'roles_set_updated_at') THEN
    CREATE TRIGGER roles_set_updated_at
    BEFORE UPDATE ON website_content.roles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.permissions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT NOT NULL,   -- post:create, post:publish, etc.
  name        TEXT NOT NULL,
  description TEXT NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT permissions_key_unique UNIQUE (key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'permissions_set_updated_at') THEN
    CREATE TRIGGER permissions_set_updated_at
    BEFORE UPDATE ON website_content.permissions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.user_roles (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  role_id    UUID NOT NULL REFERENCES website_content.roles(id) ON DELETE CASCADE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT user_roles_unique UNIQUE (user_id, role_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'user_roles_set_updated_at') THEN
    CREATE TRIGGER user_roles_set_updated_at
    BEFORE UPDATE ON website_content.user_roles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.role_permissions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id       UUID NOT NULL REFERENCES website_content.roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES website_content.permissions(id) ON DELETE CASCADE,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT role_permissions_unique UNIQUE (role_id, permission_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'role_permissions_set_updated_at') THEN
    CREATE TRIGGER role_permissions_set_updated_at
    BEFORE UPDATE ON website_content.role_permissions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;


---

/database/migrations/0004_taxonomy_seo.sql

-- =========================
-- Taxonomy + SEO
-- =========================

CREATE TABLE IF NOT EXISTS website_content.tags (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug       TEXT NOT NULL,
  name       TEXT NOT NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT tags_slug_unique UNIQUE (slug)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tags_set_updated_at') THEN
    CREATE TRIGGER tags_set_updated_at
    BEFORE UPDATE ON website_content.tags
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.categories (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug       TEXT NOT NULL,
  name       TEXT NOT NULL,
  parent_id  UUID NULL REFERENCES website_content.categories(id) ON DELETE SET NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT categories_slug_unique UNIQUE (slug)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'categories_set_updated_at') THEN
    CREATE TRIGGER categories_set_updated_at
    BEFORE UPDATE ON website_content.categories
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.seo (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NULL,
  description     TEXT NULL,
  canonical_url   TEXT NULL,
  og_title        TEXT NULL,
  og_description  TEXT NULL,
  og_image_url    TEXT NULL,
  twitter_card    TEXT NULL,
  noindex         BOOLEAN NOT NULL DEFAULT FALSE,
  nofollow        BOOLEAN NOT NULL DEFAULT FALSE,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'seo_set_updated_at') THEN
    CREATE TRIGGER seo_set_updated_at
    BEFORE UPDATE ON website_content.seo
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;


---

/database/migrations/0005_cms_content.sql

-- =========================
-- CMS: posts, pages, templates, revisions, comments
-- =========================

CREATE TABLE IF NOT EXISTS website_content.posts (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  author_id          UUID NOT NULL REFERENCES website_content.users(id) ON DELETE RESTRICT,
  seo_id             UUID NULL REFERENCES website_content.seo(id) ON DELETE SET NULL,

  slug               TEXT NOT NULL,
  title              TEXT NOT NULL,
  excerpt            TEXT NULL,
  featured_image_url TEXT NULL,

  status             TEXT NOT NULL DEFAULT 'draft',
  published_at       TIMESTAMPTZ NULL,
  archived_at        TIMESTAMPTZ NULL,

  content_jsonb      JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- FTS
  search_vector      TSVECTOR NULL,

  deleted_at         TIMESTAMPTZ NULL,
  is_deleted         BOOLEAN NOT NULL DEFAULT FALSE,

  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT posts_slug_unique UNIQUE (slug),
  CONSTRAINT posts_status_check CHECK (status IN ('draft','review','published','archived')),
  CONSTRAINT posts_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  ),
  CONSTRAINT posts_publish_consistency CHECK (
    (status <> 'published' AND published_at IS NULL) OR
    (status = 'published'  AND published_at IS NOT NULL)
  )
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'posts_set_updated_at') THEN
    CREATE TRIGGER posts_set_updated_at
    BEFORE UPDATE ON website_content.posts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'posts_set_search_vector') THEN
    CREATE TRIGGER posts_set_search_vector
    BEFORE INSERT OR UPDATE OF title, excerpt ON website_content.posts
    FOR EACH ROW EXECUTE FUNCTION website_content.set_post_search_vector();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.pages (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  author_id     UUID NOT NULL REFERENCES website_content.users(id) ON DELETE RESTRICT,
  seo_id        UUID NULL REFERENCES website_content.seo(id) ON DELETE SET NULL,

  slug          TEXT NOT NULL,
  title         TEXT NOT NULL,

  status        TEXT NOT NULL DEFAULT 'draft',
  published_at  TIMESTAMPTZ NULL,
  archived_at   TIMESTAMPTZ NULL,

  content_jsonb JSONB NOT NULL DEFAULT '{}'::jsonb,

  deleted_at    TIMESTAMPTZ NULL,
  is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT pages_slug_unique UNIQUE (slug),
  CONSTRAINT pages_status_check CHECK (status IN ('draft','review','published','archived')),
  CONSTRAINT pages_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  ),
  CONSTRAINT pages_publish_consistency CHECK (
    (status <> 'published' AND published_at IS NULL) OR
    (status = 'published'  AND published_at IS NOT NULL)
  )
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'pages_set_updated_at') THEN
    CREATE TRIGGER pages_set_updated_at
    BEFORE UPDATE ON website_content.pages
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.templates (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  author_id     UUID NOT NULL REFERENCES website_content.users(id) ON DELETE RESTRICT,
  seo_id        UUID NULL REFERENCES website_content.seo(id) ON DELETE SET NULL,

  slug          TEXT NOT NULL,
  name          TEXT NOT NULL,
  description   TEXT NULL,

  status        TEXT NOT NULL DEFAULT 'draft',
  content_jsonb JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT templates_slug_unique UNIQUE (slug),
  CONSTRAINT templates_status_check CHECK (status IN ('draft','published','archived'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'templates_set_updated_at') THEN
    CREATE TRIGGER templates_set_updated_at
    BEFORE UPDATE ON website_content.templates
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Optional normalized blocks table (kept simple). You can use only JSONB initially.
CREATE TABLE IF NOT EXISTS website_content.blocks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type  TEXT NOT NULL,  -- post|page|template
  owner_id    UUID NOT NULL,
  sort_order  INTEGER NOT NULL DEFAULT 0,

  block_type  TEXT NOT NULL,
  data_jsonb  JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT blocks_owner_type_check CHECK (owner_type IN ('post','page','template'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'blocks_set_updated_at') THEN
    CREATE TRIGGER blocks_set_updated_at
    BEFORE UPDATE ON website_content.blocks
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.revisions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type    TEXT NOT NULL, -- post|page|template
  entity_id      UUID NOT NULL,
  author_id      UUID NOT NULL REFERENCES website_content.users(id) ON DELETE RESTRICT,
  message        TEXT NULL,
  snapshot_jsonb JSONB NOT NULL,

  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT revisions_entity_type_check CHECK (entity_type IN ('post','page','template'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'revisions_set_updated_at') THEN
    CREATE TRIGGER revisions_set_updated_at
    BEFORE UPDATE ON website_content.revisions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id     UUID NOT NULL REFERENCES website_content.posts(id) ON DELETE CASCADE,
  author_id   UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  body        TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'visible', -- visible|hidden|spam

  deleted_at  TIMESTAMPTZ NULL,
  is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT comments_status_check CHECK (status IN ('visible','hidden','spam')),
  CONSTRAINT comments_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  )
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'comments_set_updated_at') THEN
    CREATE TRIGGER comments_set_updated_at
    BEFORE UPDATE ON website_content.comments
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Join tables
CREATE TABLE IF NOT EXISTS website_content.post_tags (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id    UUID NOT NULL REFERENCES website_content.posts(id) ON DELETE CASCADE,
  tag_id     UUID NOT NULL REFERENCES website_content.tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT post_tags_unique UNIQUE (post_id, tag_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'post_tags_set_updated_at') THEN
    CREATE TRIGGER post_tags_set_updated_at
    BEFORE UPDATE ON website_content.post_tags
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.post_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id     UUID NOT NULL REFERENCES website_content.posts(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES website_content.categories(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT post_categories_unique UNIQUE (post_id, category_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'post_categories_set_updated_at') THEN
    CREATE TRIGGER post_categories_set_updated_at
    BEFORE UPDATE ON website_content.post_categories
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;


---

/database/migrations/0006_media_nav_marketplace.sql

-- =========================
-- Media assets (uploads), Navigation, Marketplace, Events
-- =========================

CREATE TABLE IF NOT EXISTS website_content.media_assets (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uploader_id      UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  file_name        TEXT NOT NULL,
  content_type     TEXT NOT NULL,
  byte_size        BIGINT NOT NULL,

  storage_provider TEXT NOT NULL DEFAULT 's3', -- s3|r2|gcs|local
  storage_bucket   TEXT NULL,
  storage_key      TEXT NOT NULL,
  public_url       TEXT NULL,

  checksum_sha256  TEXT NULL,

  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'media_assets_set_updated_at') THEN
    CREATE TRIGGER media_assets_set_updated_at
    BEFORE UPDATE ON website_content.media_assets
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Optional: where-used tracking
CREATE TABLE IF NOT EXISTS website_content.asset_links (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id    UUID NOT NULL REFERENCES website_content.media_assets(id) ON DELETE CASCADE,
  owner_type  TEXT NOT NULL, -- post|page|template
  owner_id    UUID NOT NULL,
  note        TEXT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT asset_links_owner_type_check CHECK (owner_type IN ('post','page','template'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'asset_links_set_updated_at') THEN
    CREATE TRIGGER asset_links_set_updated_at
    BEFORE UPDATE ON website_content.asset_links
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Navigation
CREATE TABLE IF NOT EXISTS website_content.nav_menus (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug       TEXT NOT NULL,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT nav_menus_slug_unique UNIQUE (slug)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'nav_menus_set_updated_at') THEN
    CREATE TRIGGER nav_menus_set_updated_at
    BEFORE UPDATE ON website_content.nav_menus
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.nav_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_id     UUID NOT NULL REFERENCES website_content.nav_menus(id) ON DELETE CASCADE,

  parent_id   UUID NULL REFERENCES website_content.nav_items(id) ON DELETE CASCADE,
  sort_order  INTEGER NOT NULL DEFAULT 0,

  label       TEXT NOT NULL,
  href        TEXT NULL,
  page_id     UUID NULL REFERENCES website_content.pages(id) ON DELETE SET NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'nav_items_set_updated_at') THEN
    CREATE TRIGGER nav_items_set_updated_at
    BEFORE UPDATE ON website_content.nav_items
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Marketplace
CREATE TABLE IF NOT EXISTS website_content.products (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug         TEXT NOT NULL,
  name         TEXT NOT NULL,
  description  TEXT NULL,

  product_type TEXT NOT NULL DEFAULT 'template', -- template|doc|bundle|other
  price_cents  INTEGER NOT NULL DEFAULT 0,
  currency     TEXT NOT NULL DEFAULT 'USD',

  status       TEXT NOT NULL DEFAULT 'active', -- active|inactive|archived

  -- FTS
  search_vector TSVECTOR NULL,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT products_slug_unique UNIQUE (slug),
  CONSTRAINT products_type_check CHECK (product_type IN ('template','doc','bundle','other')),
  CONSTRAINT products_status_check CHECK (status IN ('active','inactive','archived'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'products_set_updated_at') THEN
    CREATE TRIGGER products_set_updated_at
    BEFORE UPDATE ON website_content.products
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'products_set_search_vector') THEN
    CREATE TRIGGER products_set_search_vector
    BEFORE INSERT OR UPDATE OF name, description ON website_content.products
    FOR EACH ROW EXECUTE FUNCTION website_content.set_product_search_vector();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.licenses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id      UUID NOT NULL REFERENCES website_content.products(id) ON DELETE CASCADE,
  license_key     TEXT NOT NULL, -- store hashed later if desired
  max_activations INTEGER NOT NULL DEFAULT 1,
  expires_at      TIMESTAMPTZ NULL,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT licenses_key_unique UNIQUE (license_key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'licenses_set_updated_at') THEN
    CREATE TRIGGER licenses_set_updated_at
    BEFORE UPDATE ON website_content.licenses
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.purchases (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id     UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,
  product_id   UUID NOT NULL REFERENCES website_content.products(id) ON DELETE RESTRICT,
  license_id   UUID NULL REFERENCES website_content.licenses(id) ON DELETE SET NULL,

  amount_cents INTEGER NOT NULL,
  currency     TEXT NOT NULL DEFAULT 'USD',

  provider     TEXT NOT NULL DEFAULT 'manual', -- stripe|paddle|manual
  provider_ref TEXT NULL,

  status       TEXT NOT NULL DEFAULT 'paid',   -- pending|paid|refunded|failed

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT purchases_status_check CHECK (status IN ('pending','paid','refunded','failed'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'purchases_set_updated_at') THEN
    CREATE TRIGGER purchases_set_updated_at
    BEFORE UPDATE ON website_content.purchases
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Simple analytics events
CREATE TABLE IF NOT EXISTS website_content.events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type  TEXT NOT NULL, -- pageview|click|search|purchase|custom
  user_id     UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,
  session_id  TEXT NULL,
  path        TEXT NULL,
  referrer    TEXT NULL,
  user_agent  TEXT NULL,
  ip_hash     TEXT NULL, -- store a hash, not raw IP (privacy)

  properties  JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT events_type_check CHECK (event_type IN ('pageview','click','search','purchase','custom'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'events_set_updated_at') THEN
    CREATE TRIGGER events_set_updated_at
    BEFORE UPDATE ON website_content.events
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;


---

/database/migrations/0007_indexes_search.sql

-- =========================
-- Indexes (explicit pack)
-- =========================

-- Users
CREATE INDEX IF NOT EXISTS idx_users_active ON website_content.users(is_active) WHERE is_deleted = FALSE;

-- RBAC
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON website_content.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON website_content.user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON website_content.role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON website_content.role_permissions(permission_id);

-- Posts
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON website_content.posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON website_content.posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_published_at ON website_content.posts(published_at) WHERE status = 'published' AND is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_posts_updated_at ON website_content.posts(updated_at);

-- FTS (Posts)
CREATE INDEX IF NOT EXISTS idx_posts_search_vector ON website_content.posts USING GIN (search_vector);

-- Pages
CREATE INDEX IF NOT EXISTS idx_pages_author_id ON website_content.pages(author_id);
CREATE INDEX IF NOT EXISTS idx_pages_status ON website_content.pages(status);
CREATE INDEX IF NOT EXISTS idx_pages_published_at ON website_content.pages(published_at) WHERE status = 'published' AND is_deleted = FALSE;

-- Templates
CREATE INDEX IF NOT EXISTS idx_templates_author_id ON website_content.templates(author_id);
CREATE INDEX IF NOT EXISTS idx_templates_status ON website_content.templates(status);

-- Join tables
CREATE INDEX IF NOT EXISTS idx_post_tags_post_id ON website_content.post_tags(post_id);
CREATE INDEX IF NOT EXISTS idx_post_tags_tag_id ON website_content.post_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_post_categories_post_id ON website_content.post_categories(post_id);
CREATE INDEX IF NOT EXISTS idx_post_categories_category_id ON website_content.post_categories(category_id);

-- Comments
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON website_content.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_status ON website_content.comments(status) WHERE is_deleted = FALSE;

-- Media
CREATE INDEX IF NOT EXISTS idx_media_assets_uploader_id ON website_content.media_assets(uploader_id);
CREATE INDEX IF NOT EXISTS idx_asset_links_asset_id ON website_content.asset_links(asset_id);

-- Nav
CREATE INDEX IF NOT EXISTS idx_nav_items_menu_id ON website_content.nav_items(menu_id);
CREATE INDEX IF NOT EXISTS idx_nav_items_parent_id ON website_content.nav_items(parent_id);

-- Marketplace
CREATE INDEX IF NOT EXISTS idx_products_status ON website_content.products(status);
CREATE INDEX IF NOT EXISTS idx_products_type ON website_content.products(product_type);
CREATE INDEX IF NOT EXISTS idx_products_search_vector ON website_content.products USING GIN (search_vector);

CREATE INDEX IF NOT EXISTS idx_licenses_product_id ON website_content.licenses(product_id);
CREATE INDEX IF NOT EXISTS idx_purchases_buyer_id ON website_content.purchases(buyer_id);
CREATE INDEX IF NOT EXISTS idx_purchases_product_id ON website_content.purchases(product_id);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON website_content.purchases(status);

-- Events
CREATE INDEX IF NOT EXISTS idx_events_type_created_at ON website_content.events(event_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_user_id ON website_content.events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_properties_gin ON website_content.events USING GIN (properties);


---

/database/migrations/0008_seed_minimal.sql

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


---

Quick sanity checks (run after migrations)

\dn
\dt website_content.*
SELECT to_regclass('website_content.purchases') AS purchases_table;
SELECT count(*) FROM website_content.posts;
SELECT count(*) FROM website_content.products;

If you want, paste your current DATABASE_URL (just host/dbname, redact password) and your migration runner path, and I’ll tell you exactly how to run these so you don’t hit “relation does not exist” again.
