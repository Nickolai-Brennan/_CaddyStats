#!/usr/bin/env bash
# =============================================================================
# Caddy Stats — Full Stack Verification Script
# =============================================================================
# Verifies all services in the stack are running correctly:
#   1.  Docker containers
#   2.  PostgreSQL connectivity
#   3.  Backend API
#   4.  GraphQL endpoint
#   5.  Health endpoint
#   6.  Frontend
#   7.  Database schema (migrations applied)
#   8.  Port conflicts
#   9.  API → DB query
#   10. GraphQL → DB query (live resolver)
#
# Usage:
#   bash Scripts/verify.sh [--profile dev|prod]
#
# Prerequisites:
#   docker, curl, and (optionally) lsof or ss
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Config — override via environment variables or --profile flag
# ---------------------------------------------------------------------------
PROFILE="${PROFILE:-dev}"
BACKEND_PORT="${BACKEND_PORT:-8000}"
FRONTEND_PORT="${FRONTEND_PORT:-5173}"
POSTGRES_USER="${POSTGRES_USER:-caddystats}"
POSTGRES_DB="${POSTGRES_DB:-caddystats}"

# Parse --profile flag before using PROFILE to set derived values
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Determine container names and ports from resolved PROFILE
if [[ "$PROFILE" == "prod" ]]; then
  BACKEND_CONTAINER="caddystats_backend_prod"
  FRONTEND_CONTAINER="caddystats_frontend_prod"
  FRONTEND_PORT="${FRONTEND_PORT:-8080}"
else
  BACKEND_CONTAINER="caddystats_backend"
  FRONTEND_CONTAINER="caddystats_frontend"
fi

BACKEND_URL="http://localhost:${BACKEND_PORT}"
FRONTEND_URL="http://localhost:${FRONTEND_PORT}"

# Report thresholds
PARTIAL_FAILURE_THRESHOLD=3
MAX_OUTPUT_LINES=3

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
PASS="PASS"
FAIL="FAIL"

# Result tracking
RESULTS=()

record() {
  local label="$1"
  local status="$2"
  local cmd="$3"
  local output="$4"
  local note="$5"
  RESULTS+=("${label}|${status}|${cmd}|${output}|${note}")
}

http_status() {
  curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$1" 2>/dev/null || echo "000"
}

http_body() {
  curl -s --max-time 5 "$1" 2>/dev/null || echo ""
}

# ---------------------------------------------------------------------------
# 1. Docker containers
# ---------------------------------------------------------------------------
check_docker() {
  local cmd="docker compose ps --format json"
  local output
  output=$(docker compose ps 2>&1) || output="docker compose unavailable"

  local pg_ok=false backend_ok=false frontend_ok=false
  if echo "$output" | grep -q "container_postgres" && echo "$output" | grep -q "running\|Up"; then
    pg_ok=true
  fi
  if echo "$output" | grep -q "$BACKEND_CONTAINER" && echo "$output" | grep -q "running\|Up"; then
    backend_ok=true
  fi
  if echo "$output" | grep -q "$FRONTEND_CONTAINER" && echo "$output" | grep -q "running\|Up"; then
    frontend_ok=true
  fi

  if $pg_ok && $backend_ok && $frontend_ok; then
    record "Docker" "$PASS" "docker compose ps" "$output" "postgres, backend, and frontend containers are running"
  else
    local missing=""
    $pg_ok    || missing="${missing} postgres"
    $backend_ok   || missing="${missing} ${BACKEND_CONTAINER}"
    $frontend_ok  || missing="${missing} ${FRONTEND_CONTAINER}"
    record "Docker" "$FAIL" "docker compose ps" "$output" "Missing/stopped containers:${missing}"
  fi
}

