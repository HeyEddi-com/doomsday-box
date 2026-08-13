#!/usr/bin/env bash
# Prepare this appliance for imaging (USB / disk clone).
# PHYSICAL CONSOLE ONLY — refuses SSH. Stops compose, wipes identity + claim,
# leaves systemd units enabled so clones boot the stack without SSH.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f /usr/local/lib/doombox/physical-console.sh ]]; then
  # shellcheck source=/dev/null
  source /usr/local/lib/doombox/physical-console.sh
elif [[ -f "${HOST_ROOT}/scripts/lib/physical-console.sh" ]]; then
  # shellcheck source=lib/physical-console.sh
  source "${HOST_ROOT}/scripts/lib/physical-console.sh"
else
  echo "missing physical-console helper" >&2
  exit 1
fi

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

[[ "${EUID}" -eq 0 ]] || die "run as root (sudo doombox-prepare-golden)"
doombox_require_physical_console "prepare golden image" || exit $?

echo "This generalizes the box for cloning:"
echo "  - stop Compose"
echo "  - wipe claim / sessions under ${DATA}"
echo "  - empty machine-id and remove SSH host keys"
echo "  - arm first-boot for the next power-on"
echo "Docker images are KEPT (required for offline boot)."
read -r -p "Type PREPARE to continue: " ans
[[ "${ans}" == "PREPARE" ]] || { echo "aborted"; exit 1; }

install -d -m 0755 /var/lib/doombox

if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
  systemctl stop doombox-compose.service 2>/dev/null || true
fi
if [[ -x /usr/local/sbin/doombox-compose-down ]]; then
  /usr/local/sbin/doombox-compose-down || true
elif [[ -f "${HOST_ROOT}/scripts/compose-down.sh" ]]; then
  bash "${HOST_ROOT}/scripts/compose-down.sh" || true
fi

log "Wiping claim / session state"
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

log "Clearing machine-id and SSH host keys"
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
rm -f /etc/ssh/ssh_host_*

rm -f "${STAMP}"
date -u +%Y-%m-%dT%H:%M:%SZ >"${GOLDEN_PENDING}"
chmod 0644 "${GOLDEN_PENDING}"

log "Golden pending marker written (${GOLDEN_PENDING})"
log "Next: power off, image the disk (doombox-bake-golden or dd|gzip), flash clones."
log "Do NOT reboot this reference unit into multi-user before imaging — first-boot would mint a PIN into the golden."
