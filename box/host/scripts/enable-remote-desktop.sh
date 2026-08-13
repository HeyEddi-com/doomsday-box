#!/usr/bin/env bash
# Start browser remote desktop (webtop) via compose profile.
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

puid="${REMOTE_DESKTOP_PUID:-1000}"
pgid="${REMOTE_DESKTOP_PGID:-1000}"
for envf in "${BOX_ROOT}/.env" "/box/.env"; do
  [[ -f "${envf}" ]] || continue
  # shellcheck disable=SC1090
  set -a
  # shellcheck disable=SC1091
  source "${envf}"
  set +a
  puid="${REMOTE_DESKTOP_PUID:-${puid}}"
  pgid="${REMOTE_DESKTOP_PGID:-${pgid}}"
  break
done
[[ "${puid}" =~ ^[0-9]+$ && "${pgid}" =~ ^[0-9]+$ ]] \
  || die "REMOTE_DESKTOP_PUID/PGID must be numeric (got ${puid}:${pgid})"

install -d -m 0755 /mnt/storage/compose
install -d -m 0755 -o "${puid}" -g "${pgid}" /mnt/storage/remote-desktop
install -d -m 0755 -o "${puid}" -g "${pgid}" /mnt/storage/workspace

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

# Mark desired state for the dashboard (locked; never wipe on corrupt JSON)
python3 "${update_apps_json}" --key remote_desktop --value true

log "Starting remote-desktop profile (pull may take a few minutes if image not cached)"
docker compose -f compose/docker-compose.yml --env-file .env --profile remote-desktop up -d remote-desktop

log "Desktop starting. Sign in to the hub, then open http://box.local/desktop/"
log "Install Cursor inside the desktop when you need the Cursor agent."
