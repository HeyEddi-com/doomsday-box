#!/usr/bin/env bash
# Runs inside the Debian bookworm test container.
set -euo pipefail

HOST_ROOT="/opt/doombox-host"
export DOOMBOX_TEST_MODE=container
export DEBIAN_FRONTEND=noninteractive

cd "${HOST_ROOT}"
chmod +x scripts/*.sh scripts/lib/*.sh test/*.sh 2>/dev/null || true

ARGS=(--skip-docker)
if [[ "${DOOMBOX_TEST_WITH_DOCKER:-0}" == "1" ]]; then
  ARGS=()
fi

echo "==> container bootstrap: ./scripts/bootstrap.sh ${ARGS[*]:-}"
./scripts/bootstrap.sh "${ARGS[@]}"

echo "==> container smoke-check --container"
./scripts/smoke-check.sh --container

echo "==> HTTP stub"
curl -fsS http://127.0.0.1/ | head -n 5

echo "CONTAINER SMOKE OK"
