-- 0004_cms_content.down.sql
-- Rollback CMS content tables

SET search_path TO website_content;

DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS revisions;
DROP TABLE IF EXISTS templates;
DROP TABLE IF EXISTS pages;
DROP TABLE IF EXISTS posts;
