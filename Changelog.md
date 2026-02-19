# Changelog

All notable changes to Caddy Stats will be documented here.

Format based on Keep a Changelog principles.
Project follows semantic versioning.

---

## [0.0] – Phase 0 Core Documentation – 2026-02-19


## [1.0] – Phase 1 Foundation – 2026-02-19

### Added

#### 1.0.1 – Base Folder Architecture
- Created root project structure:
  - backend/
  - frontend/
  - database/
  - docs/
- Structured backend modular layout (api, graphql, db, middleware, core, etc.)
- Structured frontend React/Vite layout
- Prepared database init directory

#### 1.0.2 – Branch Strategy
- Defined protected `main` branch
- Added `develop` integration branch
- Documented feature/fix/chore/refactor branching rules
- Defined release process and tagging standards
- Added database migration enforcement rule

#### 1.0.3 – .gitignore Setup
- Added Python ignores
- Added Node/Vite ignores
- Added Docker log ignores
- Secured `.env` from commits

#### 1.0.4 – README Initialization
- Added Docker boot instructions
- Documented service URLs
- Clarified dual-schema Postgres architecture (content + stats)

#### 1.0.5 – Commit Convention Rules
- Standardized commit format: type(scope): message
- Defined allowed commit types
- Added scope categories
- Enforced DB change documentation requirements
- Established no-direct-commit-to-main rule

---

## Upcoming

- Docker Compose environment
- Backend FastAPI scaffold
- GraphQL schema base
- Frontend boot screen
