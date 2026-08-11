#!/usr/bin/env bash
# Create /mnt/storage layout used by the appliance.
set -euo pipefail

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"

ROOT="/mnt/storage"
SERVICE_USER="${DOOMBOX_SERVICE_USER:-doombox}"
DIRS=(
  docker
  ollama
  kiwix
  media
  backups
  compose
)

log "Ensuring ${ROOT} layout"
install -d -m 0755 "${ROOT}"
for d in "${DIRS[@]}"; do
  install -d -m 0755 "${ROOT}/${d}"
done

# App/data dirs owned by locked service user. Docker data-root stays root-managed.
if getent passwd "${SERVICE_USER}" >/dev/null; then
  for d in ollama kiwix media backups compose; do
    chown -R "${SERVICE_USER}:${SERVICE_USER}" "${ROOT}/${d}"
  done
  chown root:root "${ROOT}/docker"
  chmod 0711 "${ROOT}/docker"
else
  log "WARNING: service user ${SERVICE_USER} missing; skip chown (run configure-users first)"
fi

cat > "${ROOT}/README" <<EOF
HeyEddi Doomsday Box storage root.

Subdirs: docker (root/Docker), ollama, kiwix, media, backups, compose
App dirs are owned by locked service user: ${SERVICE_USER}
Do not delete this tree; apps and Docker data-root expect it.
EOF

log "Storage ready under ${ROOT}"
