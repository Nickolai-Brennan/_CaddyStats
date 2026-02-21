-- 0005_taxonomy_seo.down.sql
-- Rollback taxonomy + SEO

SET search_path TO website_content;

ALTER TABLE templates DROP COLUMN IF EXISTS seo_id;
ALTER TABLE pages     DROP COLUMN IF EXISTS seo_id;
ALTER TABLE posts     DROP COLUMN IF EXISTS seo_id;

DROP TABLE IF EXISTS seo;
DROP TABLE IF EXISTS post_categories;
DROP TABLE IF EXISTS post_tags;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS tags;
