#!/usr/bin/env bash
# Stop core Compose stack (leave containers; images stay for next boot).
set -euo pipefail

if [[ -f /etc/default/doombox ]]; then
  # shellcheck source=/dev/null
  source /etc/default/doombox
fi

ROOT="${DOOMBOX_BOX_ROOT:-/opt/doombox}"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"
[[ -f "${ROOT}/compose/docker-compose.yml" ]] || die "compose file missing under ${ROOT}"
command -v docker >/dev/null || die "docker required"

cd "${ROOT}"
[[ -f .env ]] || die "missing ${ROOT}/.env"
exec docker compose -f compose/docker-compose.yml --env-file .env stop
