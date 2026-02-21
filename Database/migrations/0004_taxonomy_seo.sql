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
