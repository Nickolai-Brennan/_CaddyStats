-- Ultimate Blog Add-ons: Options + Meta tables (WordPress-style extensibility)
-- Requires:
--   0000_extensions.sql (pgcrypto, citext)
--   0001_create_schema.sql (website_content)
--   0002_triggers.sql (public.set_updated_at)

-- =========================
-- Options (wp_options equivalent)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.options (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT NOT NULL,
  value_jsonb JSONB NOT NULL DEFAULT '{}'::jsonb,
  autoload    BOOLEAN NOT NULL DEFAULT TRUE,

  deleted_at  TIMESTAMPTZ NULL,
  is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT options_key_unique UNIQUE (key),
  CONSTRAINT options_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  )
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'options_set_updated_at') THEN
    CREATE TRIGGER options_set_updated_at
    BEFORE UPDATE ON website_content.options
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Meta tables (wp_postmeta / wp_usermeta / wp_commentmeta equivalents)
-- Policy:
--   - value_jsonb for flexible structured values
--   - value_text for simple string use cases
--   - UNIQUE(owner_id, key) keeps one value per key (recommended)
-- =========================

CREATE TABLE IF NOT EXISTS website_content.post_meta (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id     UUID NOT NULL REFERENCES website_content.posts(id) ON DELETE CASCADE,
  key         TEXT NOT NULL,
  value_text  TEXT NULL,
  value_jsonb JSONB NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT post_meta_unique UNIQUE (post_id, key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'post_meta_set_updated_at') THEN
    CREATE TRIGGER post_meta_set_updated_at
    BEFORE UPDATE ON website_content.post_meta
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.user_meta (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  key         TEXT NOT NULL,
  value_text  TEXT NULL,
  value_jsonb JSONB NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT user_meta_unique UNIQUE (user_id, key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'user_meta_set_updated_at') THEN
    CREATE TRIGGER user_meta_set_updated_at
    BEFORE UPDATE ON website_content.user_meta
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.comment_meta (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id  UUID NOT NULL REFERENCES website_content.comments(id) ON DELETE CASCADE,
  key         TEXT NOT NULL,
  value_text  TEXT NULL,
  value_jsonb JSONB NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT comment_meta_unique UNIQUE (comment_id, key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'comment_meta_set_updated_at') THEN
    CREATE TRIGGER comment_meta_set_updated_at
    BEFORE UPDATE ON website_content.comment_meta
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.product_meta (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID NOT NULL REFERENCES website_content.products(id) ON DELETE CASCADE,
  key         TEXT NOT NULL,
  value_text  TEXT NULL,
  value_jsonb JSONB NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT product_meta_unique UNIQUE (product_id, key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'product_meta_set_updated_at') THEN
    CREATE TRIGGER product_meta_set_updated_at
    BEFORE UPDATE ON website_content.product_meta
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
