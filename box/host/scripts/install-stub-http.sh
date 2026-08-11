#!/usr/bin/env bash
# Serve the Phase-v0 stub page on port 80 via nginx.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"
log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"

WEB_ROOT="/var/www/doombox-stub"
log "Installing stub HTTP site"
install -d -m 0755 "${WEB_ROOT}"
install -m 0644 "${HOST_ROOT}/stub/index.html" "${WEB_ROOT}/index.html"
install -d /etc/nginx/sites-available /etc/nginx/sites-enabled
install -m 0644 "${HOST_ROOT}/conf/nginx/doombox-stub.conf" /etc/nginx/sites-available/doombox-stub

if [[ -e /etc/nginx/sites-enabled/default ]]; then
  rm -f /etc/nginx/sites-enabled/default
fi
ln -sfn /etc/nginx/sites-available/doombox-stub /etc/nginx/sites-enabled/doombox-stub

nginx -t
if doombox_has_systemd; then
  systemctl enable --now nginx
  systemctl reload nginx
else
  # Container / no-systemd path
  nginx -s stop 2>/dev/null || true
  nginx
fi

log "Stub available on http://box.local/ and http://doomsday.local/"
