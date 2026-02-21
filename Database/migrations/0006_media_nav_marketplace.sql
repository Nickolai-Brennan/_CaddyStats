-- 0006_media_nav_marketplace.sql
-- Media assets, navigation, marketplace (products/licenses/purchases), analytics events

SET search_path TO website_content;

-- Media Assets ------------------------------------------------------------
CREATE TABLE media_assets (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    uploader_id      UUID        REFERENCES users(id),
    storage_provider TEXT        NOT NULL DEFAULT 'local',
    bucket           TEXT,
    key              TEXT        NOT NULL,
    url              TEXT        NOT NULL,
    filename         TEXT        NOT NULL,
    mime_type        TEXT,
    file_size        BIGINT,
    width            INT,
    height           INT,
    alt_text         TEXT,
    deleted_at       TIMESTAMPTZ NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_media_assets_updated_at
    BEFORE UPDATE ON media_assets
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Asset Links (where-used tracking) ---------------------------------------
CREATE TABLE asset_links (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id    UUID        NOT NULL REFERENCES media_assets(id) ON DELETE CASCADE,
    entity_type TEXT        NOT NULL,
    entity_id   UUID        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Navigation Menus --------------------------------------------------------
CREATE TABLE nav_menus (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL,
    slug        TEXT        NOT NULL UNIQUE,
    description TEXT,
    deleted_at  TIMESTAMPTZ NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_nav_menus_updated_at
    BEFORE UPDATE ON nav_menus
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Navigation Items (tree via parent_id + sort_order) ----------------------
CREATE TABLE nav_items (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_id    UUID        NOT NULL REFERENCES nav_menus(id) ON DELETE CASCADE,
    parent_id  UUID        REFERENCES nav_items(id),
    label      TEXT        NOT NULL,
    url        TEXT,
    target     TEXT        NOT NULL DEFAULT '_self',
    sort_order INT         NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_nav_items_updated_at
    BEFORE UPDATE ON nav_items
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Products (Docs/Templates Store) -----------------------------------------
CREATE TABLE products (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT        NOT NULL,
    slug            TEXT        NOT NULL UNIQUE,
    description     TEXT,
    price_cents     INT         NOT NULL DEFAULT 0,
    currency        TEXT        NOT NULL DEFAULT 'USD',
    status          TEXT        NOT NULL DEFAULT 'draft'
                                CHECK (status IN ('draft', 'active', 'archived')),
    provider        TEXT        NOT NULL DEFAULT 'manual'
                                CHECK (provider IN ('stripe', 'paddle', 'manual')),
    provider_id     TEXT,
    seo_id          UUID        REFERENCES seo(id),
    deleted_at      TIMESTAMPTZ NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    search_vector   TSVECTOR
);

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Licenses ----------------------------------------------------------------
CREATE TABLE licenses (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID        NOT NULL REFERENCES products(id),
    key        TEXT        NOT NULL UNIQUE,
    user_id    UUID        REFERENCES users(id),
    status     TEXT        NOT NULL DEFAULT 'active'
                           CHECK (status IN ('active', 'revoked', 'expired')),
    expires_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_licenses_updated_at
    BEFORE UPDATE ON licenses
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Purchases ---------------------------------------------------------------
CREATE TABLE purchases (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        REFERENCES users(id),
    product_id      UUID        NOT NULL REFERENCES products(id),
    license_id      UUID        REFERENCES licenses(id),
    amount_cents    INT         NOT NULL,
    currency        TEXT        NOT NULL DEFAULT 'USD',
    provider        TEXT        NOT NULL DEFAULT 'manual',
    provider_txn_id TEXT,
    status          TEXT        NOT NULL DEFAULT 'completed'
                                CHECK (status IN ('pending', 'completed', 'refunded', 'failed')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_purchases_updated_at
    BEFORE UPDATE ON purchases
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Analytics Events (pageview, click, purchase, search) --------------------
CREATE TABLE events (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT        NOT NULL,
    user_id    UUID        REFERENCES users(id),
    session_id TEXT,
    path       TEXT,
    referrer   TEXT,
    properties JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
