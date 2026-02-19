# Deployment Guide – Caddy Stats

Stack:
Frontend: React + Vite
Backend: FastAPI + Strawberry
Database: PostgreSQL
Infra: Docker + Reverse Proxy

Goal:
Consistent local → staging → production environments.

---

# 1️⃣ Environment Strategy

Environments:

- local
- staging
- production

Each must have:

DATABASE_URL_APP
DATABASE_URL_GOLF
JWT_SECRET
CORS_ORIGINS
ENVIRONMENT
REDIS_URL (future)
STRIPE_SECRET (future)

Never commit real secrets.

---

# 2️⃣ Local Development (Docker Compose)

File:
docker-compose.yml

Services:

- frontend
- backend
- postgres
- nginx (optional local proxy)

Command:

docker compose up --build

Ports:

Frontend: 5173
Backend: 8000
Postgres: 5432

Volumes:

- postgres_data
- backend code mount (dev only)
- frontend code mount (dev only)

---

# 3️⃣ Production Container Build

Directory:
/docker/

---

## 3.1 Frontend Dockerfile

docker/frontend.Dockerfile

Multi-stage build:

1. Node build stage
2. NGINX static serve stage

Output:
Optimized static bundle

---

## 3.2 Backend Dockerfile

docker/backend.Dockerfile

Base:
python:3.11-slim

Steps:
- install dependencies
- copy app
- run uvicorn

CMD:
uvicorn app.main:app --host 0.0.0.0 --port 8000

---

# 4️⃣ Reverse Proxy (NGINX)

File:
docker/nginx.conf

Responsibilities:

- Route / to frontend
- Route /graphql and /api to backend
- Enable gzip
- Set caching headers
- Terminate SSL (optional if not using external LB)

---

# 5️⃣ Production Infrastructure Layout

Recommended:

CDN (Cloudflare or similar)
        ↓
Reverse Proxy / Load Balancer
        ↓
Frontend Container (static)
Backend Container (FastAPI)
        ↓
Managed PostgreSQL

---

# 6️⃣ Managed PostgreSQL

Production DB must:

- Run on managed provider
- Have automated backups
- Enable connection pooling
- Restrict IP access
- Enforce SSL

Schemas:

app_schema
golf_schema

Backups:
Nightly automatic
Retention: 7–30 days

---

# 7️⃣ SSL Configuration

Options:

1. Managed by hosting provider
2. Cloudflare SSL
3. NGINX Let's Encrypt

All traffic:
Force HTTPS redirect.

---

# 8️⃣ CDN Strategy

Cache:

- Static frontend assets
- Images
- OG images
- Public REST endpoints (short TTL)

Do NOT cache:

- Authenticated endpoints
- GraphQL mutations

---

# 9️⃣ Caching & Performance

REST endpoints:

Cache-Control:
public, max-age=60

Materialized views:
Refreshed pre-tournament

Future:
Redis for:
- leaderboard hot cache
- premium dashboards

---

# 🔟 Monitoring & Logging

Backend:

Log:
- request path
- status code
- execution time
- user_id (if present)

Log destination:
stdout (container)
Aggregated via hosting provider

Database:
Enable slow query log.

Frontend:
Track:
- load time
- error rate

Future:
Integrate error tracking service.

---

# 11️⃣ CI/CD Pipeline (Recommended)

Steps:

1. Run lint + tests
2. Build frontend
3. Build backend image
4. Run migration
5. Deploy containers
6. Health check endpoints

Health check:

GET /api/leaderboard?tournamentId=test

Must return 200.

---

# 12️⃣ Rollback Procedure

If deployment fails:

1. Stop new container
2. Revert to previous image tag
3. Restore DB backup if migration broke schema
4. Clear CDN cache

Migration policy:
Never destructive without backup.

---

# 13️⃣ Security Hardening Checklist

- Disable GraphQL playground in production
- Restrict CORS origins
- Set secure cookies (if used)
- Use strong JWT secret
- Use environment-based config
- Sanitize HTML blocks
- Limit admin route exposure

---

# 14️⃣ Horizontal Scaling (Future)

Backend:
Scale container replicas

Stats endpoints:
Can scale independently

Frontend:
Statically served via CDN

Database:
Read replicas for analytics-heavy loads

---

# 15️⃣ Deployment Checklist

- [ ] Environment variables set
- [ ] Database migrations applied
- [ ] Indexes verified
- [ ] Health check passes
- [ ] SSL active
- [ ] CDN active
- [ ] Sitemap accessible
- [ ] robots.txt accessible
- [ ] GraphQL playground disabled
- [ ] Rate limiting active
