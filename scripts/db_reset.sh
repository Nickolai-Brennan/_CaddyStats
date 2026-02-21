#!/bin/bash
set -e

echo "Dropping database..."
docker compose exec postgres psql -U postgres -c "DROP DATABASE IF EXISTS caddystats;"
docker compose exec postgres psql -U postgres -c "CREATE DATABASE caddystats;"

echo "Running migrations..."
for file in database/migrations/*.sql; do
  echo "Applying $file"
  docker compose exec -T postgres psql -U postgres -d caddystats < "$file"
done

echo "Seeding..."
docker compose exec -T postgres psql -U postgres -d caddystats < database/seeds/seed.sql

echo "Done."
