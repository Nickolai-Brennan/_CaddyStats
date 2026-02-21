-- 0018_authors.sql
-- Adds WordPress-grade Author Profiles (supports guest authors + linked user accounts)
-- Schema: website_content
-- Requirements:
--   - gen_random_uuid() available (pgcrypto)
--   - public.set_updated_at() trigger function exists
-- Notes:
--   - Does NOT drop any existing post author column/constraints.
--   - Adds authors + post_authors join table (supports multi-author bylines).
--   - Adds posts.primary_author_id column (optional, fast “main author” access).

-- =========================
-- 1) AUTHORS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS website_content.authors (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Optional link to a real login account (nullable supports guest authors)
  user_id         UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  -- Public author identity
  slug            TEXT NOT NULL,
  display_name    TEXT NOT NULL,
  bio             TEXT NULL,

  -- Media (optional; references your media system if present)
  avatar_asset_id UUID NULL REFERENCES website_content.media_assets(id) ON DELETE SET NULL,

  -- Social/contact (kept flexible, but minimal JSONB)
  socials_jsonb    JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Publish controls
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,

  -- Standard columns
  deleted_at      TIMESTAMPTZ NULL,
  is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT authors_slug_unique UNIQUE (slug),
  CONSTRAINT authors_user_id_unique UNIQUE (user_id),
  CONSTRAINT authors_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  )
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'authors_set_updated_at') THEN
    CREATE TRIGGER authors_set_updated_at
    BEFORE UPDATE ON website_content.authors
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_authors_is_active ON website_content.authors(is_active) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_authors_user_id ON website_content.authors(user_id);

-- =========================
-- 2) POSTS: PRIMARY AUTHOR (optional, but recommended)
-- =========================
-- We do NOT assume you already have any particular author column.
-- We add a new one that points to authors.id.
ALTER TABLE website_content.posts
  ADD COLUMN IF NOT EXISTS primary_author_id UUID NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'posts_primary_author_fk'
  ) THEN
    ALTER TABLE website_content.posts
      ADD CONSTRAINT posts_primary_author_fk
      FOREIGN KEY (primary_author_id)
      REFERENCES website_content.authors(id)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_posts_primary_author_id
  ON website_content.posts(primary_author_id);

-- =========================
-- 3) MULTI-AUTHOR SUPPORT (recommended)
-- =========================
-- WordPress is single-author by default, but modern editorial needs multi-author bylines.
CREATE TABLE IF NOT EXISTS website_content.post_authors (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id    UUID NOT NULL REFERENCES website_content.posts(id) ON DELETE CASCADE,
  author_id  UUID NOT NULL REFERENCES website_content.authors(id) ON DELETE CASCADE,

  -- byline ordering + role
  sort_order INTEGER NOT NULL DEFAULT 1,
  role       TEXT NULL, -- e.g. 'writer', 'editor', 'contributor'

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT post_authors_unique UNIQUE (post_id, author_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'post_authors_set_updated_at') THEN
    CREATE TRIGGER post_authors_set_updated_at
    BEFORE UPDATE ON website_content.post_authors
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_post_authors_post_id ON website_content.post_authors(post_id);
CREATE INDEX IF NOT EXISTS idx_post_authors_author_id ON website_content.post_authors(author_id);
CREATE INDEX IF NOT EXISTS idx_post_authors_post_sort ON website_content.post_authors(post_id, sort_order);

-- =========================
-- 4) OPTIONAL BACKFILL HOOK (safe stub)
-- =========================
-- We cannot safely backfill without knowing your existing columns
-- (e.g., posts.created_by_id, posts.author_id, etc.).
-- Do your backfill explicitly once you confirm which column holds the user reference.

-- Example backfill pattern (ONLY RUN AFTER CONFIRMING your column names):
-- 1) Create authors for existing users:
-- INSERT INTO website_content.authors (user_id, slug, display_name)
-- SELECT u.id, lower(u.username), coalesce(u.display_name, u.username)
-- FROM website_content.users u
-- WHERE NOT EXISTS (SELECT 1 FROM website_content.authors a WHERE a.user_id = u.id);
--
-- 2) Set primary_author_id on posts:
-- UPDATE website_content.posts p
-- SET primary_author_id = a.id
-- FROM website_content.authors a
-- WHERE a.user_id = p.created_by_id;  -- replace created_by_id with your actual column
