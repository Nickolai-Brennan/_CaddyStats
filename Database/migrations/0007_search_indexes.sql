-- 0007_search_indexes.sql
-- Performance layer: FK indexes, slug indexes, partial indexes, FTS, JSONB GIN

SET search_path TO website_content;

-- FK indexes --------------------------------------------------------------

-- posts
CREATE INDEX idx_posts_author_id   ON posts(author_id);
CREATE INDEX idx_posts_seo_id      ON posts(seo_id);

-- pages
CREATE INDEX idx_pages_author_id   ON pages(author_id);
CREATE INDEX idx_pages_seo_id      ON pages(seo_id);

-- templates
CREATE INDEX idx_templates_author_id ON templates(author_id);
CREATE INDEX idx_templates_seo_id    ON templates(seo_id);

-- comments
CREATE INDEX idx_comments_post_id    ON comments(post_id);
CREATE INDEX idx_comments_author_id  ON comments(author_id);
CREATE INDEX idx_comments_parent_id  ON comments(parent_id);

-- revisions
CREATE INDEX idx_revisions_entity ON revisions(entity_type, entity_id);
CREATE INDEX idx_revisions_author ON revisions(author_id);

-- user_roles
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- role_permissions
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);

-- categories
CREATE INDEX idx_categories_parent_id ON categories(parent_id);

-- media_assets
CREATE INDEX idx_media_assets_uploader_id ON media_assets(uploader_id);

-- asset_links
CREATE INDEX idx_asset_links_asset_id    ON asset_links(asset_id);
CREATE INDEX idx_asset_links_entity      ON asset_links(entity_type, entity_id);

-- nav_items
CREATE INDEX idx_nav_items_menu_id   ON nav_items(menu_id);
CREATE INDEX idx_nav_items_parent_id ON nav_items(parent_id);

-- products
CREATE INDEX idx_products_seo_id ON products(seo_id);

-- licenses
CREATE INDEX idx_licenses_product_id ON licenses(product_id);
CREATE INDEX idx_licenses_user_id    ON licenses(user_id);

-- purchases
CREATE INDEX idx_purchases_user_id    ON purchases(user_id);
CREATE INDEX idx_purchases_product_id ON purchases(product_id);
CREATE INDEX idx_purchases_license_id ON purchases(license_id);

-- events
CREATE INDEX idx_events_user_id    ON events(user_id);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_created_at ON events(created_at);

-- Slug indexes (unique, already enforced at table level) ------------------
-- Explicit non-partial index for fast lookup
CREATE INDEX idx_posts_slug      ON posts(slug);
CREATE INDEX idx_pages_slug      ON pages(slug);
CREATE INDEX idx_templates_slug  ON templates(slug);
CREATE INDEX idx_tags_slug       ON tags(slug);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_nav_menus_slug  ON nav_menus(slug);
CREATE INDEX idx_products_slug   ON products(slug);

-- Partial indexes for published content ----------------------------------
CREATE INDEX idx_posts_published
    ON posts(published_at DESC)
    WHERE status = 'published' AND deleted_at IS NULL;

CREATE INDEX idx_pages_published
    ON pages(published_at DESC)
    WHERE status = 'published' AND deleted_at IS NULL;

CREATE INDEX idx_products_active
    ON products(created_at DESC)
    WHERE status = 'active' AND deleted_at IS NULL;

-- Full-text search --------------------------------------------------------
-- posts: populate search_vector from title + excerpt + content_jsonb
CREATE INDEX idx_posts_search_vector ON posts USING GIN(search_vector);

-- Trigger to keep search_vector current
CREATE OR REPLACE FUNCTION website_content.posts_update_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.excerpt, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(NEW.content_jsonb::text, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_posts_search_vector
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION posts_update_search_vector();

-- products: populate search_vector from name + description
CREATE INDEX idx_products_search_vector ON products USING GIN(search_vector);

CREATE OR REPLACE FUNCTION website_content.products_update_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products_search_vector
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION products_update_search_vector();

-- JSONB GIN indexes (only for columns that are queried inside the JSONB) --
-- posts.content_jsonb and templates.content_jsonb are editor-block stores;
-- add GIN only if filtering/searching inside the JSONB at the application level.
CREATE INDEX idx_posts_content_jsonb     ON posts(content_jsonb)     USING GIN;
CREATE INDEX idx_templates_content_jsonb ON templates(content_jsonb) USING GIN;

-- events.properties GIN for flexible event-property queries
CREATE INDEX idx_events_properties ON events(properties) USING GIN;
