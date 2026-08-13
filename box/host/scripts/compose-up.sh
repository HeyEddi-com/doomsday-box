#!/usr/bin/env bash
# Start core Compose stack (no --build — images must already exist on golden / after enable).
set -euo pipefail

if [[ -f /usr/local/lib/doombox/host-env.sh ]]; then
  # shellcheck source=/dev/null
  source /usr/local/lib/doombox/host-env.sh
elif [[ -f "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/lib/host-env.sh" ]]; then
  # shellcheck source=lib/host-env.sh
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/lib/host-env.sh"
fi

if [[ -f /etc/default/doombox ]]; then
  # shellcheck source=/dev/null
  source /etc/default/doombox
fi

ROOT="${DOOMBOX_BOX_ROOT:-/opt/doombox}"
STORAGE="${DOOMBOX_STORAGE:-/mnt/storage}"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"
[[ -d "${ROOT}" ]] || die "DOOMBOX_BOX_ROOT missing: ${ROOT}"
[[ -f "${ROOT}/compose/docker-compose.yml" ]] || die "compose file missing under ${ROOT}"
command -v docker >/dev/null || die "docker required"

install -d -m 0755 "${STORAGE}/compose"
install -d -m 0755 /var/lib/doombox

cd "${ROOT}"
if [[ ! -f .env ]]; then
  [[ -f .env.example ]] || die "no .env and no .env.example in ${ROOT}"
  cp .env.example .env
fi

# Core stack only — remote-desktop profile stays off until Settings enable.
exec docker compose -f compose/docker-compose.yml --env-file .env up -d --remove-orphans
