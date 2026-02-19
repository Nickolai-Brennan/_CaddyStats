# Caddy Stats – Commit Convention Rules

## Purpose

Create consistent, readable commit history
that scales with a multi-layer architecture:

- Backend (FastAPI + GraphQL)
- Frontend (React + TanStack)
- Database (Postgres schemas)
- DevOps (Docker / CI)
- AI + Editor systems

---

# 🔹 Commit Format

type(scope): short description

Example:
feat(graphql): add ping query
fix(docker): correct postgres service hostname
docs(branching): add release workflow

---

# 🔹 Allowed Types

## feat
New feature

## fix
Bug fix

## refactor
Code change without behavior change

## chore
Maintenance (deps, formatting, tooling)

## docs
Documentation only

## test
Add or modify tests

## perf
Performance improvement

---

# 🔹 Scope Examples

backend
frontend
graphql
database
docker
editor
seo
ai
auth
docs
infra

---

# 🔹 Rules

1. Small, focused commits
2. No mixed feature + refactor commits
3. Database changes require:
   - migration file
   - documentation update
4. No secrets in commits
5. No direct commits to `main`

---

# 🔹 Example Good Commits

feat(editor): add block schema model
fix(auth): correct JWT expiration logic
chore(deps): upgrade fastapi to 0.115
docs(api): document GraphQL schema structure

---

# 🔹 Why This Matters

Caddy Stats is long-term infrastructure.

Clean commit history enables:

- Safer releases
- Faster debugging
- Clean rollbacks
- Team scalability
