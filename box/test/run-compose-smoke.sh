#!/usr/bin/env bash
# Full stack smoke: api + dashboard + gateway via compose.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORAGE="$(mktemp -d)"
HOST_STATE="$(mktemp -d)"
COOKIE_JAR="$(mktemp)"
ENV_FILE="${ROOT}/.env"
COMPOSE=(docker compose -f "${ROOT}/compose/docker-compose.yml" --env-file "${ENV_FILE}")

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

cleanup() {
  "${COMPOSE[@]}" down --remove-orphans >/dev/null 2>&1 || true
  rm -rf "${STORAGE}" "${HOST_STATE}" "${COOKIE_JAR}"
}
trap cleanup EXIT

command -v docker >/dev/null || die "docker not found"
command -v curl >/dev/null || die "curl not found"

[[ -f "${ENV_FILE}" ]] || cp "${ROOT}/.env.example" "${ENV_FILE}"

mkdir -p "${STORAGE}/compose"
chmod -R a+rwx "${STORAGE}"
mkdir -p "${HOST_STATE}"
chmod a+rx "${HOST_STATE}"

export STORAGE_ROOT="${STORAGE}"
export DOOMBOX_HOST_STATE="${HOST_STATE}"
export GATEWAY_HTTP_PORT="${GATEWAY_HTTP_PORT:-8080}"
# Smoke must not pull webtop via API toggle
export DOOMBOX_DOCKER_CONTROL=0

log "Building and starting compose stack (storage=${STORAGE})"
"${COMPOSE[@]}" up -d --build --wait

BASE="http://127.0.0.1:${GATEWAY_HTTP_PORT}"

log "Gateway health"
curl -fsS "${BASE}/api/health" | grep -q '"ok":true'

log "Gateway status (unclaimed)"
curl -fsS "${BASE}/api/status" | grep -q '"setup_open":true'

log "Dashboard shell"
curl -fsS -o /dev/null "${BASE}/"

PIN="$("${COMPOSE[@]}" exec -T api cat /mnt/storage/compose/SETUP_PIN.txt | tr -d ' \n')"
[[ -n "${PIN}" ]] || die "claim PIN not minted in api container"

log "Claim ceremony via gateway"
curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  -X POST "${BASE}/api/setup" \
  -H 'Content-Type: application/json' \
  -d "{\"claim_code\":\"${PIN}\",\"admin_password\":\"compose-smoke1\",\"network_mode\":\"lan\"}" \
  | grep -q '"setup_complete":true'

log "Authenticated /api/me"
curl -fsS -b "${COOKIE_JAR}" "${BASE}/api/me" | grep -q '"authenticated":true'

log "Operator status contract"
curl -fsS -b "${COOKIE_JAR}" "${BASE}/api/operator-status" \
  | grep -q '"factory_reset_via_api":false'

log "Auth session for desktop gateway"
curl -fsS -o /dev/null -b "${COOKIE_JAR}" "${BASE}/api/auth/session"
curl -s -o /dev/null -w '%{http_code}' "${BASE}/api/auth/session" | grep -q '401'

log "Remote desktop desired-state API (no webtop pull in smoke)"
curl -fsS -b "${COOKIE_JAR}" "${BASE}/api/apps/remote-desktop" | grep -q '"desired":false'
curl -fsS -b "${COOKIE_JAR}" -X POST "${BASE}/api/apps/remote-desktop" \
  -H 'Content-Type: application/json' \
  -d '{"enabled":true}' | grep -q '"desired":true'
curl -fsS -b "${COOKIE_JAR}" -X POST "${BASE}/api/apps/remote-desktop" \
  -H 'Content-Type: application/json' \
  -d '{"enabled":false}' | grep -q '"desired":false'

log "Desktop path redirects unsigned browsers to hub login"
code="$(curl -s -o /dev/null -w '%{http_code}' "${BASE}/desktop/")"
[[ "${code}" == "302" ]] || die "expected /desktop/ 302 without cookie, got ${code}"
loc="$(curl -sI "${BASE}/desktop/" | tr -d '\r' | awk 'tolower($1)=="location:"{print $2}')"
[[ "${loc}" == *"/login?next=/desktop/"* ]] || die "expected Location /login?next=/desktop/, got ${loc}"

log "Compose stack smoke OK"
