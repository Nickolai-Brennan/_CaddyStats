-- 0003_auth_rbac.down.sql
-- Rollback Auth + RBAC tables

SET search_path TO website_content;

DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;
