-- Ultimate Blog Add-ons: Newsletter + subscriber system (WP plugins / Ghost newsletters)

CREATE TABLE IF NOT EXISTS website_content.subscribers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           CITEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending', -- pending|confirmed|unsubscribed
  source          TEXT NULL,

  confirmed_at    TIMESTAMPTZ NULL,
  unsubscribed_at TIMESTAMPTZ NULL,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT subscribers_email_unique UNIQUE (email),
  CONSTRAINT subscribers_status_check CHECK (status IN ('pending','confirmed','unsubscribed'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'subscribers_set_updated_at') THEN
    CREATE TRIGGER subscribers_set_updated_at
    BEFORE UPDATE ON website_content.subscribers
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.subscriber_lists (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT NOT NULL,
  name        TEXT NOT NULL,
  description TEXT NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT subscriber_lists_slug_unique UNIQUE (slug)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'subscriber_lists_set_updated_at') THEN
    CREATE TRIGGER subscriber_lists_set_updated_at
    BEFORE UPDATE ON website_content.subscriber_lists
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.subscriber_list_memberships (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscriber_id UUID NOT NULL REFERENCES website_content.subscribers(id) ON DELETE CASCADE,
  list_id       UUID NOT NULL REFERENCES website_content.subscriber_lists(id) ON DELETE CASCADE,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT subscriber_list_memberships_unique UNIQUE (subscriber_id, list_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'subscriber_list_memberships_set_updated_at') THEN
    CREATE TRIGGER subscriber_list_memberships_set_updated_at
    BEFORE UPDATE ON website_content.subscriber_list_memberships
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Campaigns stored as JSONB to support editor blocks + HTML variants.
CREATE TABLE IF NOT EXISTS website_content.email_campaigns (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id      UUID NOT NULL REFERENCES website_content.subscriber_lists(id) ON DELETE RESTRICT,

  subject      TEXT NOT NULL,
  body_jsonb   JSONB NOT NULL DEFAULT '{}'::jsonb,
  status       TEXT NOT NULL DEFAULT 'draft', -- draft|scheduled|sending|sent|canceled|failed

  scheduled_at TIMESTAMPTZ NULL,
  sent_at      TIMESTAMPTZ NULL,

  provider     TEXT NOT NULL DEFAULT 'manual', -- ses|sendgrid|mailchimp|manual
  provider_ref TEXT NULL,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT email_campaigns_status_check CHECK (status IN ('draft','scheduled','sending','sent','canceled','failed'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'email_campaigns_set_updated_at') THEN
    CREATE TRIGGER email_campaigns_set_updated_at
    BEFORE UPDATE ON website_content.email_campaigns
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Optional delivery tracking (lightweight)
CREATE TABLE IF NOT EXISTS website_content.email_deliveries (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id   UUID NOT NULL REFERENCES website_content.email_campaigns(id) ON DELETE CASCADE,
  subscriber_id UUID NOT NULL REFERENCES website_content.subscribers(id) ON DELETE CASCADE,

  status        TEXT NOT NULL DEFAULT 'queued', -- queued|sent|bounced|failed
  provider_ref  TEXT NULL,

  opened_at     TIMESTAMPTZ NULL,
  clicked_at    TIMESTAMPTZ NULL,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT email_deliveries_status_check CHECK (status IN ('queued','sent','bounced','failed')),
  CONSTRAINT email_deliveries_unique UNIQUE (campaign_id, subscriber_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'email_deliveries_set_updated_at') THEN
    CREATE TRIGGER email_deliveries_set_updated_at
    BEFORE UPDATE ON website_content.email_deliveries
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
