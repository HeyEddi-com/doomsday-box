#!/usr/bin/env bash
# First boot after a golden flash: unique machine identity + wipe cloned claim state.
# Idempotent via /var/lib/doombox/first-boot.done (removed by prepare-golden).
#
# Claim wipe runs only on the clone path (empty machine-id and/or golden-pending
# marker). A normal enable-compose-stack install must not erase an existing claim.
set -euo pipefail

if [[ -f /etc/default/doombox ]]; then
  # shellcheck source=/dev/null
  source /etc/default/doombox
fi

STORAGE="${DOOMBOX_STORAGE:-/mnt/storage}"
DATA="${STORAGE}/compose"
STAMP="/var/lib/doombox/first-boot.done"
GOLDEN_PENDING="/var/lib/doombox/golden-pending"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '==> %s\n' "$*"; }

[[ "${EUID}" -eq 0 ]] || die "run as root"

if [[ -f "${STAMP}" ]]; then
  log "first-boot already done (${STAMP})"
  exit 0
fi

install -d -m 0755 /var/lib/doombox
install -d -m 0755 "${DATA}"

CLONE=0
if [[ -f "${GOLDEN_PENDING}" ]] || [[ ! -s /etc/machine-id ]]; then
  CLONE=1
fi

if [[ ! -s /etc/machine-id ]]; then
  log "Regenerating machine-id (empty after golden bake)"
  rm -f /var/lib/dbus/machine-id
  if command -v systemd-machine-id-setup >/dev/null 2>&1; then
    systemd-machine-id-setup
  else
    openssl rand -hex 16 >/etc/machine-id
    chmod 0444 /etc/machine-id
  fi
else
  log "Keeping existing machine-id"
fi

if [[ -d /var/lib/dbus ]]; then
  ln -sfn /etc/machine-id /var/lib/dbus/machine-id
fi

shopt -s nullglob
host_keys=(/etc/ssh/ssh_host_*)
shopt -u nullglob
if [[ "${#host_keys[@]}" -eq 0 ]]; then
  log "Generating SSH host keys (sshd stays disabled unless operator opted in)"
  if command -v ssh-keygen >/dev/null 2>&1; then
    ssh-keygen -A
  fi
else
  log "SSH host keys already present"
fi

if [[ "${CLONE}" -eq 1 ]]; then
  log "Clone path — wiping claim / session state (API will mint a fresh PIN)"
  if command -v chattr >/dev/null 2>&1; then
    chattr -i \
      "${DATA}/setup-state.json" \
      "${DATA}/setup-claim.json" \
      "${DATA}/SETUP_PIN.txt" 2>/dev/null || true
  fi
  rm -f \
    "${DATA}/setup-state.json" \
    "${DATA}/setup-claim.json" \
    "${DATA}/SETUP_PIN.txt" \
    "${DATA}/sessions.json" \
    "${DATA}/apps.json"
  rm -f "${GOLDEN_PENDING}"
else
  log "Not a golden clone — leaving claim state untouched"
fi

date -u +%Y-%m-%dT%H:%M:%SZ >"${STAMP}"
chmod 0644 "${STAMP}"
log "First-boot complete — stamp ${STAMP}"
