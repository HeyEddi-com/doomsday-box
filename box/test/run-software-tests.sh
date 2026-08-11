#!/usr/bin/env bash
# Run all software tests that do not require real hardware.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log() { printf '==> %s\n' "$*"; }

log "Dashboard typecheck + build"
(
  cd "${ROOT}/dashboard"
  npm ci
  npm run typecheck
  npm run build
  npm test
)

log "API pytest"
(
  cd "${ROOT}/api"
  if [[ ! -d .venv ]]; then
    if command -v python3.12 >/dev/null 2>&1; then
      python3.12 -m venv .venv
    else
      python3 -m venv .venv
    fi
  fi
  # shellcheck disable=SC1091
  source .venv/bin/activate
  pip install -q -r requirements-dev.txt
  pytest -q
)

if [[ "${DOOMBOX_SKIP_CONTAINER_TESTS:-0}" != "1" ]]; then
  log "Host container smoke"
  "${ROOT}/host/test/run-container-smoke.sh"
fi

if [[ "${DOOMBOX_SKIP_COMPOSE_TESTS:-0}" != "1" ]]; then
  log "Compose stack smoke"
  bash "${ROOT}/test/run-compose-smoke.sh"
fi

log "All software tests passed"
