-- =========================
-- CMS: posts, pages, templates, blocks, revisions, comments
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
