-- Ultimate Blog Add-ons (OPTIONAL): Marketplace Plus (orders/items/coupons)
-- If you're only doing simple one-product purchases, you can skip this file.

CREATE TABLE IF NOT EXISTS website_content.orders (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id     UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  status       TEXT NOT NULL DEFAULT 'paid', -- pending|paid|refunded|failed|canceled
  amount_cents INTEGER NOT NULL DEFAULT 0,
  currency     TEXT NOT NULL DEFAULT 'USD',

  provider     TEXT NOT NULL DEFAULT 'manual',
  provider_ref TEXT NULL,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT orders_status_check CHECK (status IN ('pending','paid','refunded','failed','canceled'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'orders_set_updated_at') THEN
    CREATE TRIGGER orders_set_updated_at
    BEFORE UPDATE ON website_content.orders
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.order_items (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         UUID NOT NULL REFERENCES website_content.orders(id) ON DELETE CASCADE,
  product_id       UUID NOT NULL REFERENCES website_content.products(id) ON DELETE RESTRICT,

  quantity         INTEGER NOT NULL DEFAULT 1,
  unit_price_cents INTEGER NOT NULL DEFAULT 0,

  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT order_items_quantity_check CHECK (quantity > 0)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'order_items_set_updated_at') THEN
    CREATE TRIGGER order_items_set_updated_at
    BEFORE UPDATE ON website_content.order_items
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.coupons (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code           TEXT NOT NULL,
  description    TEXT NULL,

  discount_type  TEXT NOT NULL DEFAULT 'percent', -- percent|amount
  discount_value INTEGER NOT NULL DEFAULT 0,      -- percent 0-100 or cents amount

  starts_at      TIMESTAMPTZ NULL,
  ends_at        TIMESTAMPTZ NULL,
  max_redemptions INTEGER NULL,

  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT coupons_code_unique UNIQUE (code),
  CONSTRAINT coupons_discount_type_check CHECK (discount_type IN ('percent','amount'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'coupons_set_updated_at') THEN
    CREATE TRIGGER coupons_set_updated_at
    BEFORE UPDATE ON website_content.coupons
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.coupon_redemptions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id   UUID NOT NULL REFERENCES website_content.coupons(id) ON DELETE CASCADE,
  order_id    UUID NOT NULL REFERENCES website_content.orders(id) ON DELETE CASCADE,
  buyer_id    UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  redeemed_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT coupon_redemptions_unique UNIQUE (coupon_id, order_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'coupon_redemptions_set_updated_at') THEN
    CREATE TRIGGER coupon_redemptions_set_updated_at
    BEFORE UPDATE ON website_content.coupon_redemptions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
