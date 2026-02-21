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

  status       TEXT NOT NULL DEFAULT 'draft',
  published_at TIMESTAMPTZ NULL,

  seo_id       UUID NULL REFERENCES website_content.seo(id) ON DELETE SET NULL,

  -- FTS
  search_vector TSVECTOR NULL,

  deleted_at   TIMESTAMPTZ NULL,
  is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT products_slug_unique UNIQUE (slug),
  CONSTRAINT products_status_check CHECK (status IN ('draft','active','archived')),
  CONSTRAINT products_type_check CHECK (product_type IN ('template','doc','bundle','other')),
  CONSTRAINT products_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  )
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
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID NOT NULL REFERENCES website_content.products(id) ON DELETE RESTRICT,
  user_id     UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  license_key TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'active', -- active|revoked|expired
  expires_at  TIMESTAMPTZ NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT licenses_key_unique UNIQUE (license_key),
  CONSTRAINT licenses_status_check CHECK (status IN ('active','revoked','expired'))
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
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,
  product_id      UUID NOT NULL REFERENCES website_content.products(id) ON DELETE RESTRICT,
  license_id      UUID NULL REFERENCES website_content.licenses(id) ON DELETE SET NULL,

  amount_cents    INTEGER NOT NULL,
  currency        TEXT NOT NULL DEFAULT 'USD',

  provider        TEXT NOT NULL DEFAULT 'manual', -- stripe|paddle|manual
  provider_txn_id TEXT NULL,

  status          TEXT NOT NULL DEFAULT 'completed',

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT purchases_status_check CHECK (status IN ('pending','completed','refunded','failed')),
  CONSTRAINT purchases_provider_check CHECK (provider IN ('stripe','paddle','manual'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'purchases_set_updated_at') THEN
    CREATE TRIGGER purchases_set_updated_at
    BEFORE UPDATE ON website_content.purchases
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Analytics Events (pageview, click, purchase, search)
CREATE TABLE IF NOT EXISTS website_content.events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type  TEXT NOT NULL, -- pageview|click|purchase|search
  user_id     UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,
  session_id  TEXT NULL,
  path        TEXT NULL,
  referrer    TEXT NULL,
  properties  JSONB NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
