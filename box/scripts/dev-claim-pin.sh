#!/usr/bin/env bash
# Dev helper: print the live claim PIN from local compose storage.
# Never expose this over the network; for workstation testing only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/.env"
COMPOSE_FILE="${ROOT}/compose/docker-compose.yml"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Copy from .env.example and set STORAGE_ROOT." >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
# STORAGE_ROOT only
STORAGE_ROOT="$(grep -E '^STORAGE_ROOT=' "${ENV_FILE}" | head -1 | cut -d= -f2-)"
set +a
STORAGE_ROOT="${STORAGE_ROOT:-/mnt/storage}"
PIN_FILE="${STORAGE_ROOT}/compose/SETUP_PIN.txt"

echo "=== DoomBox claim PIN (dev) ==="
echo "storage: ${STORAGE_ROOT}/compose"
echo

print_pin_via_docker() {
  docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" exec -T api \
    cat /mnt/storage/compose/SETUP_PIN.txt 2>/dev/null | tr -d '\n'
}

PIN=""
if [[ -f "${PIN_FILE}" ]]; then
  PIN="$(cat "${PIN_FILE}" 2>/dev/null | tr -d '\n' || true)"
fi
if [[ -z "${PIN}" ]]; then
  PIN="$(print_pin_via_docker || true)"
fi

if [[ -n "${PIN}" ]]; then
  echo "PIN: ${PIN}"
else
  echo "No SETUP_PIN.txt yet. Starting API so it can mint one…"
  docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d api
  sleep 2
  PIN="$(print_pin_via_docker || true)"
  if [[ -z "${PIN}" ]]; then
    echo "Still no PIN. Is the API healthy?" >&2
    exit 1
  fi
  echo "PIN: ${PIN}"
fi

echo
echo "UI: http://127.0.0.1:8080/setup"
echo "Reset:  ${ROOT}/scripts/dev-reset-claim.sh"
