-- 0005_taxonomy_seo.sql
-- Taxonomy (tags, categories) + SEO object + junction tables

SET search_path TO website_content;

-- Tags --------------------------------------------------------------------
CREATE TABLE tags (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT        NOT NULL UNIQUE,
    slug       TEXT        NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_tags_updated_at
    BEFORE UPDATE ON tags
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Categories (hierarchical via parent_id) --------------------------------
CREATE TABLE categories (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL UNIQUE,
    slug        TEXT        NOT NULL UNIQUE,
    description TEXT,
    parent_id   UUID        REFERENCES categories(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Post ↔ Tag junction -----------------------------------------------------
CREATE TABLE post_tags (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id  UUID NOT NULL REFERENCES tags(id)  ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);

-- Post ↔ Category junction ------------------------------------------------
CREATE TABLE post_categories (
    post_id     UUID NOT NULL REFERENCES posts(id)       ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id)  ON DELETE CASCADE,
    PRIMARY KEY (post_id, category_id)
);

-- SEO (reusable object) ---------------------------------------------------
CREATE TABLE seo (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    meta_title       TEXT,
    meta_description TEXT,
    og_title         TEXT,
    og_description   TEXT,
    og_image_url     TEXT,
    canonical_url    TEXT,
    robots           TEXT        NOT NULL DEFAULT 'index,follow',
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_seo_updated_at
    BEFORE UPDATE ON seo
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Attach seo_id to content tables -----------------------------------------
ALTER TABLE posts     ADD COLUMN seo_id UUID REFERENCES seo(id);
ALTER TABLE pages     ADD COLUMN seo_id UUID REFERENCES seo(id);
ALTER TABLE templates ADD COLUMN seo_id UUID REFERENCES seo(id);
