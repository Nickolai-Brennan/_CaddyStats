#!/bin/bash

echo "Checking PostgreSQL..."
docker compose exec postgres pg_isready

echo "Checking Backend..."
curl -s http://localhost:8000/health

echo "Checking GraphQL..."
curl -s -X POST http://localhost:8000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __typename }"}'

echo "Checking Frontend..."
curl -s http://localhost:5173
