#!/usr/bin/env bash
# Send the unit's label.zpl to a CUPS/raw thermal printer (physical console only).
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

[[ "${EUID}" -eq 0 ]] || { echo "run as root (sudo doombox-print-claim-label)"; exit 1; }
doombox_require_physical_console "print-claim-label" || exit $?

STORAGE="${DOOMBOX_STORAGE:-/mnt/storage}"
LABEL_ROOT="${STORAGE}/backups/labels"
PRINTER="${DOOMBOX_LABEL_PRINTER:-}"
SERIAL="${1:-}"

usage() {
  cat <<EOF
Usage: sudo doombox-print-claim-label [SERIAL]

  Prints label.zpl via CUPS raw queue.
  Env:
    DOOMBOX_LABEL_PRINTER  CUPS queue name (required unless only one raw printer)
    DOOMBOX_STORAGE        default /mnt/storage

First run export: sudo doombox-export-claim-label
Then:             sudo doombox-print-claim-label
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

if [[ -z "${SERIAL}" ]]; then
  # newest label dir
  SERIAL="$(find "${LABEL_ROOT}" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %f\n' 2>/dev/null | sort -nr | head -1 | awk '{print $2}')"
fi

[[ -n "${SERIAL}" ]] || { echo "No label pack found. Run doombox-export-claim-label first." >&2; exit 1; }
ZPL="${LABEL_ROOT}/${SERIAL}/label.zpl"
[[ -f "${ZPL}" ]] || { echo "Missing ${ZPL}" >&2; exit 1; }

if [[ -z "${PRINTER}" ]]; then
  # try first printer
  PRINTER="$(lpstat -p 2>/dev/null | awk '/^printer /{print $2; exit}')"
fi
[[ -n "${PRINTER}" ]] || {
  echo "No printer. Set DOOMBOX_LABEL_PRINTER=YourQueue (CUPS)." >&2
  echo "HTML fallback: open ${LABEL_ROOT}/${SERIAL}/label.html in a browser and print." >&2
  exit 1
}

command -v lp >/dev/null || { echo "CUPS lp missing (apt-get install -y cups cups-client)" >&2; exit 1; }

echo "Printing ${ZPL} → ${PRINTER} (raw ZPL)"
lp -d "${PRINTER}" -o raw "${ZPL}"
echo "Submitted. If blank, confirm the queue accepts raw ZPL (Zebra/Brother)."
echo "HTML packing card: ${LABEL_ROOT}/${SERIAL}/label.html"
