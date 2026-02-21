-- =========================
-- Performance: indexes, FTS, JSONB GIN
-- =========================

-- FK indexes --------------------------------------------------------------

-- posts
CREATE INDEX IF NOT EXISTS idx_posts_author_id  ON website_content.posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_seo_id     ON website_content.posts(seo_id);

-- pages
CREATE INDEX IF NOT EXISTS idx_pages_author_id  ON website_content.pages(author_id);
CREATE INDEX IF NOT EXISTS idx_pages_seo_id     ON website_content.pages(seo_id);

-- templates
CREATE INDEX IF NOT EXISTS idx_templates_author_id ON website_content.templates(author_id);
CREATE INDEX IF NOT EXISTS idx_templates_seo_id    ON website_content.templates(seo_id);

-- blocks
CREATE INDEX IF NOT EXISTS idx_blocks_owner ON website_content.blocks(owner_type, owner_id);

-- comments
CREATE INDEX IF NOT EXISTS idx_comments_post_id   ON website_content.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author_id ON website_content.comments(author_id);

-- revisions
CREATE INDEX IF NOT EXISTS idx_revisions_entity   ON website_content.revisions(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_revisions_author   ON website_content.revisions(author_id);

-- user_roles / role_permissions
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id           ON website_content.user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON website_content.role_permissions(permission_id);

-- categories
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON website_content.categories(parent_id);

-- media_assets
CREATE INDEX IF NOT EXISTS idx_media_assets_uploader_id ON website_content.media_assets(uploader_id);

-- asset_links
CREATE INDEX IF NOT EXISTS idx_asset_links_asset_id ON website_content.asset_links(asset_id);
CREATE INDEX IF NOT EXISTS idx_asset_links_owner    ON website_content.asset_links(owner_type, owner_id);

-- nav_items
CREATE INDEX IF NOT EXISTS idx_nav_items_menu_id   ON website_content.nav_items(menu_id);
CREATE INDEX IF NOT EXISTS idx_nav_items_parent_id ON website_content.nav_items(parent_id);
CREATE INDEX IF NOT EXISTS idx_nav_items_page_id   ON website_content.nav_items(page_id);

-- products
CREATE INDEX IF NOT EXISTS idx_products_seo_id ON website_content.products(seo_id);

-- licenses
CREATE INDEX IF NOT EXISTS idx_licenses_product_id ON website_content.licenses(product_id);
CREATE INDEX IF NOT EXISTS idx_licenses_user_id    ON website_content.licenses(user_id);

-- purchases
CREATE INDEX IF NOT EXISTS idx_purchases_user_id    ON website_content.purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_product_id ON website_content.purchases(product_id);
CREATE INDEX IF NOT EXISTS idx_purchases_license_id ON website_content.purchases(license_id);

-- events
CREATE INDEX IF NOT EXISTS idx_events_user_id    ON website_content.events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_event_type ON website_content.events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON website_content.events(created_at DESC);

-- Slug indexes ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_posts_slug      ON website_content.posts(slug);
CREATE INDEX IF NOT EXISTS idx_pages_slug      ON website_content.pages(slug);
CREATE INDEX IF NOT EXISTS idx_templates_slug  ON website_content.templates(slug);
CREATE INDEX IF NOT EXISTS idx_tags_slug       ON website_content.tags(slug);
CREATE INDEX IF NOT EXISTS idx_categories_slug ON website_content.categories(slug);
CREATE INDEX IF NOT EXISTS idx_nav_menus_slug  ON website_content.nav_menus(slug);
CREATE INDEX IF NOT EXISTS idx_products_slug   ON website_content.products(slug);

-- Partial indexes for published/active content ----------------------------
CREATE INDEX IF NOT EXISTS idx_posts_published
    ON website_content.posts(published_at DESC)
    WHERE status = 'published' AND is_deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_pages_published
    ON website_content.pages(published_at DESC)
    WHERE status = 'published' AND is_deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_products_active
    ON website_content.products(created_at DESC)
    WHERE status = 'active' AND is_deleted = FALSE;

-- Full-text search GIN indexes --------------------------------------------
CREATE INDEX IF NOT EXISTS idx_posts_search_vector
    ON website_content.posts USING GIN(search_vector);

CREATE INDEX IF NOT EXISTS idx_products_search_vector
    ON website_content.products USING GIN(search_vector);

-- JSONB GIN indexes (only where app queries inside the JSONB) -------------
CREATE INDEX IF NOT EXISTS idx_posts_content_jsonb
    ON website_content.posts USING GIN(content_jsonb);

CREATE INDEX IF NOT EXISTS idx_templates_content_jsonb
    ON website_content.templates USING GIN(content_jsonb);

CREATE INDEX IF NOT EXISTS idx_events_properties
    ON website_content.events USING GIN(properties);
