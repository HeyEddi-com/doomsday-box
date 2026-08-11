#!/usr/bin/env bash
# Wipe claim + setup state so the box can be claimed again.
#
# PHYSICAL CONSOLE ONLY. Refuses SSH / remote sessions on purpose.
# There is no HTTP/API factory-reset — do not add one.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Prefer installed copy next to other sbin tools when packaged
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

DATA="${DOOMBOX_STORAGE:-/mnt/storage}/compose"

[[ "${EUID}" -eq 0 ]] || { echo "run as root (sudo doombox-factory-reset-claim)"; exit 1; }

doombox_require_physical_console "factory reset" || exit $?

echo "This deletes setup-state and claim files under ${DATA}"
echo "A new claim PIN will be minted on next API start (old sticker PIN becomes invalid)."
read -r -p "Type RESET to continue: " ans
[[ "${ans}" == "RESET" ]] || { echo "aborted"; exit 1; }

if command -v chattr >/dev/null 2>&1; then
  chattr -i \
    "${DATA}/setup-state.json" \
    "${DATA}/setup-claim.json" \
    "${DATA}/SETUP_PIN.txt" 2>/dev/null || true
fi

rm -f "${DATA}/setup-state.json" "${DATA}/setup-claim.json" "${DATA}/SETUP_PIN.txt"
echo "Cleared. Restart the API container to mint a new claim PIN, then: doombox-show-setup-pin"
echo "Re-label with: doombox-export-claim-label"
