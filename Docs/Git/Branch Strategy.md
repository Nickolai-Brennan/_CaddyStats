# Caddy Stats – Git Branch Strategy

## Purpose

Provide a predictable, production-safe branching workflow
for backend, frontend, database, AI, and infra development.

This project must always be deployable from `main`.

---

# 🌳 Core Branches

## main
- Production-ready code only
- Always deployable
- Protected branch
- No direct commits allowed
- Only merge via Pull Request

---

## develop
- Integration branch
- All feature branches merge here first
- Staging preview environment should deploy from this branch

---

# 🌿 Supporting Branch Types

## feature/*
Used for new features

Examples:
- feature/graphql-auth
- feature/editor-blocks
- feature/magazine-view
- feature/stats-projections

Rules:
- Branch from develop
- Must include related doc updates
- Must pass lint + build
- Must include migration if schema changes

---

## fix/*
Bug fixes

Examples:
- fix/docker-env
- fix/graphql-timeout

Rules:
- Branch from develop
- Small, focused commits

---

## chore/*
Maintenance tasks

Examples:
- chore/deps-upgrade
- chore/docker-optimize

---

## refactor/*
Code improvements without feature changes

---

# 🧱 Database Migration Rule

If a branch modifies:

- PostgreSQL schema
- GraphQL schema
- Pydantic models
- Table structure

It MUST:

1. Include a migration file
2. Update documentation
3. Be reviewed before merge

---

# 🚀 Release Process

1. Merge features into develop
2. Test locally + staging
3. Create release branch:

   release/v0.x.x

4. Merge release into:
   - main
   - develop

5. Tag version:
   v0.x.x

---

# 🔐 Production Safety Rules

- No playground enabled in production
- No debug logging in production
- .env never committed
- Docker builds must use production target

---

# 📦 Commit Convention

Format:

type(scope): short description

Examples:
feat(graphql): add user query
fix(docker): correct postgres service name
chore(deps): upgrade fastapi

Types:
- feat
- fix
- chore
- refactor
- docs
- test
- perf

---

# 🧠 Why This Matters

Caddy Stats is a long-term analytics platform.
We build for:

- Scale
- Stability
- Authority
- Monetization

Discipline at Git level prevents chaos at scale.
