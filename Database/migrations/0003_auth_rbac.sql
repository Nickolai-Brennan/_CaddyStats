-- =========================
-- Auth + RBAC
-- =========================

CREATE TABLE IF NOT EXISTS website_content.users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         CITEXT NOT NULL,
  username      CITEXT NULL,
  password_hash TEXT NOT NULL,

  display_name  TEXT NULL,
  avatar_url    TEXT NULL,

  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  is_verified   BOOLEAN NOT NULL DEFAULT FALSE,

  deleted_at    TIMESTAMPTZ NULL,
  is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT users_email_unique UNIQUE (email),
  CONSTRAINT users_username_unique UNIQUE (username),
  CONSTRAINT users_soft_delete_consistency CHECK (
    (is_deleted = FALSE AND deleted_at IS NULL) OR
    (is_deleted = TRUE  AND deleted_at IS NOT NULL)
  )
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'users_set_updated_at') THEN
    CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON website_content.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.roles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT NOT NULL,   -- admin, editor, author, viewer
  name        TEXT NOT NULL,
  description TEXT NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT roles_key_unique UNIQUE (key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'roles_set_updated_at') THEN
    CREATE TRIGGER roles_set_updated_at
    BEFORE UPDATE ON website_content.roles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.permissions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT NOT NULL,   -- post:create, post:publish, etc.
  name        TEXT NOT NULL,
  description TEXT NULL,

  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT permissions_key_unique UNIQUE (key)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'permissions_set_updated_at') THEN
    CREATE TRIGGER permissions_set_updated_at
    BEFORE UPDATE ON website_content.permissions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.user_roles (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES website_content.users(id) ON DELETE CASCADE,
  role_id    UUID NOT NULL REFERENCES website_content.roles(id) ON DELETE CASCADE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT user_roles_unique UNIQUE (user_id, role_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'user_roles_set_updated_at') THEN
    CREATE TRIGGER user_roles_set_updated_at
    BEFORE UPDATE ON website_content.user_roles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS website_content.role_permissions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id       UUID NOT NULL REFERENCES website_content.roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES website_content.permissions(id) ON DELETE CASCADE,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT role_permissions_unique UNIQUE (role_id, permission_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'role_permissions_set_updated_at') THEN
    CREATE TRIGGER role_permissions_set_updated_at
    BEFORE UPDATE ON website_content.role_permissions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
