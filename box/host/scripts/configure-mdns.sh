#!/usr/bin/env bash
# Avahi: box.local via hostname; doomsday.local via avahi-publish alias unit.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"
log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"

log "Configuring Avahi / mDNS"
install -d /etc/avahi
if [[ -f /etc/avahi/avahi-daemon.conf ]]; then
  sed -i \
    -e 's/^#\?use-ipv4=.*/use-ipv4=yes/' \
    -e 's/^#\?use-ipv6=.*/use-ipv6=no/' \
    -e 's/^#\?publish-addresses=.*/publish-addresses=yes/' \
    -e 's/^#\?publish-hostname=.*/publish-hostname=yes/' \
    /etc/avahi/avahi-daemon.conf || true
fi

install -m 0755 \
  "${HOST_ROOT}/scripts/publish-doomsday-mdns.sh" \
  /usr/local/sbin/doombox-publish-doomsday-mdns

if doombox_has_systemd; then
  install -d /etc/systemd/system
  install -m 0644 \
    "${HOST_ROOT}/conf/systemd/doombox-mdns-alias.service" \
    /etc/systemd/system/doombox-mdns-alias.service
  systemctl daemon-reload
  systemctl enable --now avahi-daemon
  systemctl enable --now doombox-mdns-alias.service
  systemctl restart doombox-mdns-alias.service || true
else
  log "No systemd — starting avahi best-effort (container smoke)"
  doombox_service_enable_now avahi-daemon
  install -d -m 0755 /var/log/doombox
  # Alias publisher needs a default route; may no-op in slim containers.
  /usr/local/sbin/doombox-publish-doomsday-mdns >>/var/log/doombox/mdns-alias.log 2>&1 &
fi

log "mDNS: hostname box.local + alias doomsday.local"
