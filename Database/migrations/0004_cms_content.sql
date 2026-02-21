-- 0004_cms_content.sql
-- CMS core tables: posts, pages, templates, revisions, comments

SET search_path TO website_content;

-- Posts -------------------------------------------------------------------
CREATE TABLE posts (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id      UUID        NOT NULL REFERENCES users(id),
    title          TEXT        NOT NULL,
    slug           TEXT        NOT NULL UNIQUE,
    excerpt        TEXT,
    content_jsonb  JSONB,
    featured_image TEXT,
    status         TEXT        NOT NULL DEFAULT 'draft'
                               CHECK (status IN ('draft', 'review', 'published', 'archived')),
    published_at   TIMESTAMPTZ NULL,
    -- seo_id added by 0005_taxonomy_seo.sql
    deleted_at     TIMESTAMPTZ NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    search_vector  TSVECTOR,
    CONSTRAINT published_post_has_timestamp
        CHECK (status <> 'published' OR published_at IS NOT NULL)
);

CREATE TRIGGER trg_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Pages -------------------------------------------------------------------
CREATE TABLE pages (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id      UUID        NOT NULL REFERENCES users(id),
    title          TEXT        NOT NULL,
    slug           TEXT        NOT NULL UNIQUE,
    content_jsonb  JSONB,
    featured_image TEXT,
    status         TEXT        NOT NULL DEFAULT 'draft'
                               CHECK (status IN ('draft', 'review', 'published', 'archived')),
    published_at   TIMESTAMPTZ NULL,
    -- seo_id added by 0005_taxonomy_seo.sql
    deleted_at     TIMESTAMPTZ NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_pages_updated_at
    BEFORE UPDATE ON pages
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Templates ---------------------------------------------------------------
CREATE TABLE templates (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id      UUID        NOT NULL REFERENCES users(id),
    name           TEXT        NOT NULL,
    slug           TEXT        NOT NULL UNIQUE,
    description    TEXT,
    content_jsonb  JSONB,
    status         TEXT        NOT NULL DEFAULT 'draft'
                               CHECK (status IN ('draft', 'review', 'published', 'archived')),
    published_at   TIMESTAMPTZ NULL,
    -- seo_id added by 0005_taxonomy_seo.sql
    deleted_at     TIMESTAMPTZ NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_templates_updated_at
    BEFORE UPDATE ON templates
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Revisions (generic entity snapshot) -------------------------------------
CREATE TABLE revisions (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type    TEXT        NOT NULL,
    entity_id      UUID        NOT NULL,
    snapshot_jsonb JSONB       NOT NULL,
    author_id      UUID        REFERENCES users(id),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Comments ----------------------------------------------------------------
CREATE TABLE comments (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id      UUID        NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    author_id    UUID        REFERENCES users(id),
    author_name  TEXT,
    author_email TEXT,
    body         TEXT        NOT NULL,
    status       TEXT        NOT NULL DEFAULT 'pending'
                             CHECK (status IN ('pending', 'approved', 'spam', 'trash')),
    parent_id    UUID        REFERENCES comments(id),
    deleted_at   TIMESTAMPTZ NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_comments_updated_at
    BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
