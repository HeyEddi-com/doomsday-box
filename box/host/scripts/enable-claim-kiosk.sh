#!/usr/bin/env bash
# Enable loopback claim PIN kiosk (HDMI path). Never exposes PIN on the LAN.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

WITH_BROWSER=0
[[ "${1:-}" == "--with-browser" ]] && WITH_BROWSER=1

[[ "${EUID}" -eq 0 ]] || die "run as root"

install -d -m 0755 /usr/local/lib/doombox
install -m 0755 "${HOST_ROOT}/kiosk/claim_kiosk.py" /usr/local/lib/doombox/claim_kiosk.py
install -m 0644 "${HOST_ROOT}/conf/systemd/doombox-claim-kiosk.service" \
  /etc/systemd/system/doombox-claim-kiosk.service

if doombox_has_systemd; then
  systemctl daemon-reload
  systemctl enable --now doombox-claim-kiosk.service
  log "Kiosk API: http://127.0.0.1:7901/ (loopback only — plug HDMI + open locally)"
else
  log "No systemd — start manually: python3 /usr/local/lib/doombox/claim_kiosk.py"
fi

if [[ "${WITH_BROWSER}" -eq 1 ]]; then
  if ! command -v chromium >/dev/null 2>&1 && ! command -v chromium-browser >/dev/null 2>&1; then
    die "chromium not installed (apt-get install -y chromium) for --with-browser"
  fi
  install -m 0644 "${HOST_ROOT}/conf/systemd/doombox-claim-kiosk-browser.service" \
    /etc/systemd/system/doombox-claim-kiosk-browser.service
  # Prefer chromium binary name
  if command -v chromium-browser >/dev/null 2>&1 && ! command -v chromium >/dev/null 2>&1; then
    sed -i 's|/usr/bin/chromium|/usr/bin/chromium-browser|' \
      /etc/systemd/system/doombox-claim-kiosk-browser.service
  fi
  systemctl daemon-reload
  systemctl enable --now doombox-claim-kiosk-browser.service || log "Browser unit needs a graphical seat — enable later"
  log "Fullscreen browser unit installed (needs DISPLAY / graphical target)"
fi

log "PIN is never served on box.local — only 127.0.0.1:${DOOMBOX_KIOSK_PORT:-7901}"
