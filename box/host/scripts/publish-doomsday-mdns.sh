#!/usr/bin/env bash
# Publish doomsday.local as an Avahi address alias for the default IPv4.
set -euo pipefail

for _ in $(seq 1 30); do
  if ip -4 route show default >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

IFACE="$(ip -4 route show default | awk '{print $5; exit}')"
ADDR="$(ip -4 -o addr show dev "${IFACE}" | awk '{print $4}' | cut -d/ -f1 | head -n1)"
[[ -n "${ADDR}" ]] || exit 1

exec /usr/bin/avahi-publish -a -R doomsday.local "${ADDR}"
