#!/usr/bin/env bash
# Wipe claim + setup state for local compose retests.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/.env"
COMPOSE_FILE="${ROOT}/compose/docker-compose.yml"

STORAGE_ROOT="$(grep -E '^STORAGE_ROOT=' "${ENV_FILE}" | head -1 | cut -d= -f2-)"
STORAGE_ROOT="${STORAGE_ROOT:-/mnt/storage}"
DATA="${STORAGE_ROOT}/compose"

rm -f "${DATA}/setup-state.json" "${DATA}/setup-claim.json" "${DATA}/SETUP_PIN.txt"
echo "Cleared claim files under ${DATA}"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" restart api
echo "API restarted. New PIN:"
sleep 2
"${ROOT}/scripts/dev-claim-pin.sh"
