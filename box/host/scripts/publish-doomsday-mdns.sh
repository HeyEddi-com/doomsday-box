#!/usr/bin/env bash
# Publish doomsday.local as an Avahi address alias for the default IPv4.
set -euo pipefail

IFACE=""
for _ in $(seq 1 30); do
  IFACE="$(ip -4 route show default 2>/dev/null | awk '/ dev / { for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }')"
  if [[ -n "${IFACE}" ]]; then
    break
  fi
  sleep 1
done
[[ -n "${IFACE}" ]] || exit 1
ADDR="$(ip -4 -o addr show dev "${IFACE}" | awk '{print $4}' | cut -d/ -f1 | head -n1)"
[[ -n "${ADDR}" ]] || exit 1

exec /usr/bin/avahi-publish -a -R doomsday.local "${ADDR}"
