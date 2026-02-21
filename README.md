# Caddy Stats

Golf analytics + content platform (Strik3Zone).

## Local Development (Docker)

```bash
cp .env.example .env
docker compose --profile dev up --build
```

PowerShell:

```powershell
Copy-Item .env.example .env
docker compose --profile dev up --build
```

### Services

| Service  | URL                           |
|----------|-------------------------------|
| Frontend | http://localhost:5173         |
| Backend  | http://localhost:8000         |
| Health   | http://localhost:8000/health  |
| GraphQL  | http://localhost:8000/graphql |

## Stack Verification

After starting the stack, run the verification script to confirm all services are healthy:

```bash
bash Scripts/verify.sh
```

To verify the production profile:

```bash
bash Scripts/verify.sh --profile prod
```

The script performs 10 checks and prints a structured health report:

```
CADDY STATS — SYSTEM HEALTH REPORT

Docker:                      PASS
Postgres:                    PASS
Backend API:                 PASS
GraphQL:                     PASS
Health Endpoint:             PASS
Frontend:                    PASS
Database Schema:             PASS
Port Conflicts:              PASS
API → DB Query:              PASS
GraphQL → DB Query:          PASS

OVERALL STATUS: HEALTHY
```

Exit code is `0` when all checks pass, non-zero on any failure.

## Notes

Postgres uses one database with two schemas:

- `content` — site content, editor, users, posts
- `stats` — golf analytics tables, projections, models
