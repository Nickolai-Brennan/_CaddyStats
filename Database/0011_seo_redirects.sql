-- Ultimate Blog Add-ons: SEO governance (redirects + slug history + optional sitemap cache)

-- =========================
-- Redirects
-- =========================
CREATE TABLE IF NOT EXISTS website_content.redirects (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_path   TEXT NOT NULL,
  to_path     TEXT NOT NULL,
  status_code INTEGER NOT NULL DEFAULT 301, -- 301/302/307/308
  hits        BIGINT NOT NULL DEFAULT 0,
  last_hit_at TIMESTAMPTZ NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT redirects_from_path_unique UNIQUE (from_path),
  CONSTRAINT redirects_status_code_check CHECK (status_code IN (301,302,307,308))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'redirects_set_updated_at') THEN
    CREATE TRIGGER redirects_set_updated_at
    BEFORE UPDATE ON website_content.redirects
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Slug history (can be used to auto-create redirects)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.slug_history (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL, -- post|page|template|product|category|tag
  entity_id   UUID NOT NULL,
  old_slug    TEXT NOT NULL,
  new_slug    TEXT NOT NULL,
  changed_by  UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,
  changed_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT slug_history_entity_type_check CHECK (entity_type IN ('post','page','template','product','category','tag'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'slug_history_set_updated_at') THEN
    CREATE TRIGGER slug_history_set_updated_at
    BEFORE UPDATE ON website_content.slug_history
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Optional: sitemap cache (store generated sitemap fragments)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.sitemap_cache (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cache_key    TEXT NOT NULL,
  xml_text     TEXT NOT NULL,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at   TIMESTAMPTZ NULL,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT sitemap_cache_key_unique UNIQUE (cache_key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'sitemap_cache_set_updated_at') THEN
    CREATE TRIGGER sitemap_cache_set_updated_at
    BEFORE UPDATE ON website_content.sitemap_cache
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
