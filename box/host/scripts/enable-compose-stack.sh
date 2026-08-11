#!/usr/bin/env bash
# Start Compose stack and point host nginx at the gateway (port 8080).
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOX_ROOT="$(cd "${HOST_ROOT}/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

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

log "Gateway up. Open http://box.local/ (host :80 → compose gateway :8080)"
log "API docs via http://box.local/api/docs"
