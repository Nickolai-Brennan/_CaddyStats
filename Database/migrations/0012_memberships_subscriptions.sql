-- Ultimate Blog Add-ons: Memberships / subscriptions (Ghost-like), plus entitlements

CREATE TABLE IF NOT EXISTS website_content.plans (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug         TEXT NOT NULL,
  name         TEXT NOT NULL,
  description  TEXT NULL,

  price_cents  INTEGER NOT NULL DEFAULT 0,
  currency     TEXT NOT NULL DEFAULT 'USD',
  interval     TEXT NOT NULL DEFAULT 'month', -- month|year|lifetime

  status       TEXT NOT NULL DEFAULT 'active', -- active|inactive|archived

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT plans_slug_unique UNIQUE (slug),
  CONSTRAINT plans_interval_check CHECK (interval IN ('month','year','lifetime')),
  CONSTRAINT plans_status_check CHECK (status IN ('active','inactive','archived'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'plans_set_updated_at') THEN
    CREATE TRIGGER plans_set_updated_at
    BEFORE UPDATE ON website_content.plans
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.subscriptions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  plan_id             UUID NOT NULL REFERENCES website_content.plans(id) ON DELETE RESTRICT,

  provider            TEXT NOT NULL DEFAULT 'manual', -- stripe|paddle|manual
  provider_ref        TEXT NULL,

  status              TEXT NOT NULL DEFAULT 'active', -- active|trialing|past_due|canceled
  started_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  current_period_end  TIMESTAMPTZ NULL,
  canceled_at         TIMESTAMPTZ NULL,

  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT subscriptions_status_check CHECK (status IN ('active','trialing','past_due','canceled'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'subscriptions_set_updated_at') THEN
    CREATE TRIGGER subscriptions_set_updated_at
    BEFORE UPDATE ON website_content.subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.entitlements (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id            UUID NOT NULL REFERENCES website_content.plans(id) ON DELETE CASCADE,

  entitlement_type   TEXT NOT NULL, -- premium_posts|templates|downloads|api_access|other
  meta_jsonb         JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT entitlements_type_check CHECK (entitlement_type IN ('premium_posts','templates','downloads','api_access','other'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'entitlements_set_updated_at') THEN
    CREATE TRIGGER entitlements_set_updated_at
    BEFORE UPDATE ON website_content.entitlements
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
