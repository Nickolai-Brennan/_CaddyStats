-- Ultimate Blog Add-ons: Engagement + retention (saved posts, reactions, notifications, search logs)

CREATE TABLE IF NOT EXISTS website_content.saved_posts (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES website_content.posts(id) ON DELETE CASCADE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT saved_posts_unique UNIQUE (user_id, post_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'saved_posts_set_updated_at') THEN
    CREATE TRIGGER saved_posts_set_updated_at
    BEFORE UPDATE ON website_content.saved_posts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.reactions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type   TEXT NOT NULL, -- post|comment|product
  entity_id     UUID NOT NULL,
  user_id       UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  reaction_type TEXT NOT NULL, -- like|upvote|bookmark

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT reactions_entity_type_check CHECK (entity_type IN ('post','comment','product')),
  CONSTRAINT reactions_type_check CHECK (reaction_type IN ('like','upvote','bookmark')),
  CONSTRAINT reactions_unique UNIQUE (entity_type, entity_id, user_id, reaction_type)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'reactions_set_updated_at') THEN
    CREATE TRIGGER reactions_set_updated_at
    BEFORE UPDATE ON website_content.reactions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.notifications (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  type         TEXT NOT NULL, -- system|comment_reply|purchase|newsletter|other
  payload_jsonb JSONB NOT NULL DEFAULT '{}'::jsonb,

  read_at      TIMESTAMPTZ NULL,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT notifications_type_check CHECK (type IN ('system','comment_reply','purchase','newsletter','other'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'notifications_set_updated_at') THEN
    CREATE TRIGGER notifications_set_updated_at
    BEFORE UPDATE ON website_content.notifications
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Search logs (track what people search for)
CREATE TABLE IF NOT EXISTS website_content.search_logs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  query_text   TEXT NOT NULL,
  filters_jsonb JSONB NOT NULL DEFAULT '{}'::jsonb,
  results_count INTEGER NULL,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'search_logs_set_updated_at') THEN
    CREATE TRIGGER search_logs_set_updated_at
    BEFORE UPDATE ON website_content.search_logs
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Optional daily rollup
CREATE TABLE IF NOT EXISTS website_content.page_views_daily (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  day         DATE NOT NULL,
  path        TEXT NOT NULL,
  views_count BIGINT NOT NULL DEFAULT 0,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT page_views_daily_unique UNIQUE (day, path)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'page_views_daily_set_updated_at') THEN
    CREATE TRIGGER page_views_daily_set_updated_at
    BEFORE UPDATE ON website_content.page_views_daily
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
