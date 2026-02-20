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

Services

Frontend: http://localhost:5173

Backend: http://localhost:8000

Health: http://localhost:8000/health

GraphQL: http://localhost:8000/graphql


Notes

Postgres uses one database with two schemas:

content (site + editor + users + posts)

stats (golf analytics tables, projections, models)



Reply **“done”** and I’ll give you **Item 1.0.5** (commit convention rules).
