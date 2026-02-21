-- Ultimate Blog Add-ons: Admin safety (audit logs, rate limits, IP blocks), sessions + password resets (auth hardening)

-- =========================
-- Sessions (refresh token tracking)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.sessions (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  refresh_token_hash TEXT NOT NULL,

  user_agent         TEXT NULL,
  ip_address         TEXT NULL,

  expires_at         TIMESTAMPTZ NOT NULL,
  revoked_at         TIMESTAMPTZ NULL,

  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'sessions_set_updated_at') THEN
    CREATE TRIGGER sessions_set_updated_at
    BEFORE UPDATE ON website_content.sessions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Password resets
-- =========================
CREATE TABLE IF NOT EXISTS website_content.password_resets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  token_hash  TEXT NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  used_at     TIMESTAMPTZ NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'password_resets_set_updated_at') THEN
    CREATE TRIGGER password_resets_set_updated_at
    BEFORE UPDATE ON website_content.password_resets
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Audit logs
-- =========================
CREATE TABLE IF NOT EXISTS website_content.audit_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id    UUID NULL REFERENCES website_content.users(id) ON DELETE SET NULL,
  action      TEXT NOT NULL,

  entity_type TEXT NULL,
  entity_id   UUID NULL,

  meta_jsonb  JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'audit_logs_set_updated_at') THEN
    CREATE TRIGGER audit_logs_set_updated_at
    BEFORE UPDATE ON website_content.audit_logs
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- Rate limits (simple counter per window)
-- =========================
CREATE TABLE IF NOT EXISTS website_content.rate_limits (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key           TEXT NOT NULL, -- user_id or ip hash key
  window_start  TIMESTAMPTZ NOT NULL,
  window_seconds INTEGER NOT NULL DEFAULT 60,
  count         INTEGER NOT NULL DEFAULT 0,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT rate_limits_unique UNIQUE (key, window_start, window_seconds)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'rate_limits_set_updated_at') THEN
    CREATE TRIGGER rate_limits_set_updated_at
    BEFORE UPDATE ON website_content.rate_limits
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- =========================
-- IP blocks
-- =========================
CREATE TABLE IF NOT EXISTS website_content.ip_blocks (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ip_hash    TEXT NOT NULL,
  reason     TEXT NULL,
  expires_at TIMESTAMPTZ NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT ip_blocks_ip_hash_unique UNIQUE (ip_hash)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'ip_blocks_set_updated_at') THEN
    CREATE TRIGGER ip_blocks_set_updated_at
    BEFORE UPDATE ON website_content.ip_blocks
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
