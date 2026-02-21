-- 0006_media_nav_marketplace.down.sql
-- Rollback media, navigation, marketplace, and events tables

SET search_path TO website_content;

DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS licenses;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS nav_items;
DROP TABLE IF EXISTS nav_menus;
DROP TABLE IF EXISTS asset_links;
DROP TABLE IF EXISTS media_assets;
