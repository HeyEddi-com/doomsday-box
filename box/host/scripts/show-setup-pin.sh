#!/usr/bin/env bash
# Show the one-time first-run claim PIN (physical presence). Never exposed over HTTP.
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

[[ "${EUID}" -eq 0 ]] || { echo "run as root (sudo doombox-show-setup-pin)"; exit 1; }
doombox_require_physical_console "show-setup-pin" || exit $?

PIN_FILE="${DOOMBOX_STORAGE:-/mnt/storage}/compose/SETUP_PIN.txt"
STATE_FILE="${DOOMBOX_STORAGE:-/mnt/storage}/compose/setup-state.json"

if [[ -f "${STATE_FILE}" ]] && grep -q '"setup_complete": true' "${STATE_FILE}" 2>/dev/null; then
  echo "Setup already completed — claim PIN was consumed."
  echo "Factory reset on the local console is required to generate a new claim."
  exit 1
fi

if [[ ! -f "${PIN_FILE}" ]]; then
  echo "No SETUP_PIN.txt yet. Start the API/compose stack once so it can mint a claim code."
  echo "Tried: ${PIN_FILE}"
  exit 1
fi

echo "Doomsday Box claim code (enter this in first-run setup):"
echo
tr -d '\n' < "${PIN_FILE}"
echo
echo
echo "Keep this private. Anyone with this code can claim the box on your LAN."
