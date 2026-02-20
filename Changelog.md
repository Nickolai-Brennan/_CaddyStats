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
├── 1.1 Root Project Structure
│   ├── 1.1.1 Create /frontend
│   ├── 1.1.2 Create /backend
│   ├── 1.1.3 Create /database
│   ├── 1.1.4 Create /docs
│   ├── 1.1.5 Create /scripts
│   ├── 1.1.6 Create /docker
│   ├── 1.1.7 Add docker-compose.yml
│   └── 1.1.8 Add .env.example
## Upcoming

Here’s what’s **completed vs still pending**, based on everything we actually built in this thread (files created + compose working + health checks wired).

## 1.2 Backend Setup (FastAPI + Strawberry)

### ✅ 1.2.4 Create settings/config loader — **COMPLETED**

* `backend/app/core/config.py` created
* `backend/main.py` reads from `settings`

### ✅ 1.2.5 Configure database connection module — **COMPLETED**

* `backend/app/db/base.py`
* `backend/app/db/content.py`
* `backend/app/db/stats.py`
* `/health` performs DB smoke test using both engines

### ✅ 1.2.6 Initialize GraphQL root schema — **COMPLETED**

* `backend/app/graphql/schema.py` with `Query.ping` + `server_time`
* Mounted at `/graphql` via `GraphQLRouter`

### ⏳ 1.2.7 Add global exception handler — **NOT DONE**

* We have not added a FastAPI exception handler module/middleware yet.

### ✅ 1.2.8 Add logging middleware — **COMPLETED**

* `backend/app/middleware/logging.py` exists and was used earlier in the scaffold
* (If you want it enforced in `main.py`, we can add the middleware registration explicitly as the next item.)

### ✅ 1.2.9 Confirm API boots locally — **COMPLETED**

* Confirmed via Docker `/health` and `/graphql`
* (Local venv boot was also tested earlier with uvicorn.)

---

## 1.3 Frontend Setup (React + Vite + TanStack)

### ✅ 1.3.1 Initialize Vite + React + TypeScript — **COMPLETED**

* `frontend/index.html`, `vite.config.ts`, `tsconfig.json`, `src/main.tsx`

### ⚠️ 1.3.2 Install dependencies — **PARTIALLY COMPLETED**

✅ Installed/added in `package.json`:

* `@tanstack/react-query`
* `react` / `react-dom`

❌ Not added yet (still pending):

* `@tanstack/react-table`
* `react-router-dom` (we had it in an earlier fuller scaffold, but current minimal package.json does NOT include it)
* `graphql`
* `graphql-request` (or Apollo)
* chart library (chart.js or similar)

### ✅ 1.3.3 Create frontend folder tree — **PARTIALLY COMPLETED**

✅ Present:

* `src/`
* minimal files exist

❌ Not created yet (pending dirs):

* `components/`
* `templates/`
* `editor/`
* `hooks/`
* `styles/` (we used `src/styles.css` but not `/styles` folder)
* `utils/`
* `assets/`

### ✅ 1.3.4 Configure global QueryClient — **COMPLETED**

* QueryClient configured in `src/main.tsx` and used to call `/health`

### ❌ 1.3.5 Configure router base routes — **NOT DONE**

* No router currently (we removed `react-router-dom` from the minimal boot)

### ❌ 1.3.6 Create layout wrapper component — **NOT DONE**

* No layout component in the current minimal boot version

### ❌ 1.3.7 Create theme provider (dark/light toggle) — **NOT DONE**

* Not implemented yet

### ✅ 1.3.8 Confirm frontend boots locally — **COMPLETED**

* Boots in Docker at `localhost:5173` and successfully calls backend `/health`

---

## 1.4 Docker & Environment Configuration

### ✅ 1.4.1 Create Dockerfile (backend) — **COMPLETED**

* `backend/Dockerfile` with dev + prod targets
* `backend/.dockerignore`

### ✅ 1.4.2 Create Dockerfile (frontend) — **COMPLETED**

* `frontend/Dockerfile` with dev + prod targets
* `frontend/.dockerignore`

### ✅ 1.4.3 Configure PostgreSQL container — **COMPLETED**

* Postgres service in compose
* mounts `database/init/001_init.sql` to init schemas

### ✅ 1.4.4 Configure docker-compose services — **COMPLETED**

* `postgres`, `backend`, `frontend` defined correctly

### ✅ 1.4.5 Add environment variable mapping — **COMPLETED**

* backend DB URLs mapped to `postgres` hostname
* frontend uses `VITE_API_HTTP_URL` and `VITE_API_GRAPHQL_URL`

### ✅ 1.4.6 Confirm containers network properly — **COMPLETED**

* `backend` reaches `postgres` via service DNS name `postgres`
* frontend reaches backend via host ports

### ✅ 1.4.7 Validate backend → DB connection — **COMPLETED**

* `/health` returns `db: true` (smoke queries run)

### ✅ 1.4.8 Validate frontend → backend connection — **COMPLETED**

* frontend displays backend/DB status from `/health`

### ✅ 1.4.9 Confirm full stack boots via Docker — **COMPLETED**

* `docker compose up --build` works end-to-end

---

# What’s left (short list)

**Backend**

* 1.2.7 Global exception handler (still needed)
* (Optional) ensure logging middleware is actually mounted if you want it guaranteed

**Frontend**

* 1.3.2 Add remaining deps (table, router, graphql client, charts)
* 1.3.3 Create the full folder tree
* 1.3.5 Router base routes
* 1.3.6 Layout wrapper
* 1.3.7 Theme provider toggle

If you want to continue “one at a time,” the next clean atomic step is **1.2.7 Global exception handler**.