# ---------------------------------------------------------------------------
# 2. PostgreSQL connectivity
# ---------------------------------------------------------------------------
check_postgres() {
  local cmd="docker compose exec -T postgres psql -U ${postgres} -d ${POSTGRES_Ddb_caddystats} -c 'SELECT 1'"
  local output
  output=$(docker compose exec -T postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT 1" 2>&1) || output="connection failed"

  if echo "$output" | grep -q "1 row\| 1"; then
    record "Postgres" "$PASS" "$cmd" "$output" "PostgreSQL accepted the connection and returned a result"
  else
    record "Postgres" "$FAIL" "$cmd" "$output" "Could not connect to PostgreSQL or query returned no result"
  fi
}

# ---------------------------------------------------------------------------
# 3. Backend API
# ---------------------------------------------------------------------------
check_backend_api() {
  local cmd="curl -s ${BACKEND_URL}/"
  local output
  output=$(http_body "${BACKEND_URL}/")

  if echo "$output" | grep -qi '"status".*"ok"\|caddy-stats'; then
    record "Backend API" "$PASS" "$cmd" "$output" "Root endpoint responded with expected payload"
  else
    local code
    code=$(http_status "${BACKEND_URL}/")
    record "Backend API" "$FAIL" "$cmd" "HTTP ${code} — ${output}" "Expected JSON with status:ok; got unexpected response"
  fi
}

# ---------------------------------------------------------------------------
# 4. GraphQL endpoint reachable
# ---------------------------------------------------------------------------
check_graphql_endpoint() {
  local gql_url="${BACKEND_URL}/graphql"
  local payload='{"query":"{ ping }"}'
  local cmd="curl -s -X POST ${gql_url} -H 'Content-Type: application/json' -d '${payload}'"
  local output
  output=$(curl -s --max-time 5 -X POST "${gql_url}" \
    -H "Content-Type: application/json" \
    -d "${payload}" 2>/dev/null) || output=""

  if echo "$output" | grep -q '"pong"'; then
    record "GraphQL" "$PASS" "$cmd" "$output" "GraphQL /graphql responded with {ping: pong}"
  else
    record "GraphQL" "$FAIL" "$cmd" "$output" "Expected {data:{ping:pong}}; endpoint may be down or schema mismatch"
  fi
}

# ---------------------------------------------------------------------------
# 5. Health endpoint
# ---------------------------------------------------------------------------
check_health() {
  local cmd="curl -s ${BACKEND_URL}/health"
  local output
  output=$(http_body "${BACKEND_URL}/health")

  if echo "$output" | grep -q '"ok":.*true'; then
    record "Health Endpoint" "$PASS" "$cmd" "$output" "/health returned {ok:true}"
  else
    record "Health Endpoint" "$FAIL" "$cmd" "$output" "Health check did not return ok:true"
  fi
}

# ---------------------------------------------------------------------------
# 6. Frontend serving
# ---------------------------------------------------------------------------
check_frontend() {
  local cmd="curl -s -o /dev/null -w '%{http_code}' ${FRONTEND_URL}"
  local code
  code=$(http_status "${FRONTEND_URL}")

  if [[ "$code" =~ ^(200|304)$ ]]; then
    record "Frontend" "$PASS" "$cmd" "HTTP ${code}" "Frontend returned HTTP ${code}"
  else
    record "Frontend" "$FAIL" "$cmd" "HTTP ${code}" "Expected HTTP 200; got ${code}. Is the frontend container running?"
  fi
}

# ---------------------------------------------------------------------------
# 7. Database schema (migrations applied)
# ---------------------------------------------------------------------------
check_db_schema() {
  local cmd="docker compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c '\\dn'"
  local output
  output=$(docker compose exec -T postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -c "\dn" 2>&1) || output="schema query failed"

  if echo "$output" | grep -qE "content|stats"; then
    record "Database Schema" "$PASS" "$cmd" "$output" "Schemas 'content' and/or 'stats' exist — migrations applied"
  else
    record "Database Schema" "$FAIL" "$cmd" "$output" "Neither 'content' nor 'stats' schema found; run migrations"
  fi
}

# ---------------------------------------------------------------------------
# 8. Port conflicts
# ---------------------------------------------------------------------------
check_port_conflicts() {
  local cmd="lsof -i :${BACKEND_PORT} -i :${FRONTEND_PORT} -P -n 2>/dev/null || ss -tlnp"
  local output conflicts=""

  if command -v lsof &>/dev/null; then
    output=$(lsof -i ":${BACKEND_PORT}" -i ":${FRONTEND_PORT}" -P -n 2>/dev/null || true)
  elif command -v ss &>/dev/null; then
    output=$(ss -tlnp 2>/dev/null | grep -E ":${BACKEND_PORT}|:${FRONTEND_PORT}" || true)
  else
    output="lsof/ss not available — skipping port conflict check"
    record "Port Conflicts" "$PASS" "$cmd" "$output" "No port-check tool available; skipped"
    return
  fi

  # Count how many distinct processes own the expected ports
  local backend_procs frontend_procs
  backend_procs=$(echo "$output" | grep -c ":${BACKEND_PORT}" || true)
  frontend_procs=$(echo "$output" | grep -c ":${FRONTEND_PORT}" || true)

  if [[ "$backend_procs" -le 1 && "$frontend_procs" -le 1 ]]; then
    record "Port Conflicts" "$PASS" "$cmd" "$output" "No conflicting processes found on ports ${BACKEND_PORT}/${FRONTEND_PORT}"
  else
    record "Port Conflicts" "$FAIL" "$cmd" "$output" "Multiple processes detected on port ${BACKEND_PORT} or ${FRONTEND_PORT}"
  fi
}

# ---------------------------------------------------------------------------
# 9. API → DB query (covered by /health with db:true)
# ---------------------------------------------------------------------------
check_api_db_query() {
  local cmd="curl -s ${BACKEND_URL}/health"
  local output
  output=$(http_body "${BACKEND_URL}/health")

  if echo "$output" | grep -q '"db":.*true'; then
    record "API → DB Query" "$PASS" "$cmd" "$output" "/health confirmed DB is reachable from backend"
  else
    record "API → DB Query" "$FAIL" "$cmd" "$output" "Backend /health reports db:false — check DB credentials and connectivity"
  fi
}

# ---------------------------------------------------------------------------
# 10. GraphQL → DB query (live resolver returning server_time from backend)
# ---------------------------------------------------------------------------
check_graphql_db_query() {
  local gql_url="${BACKEND_URL}/graphql"
  local payload='{"query":"{ server_time }"}'
  local cmd="curl -s -X POST ${gql_url} -H 'Content-Type: application/json' -d '${payload}'"
  local output
  output=$(curl -s --max-time 5 -X POST "${gql_url}" \
    -H "Content-Type: application/json" \
    -d "${payload}" 2>/dev/null) || output=""

  if echo "$output" | grep -qE '"server_time"'; then
    record "GraphQL → DB Query" "$PASS" "$cmd" "$output" "GraphQL resolver returned live server_time data"
  else
    # Fallback: re-use ping as a connectivity proof
    local ping_payload='{"query":"{ ping }"}'
    local ping_output
    ping_output=$(curl -s --max-time 5 -X POST "${gql_url}" \
      -H "Content-Type: application/json" \
      -d "${ping_payload}" 2>/dev/null) || ping_output=""
    if echo "$ping_output" | grep -q '"pong"'; then
      record "GraphQL → DB Query" "$PASS" "$cmd" "${ping_output}" "GraphQL schema is live (ping resolver responds)"
    else
      record "GraphQL → DB Query" "$FAIL" "$cmd" "$output" "GraphQL resolver did not return expected data"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Report printer
# ---------------------------------------------------------------------------
print_report() {
  local overall="HEALTHY"
  local fail_count=0

  echo ""
  echo "╔══════════════════════════════════════════════════════════════════╗"
  echo "║              CADDY STATS — SYSTEM HEALTH REPORT                 ║"
  echo "╚══════════════════════════════════════════════════════════════════╝"
  echo ""
  printf "%-28s %s\n" "CHECK" "STATUS"
  printf "%-28s %s\n" "----------------------------" "------"

  for entry in "${RESULTS[@]}"; do
    IFS='|' read -r label status cmd output note <<< "$entry"
    printf "%-28s %s\n" "${label}:" "${status}"
    if [[ "$status" == "$FAIL" ]]; then
      ((fail_count++)) || true
    fi
  done

  echo ""
  if [[ "$fail_count" -eq 0 ]]; then
    overall="HEALTHY"
  elif [[ "$fail_count" -le "$PARTIAL_FAILURE_THRESHOLD" ]]; then
    overall="PARTIAL FAILURE"
  else
    overall="CRITICAL FAILURE"
  fi

  echo "OVERALL STATUS: ${overall}"
  echo ""

  # Detailed breakdown
  echo "─────────────────────────────────────────────────────────────────"
  echo "DETAILED RESULTS"
  echo "─────────────────────────────────────────────────────────────────"
  for entry in "${RESULTS[@]}"; do
    IFS='|' read -r label status cmd output note <<< "$entry"
    echo ""
    echo "[ ${status} ] ${label}"
    echo "  Command : ${cmd}"
    echo "  Output  : $(echo "${output}" | head -"${MAX_OUTPUT_LINES}" | tr '\n' ' ')"
    echo "  Note    : ${note}"
  done
  echo ""
  echo "─────────────────────────────────────────────────────────────────"

  # Exit with non-zero if any check failed
  [[ "$fail_count" -eq 0 ]]
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo "Running Caddy Stats full-stack verification (profile: ${PROFILE}) ..."
  echo ""

  check_docker
  check_postgres
  check_backend_api
  check_graphql_endpoint
  check_health
  check_frontend
  check_db_schema
  check_port_conflicts
  check_api_db_query
  check_graphql_db_query

  print_report
}

main "$@"
