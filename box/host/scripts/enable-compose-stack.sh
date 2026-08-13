#!/usr/bin/env bash
# Start Compose stack and point host nginx at the gateway (port 8080).
# Also installs systemd boot units (doombox-compose + first-boot).
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOX_ROOT="$(cd "${HOST_ROOT}/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

PULL_REMOTE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pull-remote-desktop) PULL_REMOTE=1; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: sudo ./scripts/enable-compose-stack.sh [--pull-remote-desktop]

  Builds/starts the core stack, points host nginx at the gateway, and enables
  doombox-compose.service so the hub comes up on power without SSH.

  --pull-remote-desktop  Also pull webtop images (desktop still off until Settings)
EOF
      exit 0
      ;;
    *) die "unknown arg: $1" ;;
  esac
done

[[ "${EUID}" -eq 0 ]] || die "run as root"
command -v docker >/dev/null || die "docker required — run bootstrap without --skip-docker first"

install -d -m 0755 /mnt/storage/compose
install -d -m 0755 /var/lib/doombox
cd "${BOX_ROOT}"
if [[ ! -f .env ]]; then
  cp .env.example .env
  log "Created box/.env from .env.example"
fi

log "Building and starting compose stack (amd64/arm64 native)"
docker compose -f compose/docker-compose.yml --env-file .env up -d --build

install -m 0644 \
  "${HOST_ROOT}/conf/nginx/doombox-gateway-proxy.conf" \
  /etc/nginx/sites-available/doombox-gateway
ln -sfn /etc/nginx/sites-available/doombox-gateway /etc/nginx/sites-enabled/doombox-gateway
rm -f /etc/nginx/sites-enabled/doombox-stub

nginx -t
if doombox_has_systemd; then
  systemctl reload nginx
else
  nginx -s reload 2>/dev/null || { nginx -s stop 2>/dev/null || true; nginx; }
fi

BOOT_ARGS=()
[[ "${PULL_REMOTE}" -eq 1 ]] && BOOT_ARGS+=(--pull-remote-desktop)
DOOMBOX_BOX_ROOT="${DOOMBOX_BOX_ROOT:-${BOX_ROOT}}" \
  "${HOST_ROOT}/scripts/install-compose-boot.sh" "${BOOT_ARGS[@]+"${BOOT_ARGS[@]}"}"

log "Gateway up. Open http://box.local/ (host :80 → compose gateway :8080)"
log "API docs via http://box.local/api/docs"
log "Reboot test: systemctl is-enabled doombox-compose.service"
