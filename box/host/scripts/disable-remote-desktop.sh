#!/usr/bin/env bash
# Stop browser remote desktop compose profile.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f /etc/default/doombox ]]; then
  # shellcheck source=/dev/null
  source /etc/default/doombox
fi
if [[ -n "${DOOMBOX_BOX_ROOT:-}" && -f "${DOOMBOX_BOX_ROOT}/compose/docker-compose.yml" ]]; then
  BOX_ROOT="${DOOMBOX_BOX_ROOT}"
  HOST_ROOT="${BOX_ROOT}/host"
elif [[ -f "${HOST_ROOT}/../compose/docker-compose.yml" ]]; then
  BOX_ROOT="$(cd "${HOST_ROOT}/.." && pwd)"
elif [[ -f /opt/doombox/compose/docker-compose.yml ]]; then
  BOX_ROOT=/opt/doombox
  HOST_ROOT=/opt/doombox/host
else
  echo "ERROR: cannot locate box compose root (set DOOMBOX_BOX_ROOT)" >&2
  exit 1
fi
if [[ -f /usr/local/lib/doombox/host-env.sh ]]; then
  # shellcheck source=/dev/null
  source /usr/local/lib/doombox/host-env.sh
else
  # shellcheck source=lib/host-env.sh
  source "${HOST_ROOT}/scripts/lib/host-env.sh"
fi

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"
command -v docker >/dev/null || die "docker required"

cd "${BOX_ROOT}"
[[ -f .env ]] || cp .env.example .env

update_apps_json=""
for helper in \
  "${HOST_ROOT}/scripts/lib/update-apps-json.py" \
  "/usr/local/lib/doombox/update-apps-json.py"
do
  if [[ -f "${helper}" ]]; then
    update_apps_json="${helper}"
    break
  fi
done
[[ -n "${update_apps_json}" ]] || die "update-apps-json.py not found"

python3 "${update_apps_json}" --key remote_desktop --value false

log "Flushing apt software cache before stop"
docker compose -f compose/docker-compose.yml --env-file .env --profile remote-desktop \
  exec -T remote-desktop /usr/local/bin/doombox-sync-apt-cache || true

log "Stopping remote-desktop"
docker compose -f compose/docker-compose.yml --env-file .env --profile remote-desktop stop remote-desktop || true

log "Remote desktop stopped."
