#!/usr/bin/env bash
# Turn off remote shell access (back to non-tech safe default).
set -euo pipefail

STATE_DIR="/var/lib/doombox"
REMOTE_ADMIN_MARKER="${STATE_DIR}/remote-admin-enabled"
ADMIN_USER="${DOOMBOX_ADMIN_USER:-heyeddi}"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"

log "Disabling sshd"
systemctl disable --now ssh 2>/dev/null || systemctl disable --now sshd 2>/dev/null || true
rm -f "${REMOTE_ADMIN_MARKER}"

# Re-lock password auth path; does not remove authorized_keys (can re-enable later).
passwd -l "${ADMIN_USER}" >/dev/null 2>&1 || true

log "Remote admin disabled. Browser apps on LAN/VPN are unchanged."
log "Re-enable: sudo doombox-enable-operator --pubkey '…' --enable-ssh"
