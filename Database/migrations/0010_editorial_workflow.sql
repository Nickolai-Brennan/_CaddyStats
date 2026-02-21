-- Ultimate Blog Add-ons: Editorial workflow (locks, autosaves, review queue, scheduling)

-- =========================
-- Editor locks (prevents conflicting edits)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.editor_locks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL, -- post|page|template|product
  entity_id   UUID NOT NULL,
  locked_by   UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,

  locked_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at  TIMESTAMPTZ NOT NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT editor_locks_entity_type_check CHECK (entity_type IN ('post','page','template','product')),
  CONSTRAINT editor_locks_unique UNIQUE (entity_type, entity_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'editor_locks_set_updated_at') THEN
    CREATE TRIGGER editor_locks_set_updated_at
    BEFORE UPDATE ON website_content.editor_locks
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Autosaves (draft recovery)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.autosaves (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type  TEXT NOT NULL, -- post|page|template
  entity_id    UUID NOT NULL,
  author_id    UUID NOT NULL REFERENCES website_content.users(id) ON DELETE RESTRICT,

  content_jsonb JSONB NOT NULL DEFAULT '{}'::jsonb,

  saved_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT autosaves_entity_type_check CHECK (entity_type IN ('post','page','template'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'autosaves_set_updated_at') THEN
    CREATE TRIGGER autosaves_set_updated_at
    BEFORE UPDATE ON website_content.autosaves
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Review queue (draft -> review -> publish routing)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.review_queue (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type   TEXT NOT NULL, -- post|page|template
  entity_id     UUID NOT NULL,
  submitted_by  UUID NOT NULL REFERENCES website_content.users(id) ON DELETE RESTRICT,
  reviewer_id   UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,

  status        TEXT NOT NULL DEFAULT 'pending', -- pending|approved|rejected
  notes         TEXT NULL,
  decided_at    TIMESTAMPTZ NULL,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT review_queue_entity_type_check CHECK (entity_type IN ('post','page','template')),
  CONSTRAINT review_queue_status_check CHECK (status IN ('pending','approved','rejected'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'review_queue_set_updated_at') THEN
    CREATE TRIGGER review_queue_set_updated_at
    BEFORE UPDATE ON website_content.review_queue
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Content schedule (scheduled publish/archive/unpublish)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.content_schedule (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type  TEXT NOT NULL, -- post|page|template
  entity_id    UUID NOT NULL,

  action       TEXT NOT NULL, -- publish|archive|unpublish
  run_at       TIMESTAMPTZ NOT NULL,

  status       TEXT NOT NULL DEFAULT 'scheduled', -- scheduled|running|done|failed|canceled
  ran_at       TIMESTAMPTZ NULL,
  error_text   TEXT NULL,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT content_schedule_entity_type_check CHECK (entity_type IN ('post','page','template')),
  CONSTRAINT content_schedule_action_check CHECK (action IN ('publish','archive','unpublish')),
  CONSTRAINT content_schedule_status_check CHECK (status IN ('scheduled','running','done','failed','canceled'))
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'content_schedule_set_updated_at') THEN
    CREATE TRIGGER content_schedule_set_updated_at
    BEFORE UPDATE ON website_content.content_schedule
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
