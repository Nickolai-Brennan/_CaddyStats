-- =========================
-- Indexes (explicit pack)
-- =========================

-- Users
CREATE INDEX IF NOT EXISTS idx_users_active ON website_content.users(is_active) WHERE is_deleted = FALSE;

-- RBAC
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON website_content.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON website_content.user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON website_content.role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON website_content.role_permissions(permission_id);

-- Posts
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON website_content.posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON website_content.posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_published_at ON website_content.posts(published_at) WHERE status = 'published' AND is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_posts_updated_at ON website_content.posts(updated_at);

-- FTS (Posts)
CREATE INDEX IF NOT EXISTS idx_posts_search_vector ON website_content.posts USING GIN (search_vector);

-- Pages
CREATE INDEX IF NOT EXISTS idx_pages_author_id ON website_content.pages(author_id);
CREATE INDEX IF NOT EXISTS idx_pages_status ON website_content.pages(status);
CREATE INDEX IF NOT EXISTS idx_pages_published_at ON website_content.pages(published_at) WHERE status = 'published' AND is_deleted = FALSE;

-- Templates
CREATE INDEX IF NOT EXISTS idx_templates_author_id ON website_content.templates(author_id);
CREATE INDEX IF NOT EXISTS idx_templates_status ON website_content.templates(status);

-- Join tables
CREATE INDEX IF NOT EXISTS idx_post_tags_post_id ON website_content.post_tags(post_id);
CREATE INDEX IF NOT EXISTS idx_post_tags_tag_id ON website_content.post_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_post_categories_post_id ON website_content.post_categories(post_id);
CREATE INDEX IF NOT EXISTS idx_post_categories_category_id ON website_content.post_categories(category_id);

-- Comments
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON website_content.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_status ON website_content.comments(status) WHERE is_deleted = FALSE;

-- Media
CREATE INDEX IF NOT EXISTS idx_media_assets_uploader_id ON website_content.media_assets(uploader_id);
CREATE INDEX IF NOT EXISTS idx_asset_links_asset_id ON website_content.asset_links(asset_id);

-- Nav
CREATE INDEX IF NOT EXISTS idx_nav_items_menu_id ON website_content.nav_items(menu_id);
CREATE INDEX IF NOT EXISTS idx_nav_items_parent_id ON website_content.nav_items(parent_id);

-- Marketplace
CREATE INDEX IF NOT EXISTS idx_products_status ON website_content.products(status);
CREATE INDEX IF NOT EXISTS idx_products_type ON website_content.products(product_type);
CREATE INDEX IF NOT EXISTS idx_products_search_vector ON website_content.products USING GIN (search_vector);

CREATE INDEX IF NOT EXISTS idx_licenses_product_id ON website_content.licenses(product_id);
CREATE INDEX IF NOT EXISTS idx_purchases_buyer_id ON website_content.purchases(buyer_id);
CREATE INDEX IF NOT EXISTS idx_purchases_product_id ON website_content.purchases(product_id);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON website_content.purchases(status);

-- Events
CREATE INDEX IF NOT EXISTS idx_events_type_created_at ON website_content.events(event_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_user_id ON website_content.events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_properties_gin ON website_content.events USING GIN (properties);
