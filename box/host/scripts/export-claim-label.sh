#!/usr/bin/env bash
# Export a professional claim / identity label pack for *this* chassis.
#
# Outputs under /mnt/storage/backups/labels/<SERIAL>/:
#   meta.json   — full fields (support / reprint)
#   label.html  — printable packing card (browser → print)
#   label.zpl   — Zebra-style thermal (Code128 serial + QR claim)
#   claim-qr.png — if qrencode is installed
#   ledger append to claim-ledger.csv
#
# Usage (on the box, after API minted SETUP_PIN.txt):
#   sudo doombox-export-claim-label
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

[[ "${EUID}" -eq 0 ]] || { echo "run as root (sudo doombox-export-claim-label)"; exit 1; }
doombox_require_physical_console "export-claim-label" || exit $?

STORAGE="${DOOMBOX_STORAGE:-/mnt/storage}"
DATA="${STORAGE}/compose"
PIN_FILE="${DATA}/SETUP_PIN.txt"
ID_FILE="${DATA}/BOX_ID"                 # HeyEddi serial (HHDB-…)
OEM_FILE="${DATA}/OEM_SERIAL"            # Chassis / motherboard serial from DMI
IDENTITY_FILE="${DATA}/identity.json"    # Both + metadata
PRODUCT_ENV="${DOOMBOX_PRODUCT_ENV:-/etc/doombox/product.env}"
EXAMPLE_ENV="${HOST_ROOT}/conf/product.env.example"
LEDGER="${DOOMBOX_CLAIM_LEDGER:-${STORAGE}/backups/claim-ledger.csv}"
LABEL_ROOT="${STORAGE}/backups/labels"

# --- product defaults ---
PRODUCT_NAME="HeyEddi Doomsday Box"
PRODUCT_SKU="HEY-DDBX-001"
PRODUCT_MODEL=""
MANUFACTURER="HeyEddi"
SETUP_URL_HUB="http://box.local/setup"
SETUP_URL_SURVIVAL="http://doomsday.local/setup"

if [[ -f "${PRODUCT_ENV}" ]]; then
  # shellcheck disable=SC1090
  set -a
  # shellcheck source=/dev/null
  source "${PRODUCT_ENV}"
  set +a
elif [[ -f "${EXAMPLE_ENV}" ]]; then
  echo "Note: ${PRODUCT_ENV} missing — using defaults (install conf/product.env.example)." >&2
fi

mkdir -p "$(dirname "${LEDGER}")" "${DATA}" "${LABEL_ROOT}"

normalize_id() {
  printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | tr -c 'A-Z0-9\-' '-' | sed 's/-\+/-/g; s/^-\|-$//g'
}

read_oem_serial() {
  local oem=""
  if [[ -r /sys/class/dmi/id/product_serial ]]; then
    oem="$(tr -d '\n' < /sys/class/dmi/id/product_serial)"
  fi
  if [[ -z "${oem}" || "${oem}" == "None" || "${oem}" == "To be filled by O.E.M." || "${oem}" == "To-be-filled-by-O.E.M." ]]; then
    if [[ -r /sys/class/dmi/id/board_serial ]]; then
      oem="$(tr -d '\n' < /sys/class/dmi/id/board_serial)"
    fi
  fi
  if [[ -z "${oem}" || "${oem}" == "None" || "${oem}" == "To be filled by O.E.M." || "${oem}" == "To-be-filled-by-O.E.M." ]]; then
    oem="UNKNOWN"
  fi
  normalize_id "${oem}"
}

# HeyEddi serial: HHDB-<UTC datestamp>-<4 chars>
# Example: HHDB-20260811T062901Z-K7MP
mint_heyeddi_serial() {
  local stamp suffix alphabet i
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  alphabet="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
  suffix=""
  for i in 1 2 3 4; do
    suffix+="${alphabet:RANDOM%${#alphabet}:1}"
  done
  printf 'HHDB-%s-%s' "${stamp}" "${suffix}"
}

resolve_identity() {
  local heyeddi oem
  oem="$(read_oem_serial)"
  printf '%s\n' "${oem}" > "${OEM_FILE}"
  chmod 644 "${OEM_FILE}" || true

  if [[ -f "${ID_FILE}" ]]; then
    heyeddi="$(tr -d '\n' < "${ID_FILE}")"
  else
    heyeddi=""
  fi
  heyeddi="$(normalize_id "${heyeddi}")"

  # Keep stable HHDB serials; replace legacy DBX-/OEM-as-id values
  if [[ ! "${heyeddi}" =~ ^HHDB-[0-9]{8}T[0-9]{6}Z-[A-Z0-9]{4}$ ]]; then
    heyeddi="$(mint_heyeddi_serial)"
  fi

  printf '%s\n' "${heyeddi}" > "${ID_FILE}"
  chmod 644 "${ID_FILE}" || true

  cat > "${IDENTITY_FILE}" <<EOF
{
  "heyeddi_serial": "${heyeddi}",
  "oem_serial": "${oem}",
  "assigned_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
  chmod 644 "${IDENTITY_FILE}" || true

  HEYEDDI_SERIAL="${heyeddi}"
  OEM_SERIAL="${oem}"
}

resolve_model() {
  if [[ -n "${PRODUCT_MODEL}" ]]; then
    printf '%s' "${PRODUCT_MODEL}"
    return
  fi
  local arch
  arch="$(uname -m)"
  case "${arch}" in
    x86_64|amd64)
      if grep -qi 'N150' /proc/cpuinfo 2>/dev/null; then echo "N150"
      elif grep -qi 'N100' /proc/cpuinfo 2>/dev/null; then echo "N100"
      else echo "x86_64"; fi
      ;;
    aarch64|arm64) echo "ARM64" ;;
    *) echo "${arch}" ;;
  esac
}

primary_mac() {
  local iface mac
  for iface in eth0 enp1s0 end0 wlan0; do
    if [[ -r "/sys/class/net/${iface}/address" ]]; then
      mac="$(tr -d '\n' < "/sys/class/net/${iface}/address")"
      if [[ -n "${mac}" && "${mac}" != "00:00:00:00:00:00" ]]; then
        printf '%s' "${mac}"
        return
      fi
    fi
  done
  mac="$(ip -o link show 2>/dev/null | awk -F': ' '!/lo:/{print $2; exit}')"
  if [[ -n "${mac:-}" && -r "/sys/class/net/${mac}/address" ]]; then
    tr -d '\n' < "/sys/class/net/${mac}/address"
  fi
}

if [[ ! -f "${PIN_FILE}" ]]; then
  echo "No claim PIN yet. Start the compose stack once, then re-run." >&2
  echo "Expected: ${PIN_FILE}" >&2
  exit 1
fi

resolve_identity
SERIAL="${HEYEDDI_SERIAL}"
PIN="$(tr -d '\n' < "${PIN_FILE}" | tr '[:lower:]' '[:upper:]')"
MODEL="$(resolve_model)"
ARCH="$(uname -m)"
MAC="$(primary_mac || true)"
MFG_DATE="$(date -u +%Y-%m-%d)"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUT="${LABEL_ROOT}/${SERIAL}"
mkdir -p "${OUT}"

# QR payload: scannable claim hint (human can still type PIN)
QR_PAYLOAD="HEYEDDI DOOMSDAY BOX
SKU: ${PRODUCT_SKU}
S/N: ${SERIAL}
OEM: ${OEM_SERIAL}
CLAIM: ${PIN}
SETUP: ${SETUP_URL_HUB}
"

QR_PNG="${OUT}/claim-qr.png"
if command -v qrencode >/dev/null 2>&1; then
  qrencode -o "${QR_PNG}" -s 6 -m 2 "${QR_PAYLOAD}"
else
  echo "Optional: apt-get install -y qrencode  # for claim-qr.png on the label HTML" >&2
  QR_PNG=""
fi

# --- meta.json ---
cat > "${OUT}/meta.json" <<EOF
{
  "manufacturer": "$(printf '%s' "${MANUFACTURER}" | sed 's/"/\\"/g')",
  "product_name": "$(printf '%s' "${PRODUCT_NAME}" | sed 's/"/\\"/g')",
  "product_sku": "${PRODUCT_SKU}",
  "product_model": "${MODEL}",
  "heyeddi_serial": "${SERIAL}",
  "oem_serial": "${OEM_SERIAL}",
  "serial": "${SERIAL}",
  "claim_pin": "${PIN}",
  "arch": "${ARCH}",
  "mac": "${MAC}",
  "mfg_date": "${MFG_DATE}",
  "setup_url_hub": "${SETUP_URL_HUB}",
  "setup_url_survival": "${SETUP_URL_SURVIVAL}",
  "exported_at": "${TS}"
}
EOF
chmod 600 "${OUT}/meta.json" || true

# --- ZPL: Code128 = HeyEddi serial; human lines include OEM ---
cat > "${OUT}/label.zpl" <<EOF
^XA
^PW812
^LL406
^LH20,20
^CF0,28
^FO20,20^FD${MANUFACTURER}^FS
^CF0,36
^FO20,55^FD${PRODUCT_NAME}^FS
^CF0,22
^FO20,100^FDSKU ${PRODUCT_SKU}  MODEL ${MODEL}^FS
^FO20,130^FDMade ${MFG_DATE}  Arch ${ARCH}^FS
^BY2,2,50
^FO20,160^BCN,50,Y,N,N
^FD${SERIAL}^FS
^FO20,240^FDHHDB ${SERIAL}^FS
^FO20,270^FDOEM ${OEM_SERIAL}^FS
^FO480,100^BQN,2,4
^FDLA,${PIN}^FS
^FO480,265^FDCLAIM ${PIN}^FS
^FO480,295^FD${SETUP_URL_HUB}^FS
^XZ
EOF

# --- HTML packing card ---
QR_IMG_TAG=""
if [[ -n "${QR_PNG}" && -f "${QR_PNG}" ]]; then
  QR_B64="$(base64 -w0 "${QR_PNG}" 2>/dev/null || base64 "${QR_PNG}" | tr -d '\n')"
  QR_IMG_TAG="<img class=\"qr\" alt=\"Claim QR\" src=\"data:image/png;base64,${QR_B64}\" />"
else
  QR_IMG_TAG="<div class=\"qr-fallback\"><strong>CLAIM</strong><br/><span class=\"pin\">${PIN}</span><br/><small>Install qrencode for QR art</small></div>"
fi

MAC_ROW=""
if [[ -n "${MAC}" ]]; then
  MAC_ROW="<tr><th>MAC</th><td>${MAC}</td></tr>"
fi

cat > "${OUT}/label.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Label ${SERIAL}</title>
  <style>
    @page { size: 100mm 50mm; margin: 4mm; }
    * { box-sizing: border-box; }
    body {
      font-family: "IBM Plex Sans", "Segoe UI", Helvetica, Arial, sans-serif;
      color: #1a221c;
      margin: 0;
      background: #e8ece6;
    }
    .sheet {
      width: 100mm;
      min-height: 50mm;
      background: #fff;
      border: 1px solid #c5cdc6;
      padding: 3.5mm 4mm;
      display: grid;
      grid-template-columns: 1fr 28mm;
      gap: 3mm;
    }
    .brand {
      font-size: 8pt;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: #3d7a62;
      margin: 0 0 1mm;
    }
    h1 {
      font-family: "IBM Plex Serif", Georgia, serif;
      font-size: 12pt;
      margin: 0 0 2mm;
      font-weight: 600;
    }
    table { width: 100%; border-collapse: collapse; font-size: 8pt; }
    th {
      text-align: left;
      color: #5c6b62;
      font-weight: 500;
      width: 18mm;
      padding: 0.45mm 0;
      vertical-align: top;
    }
    td { padding: 0.45mm 0; font-variant-numeric: tabular-nums; }
    .serial {
      font-family: ui-monospace, "IBM Plex Mono", monospace;
      font-size: 9.5pt;
      letter-spacing: 0.02em;
      font-weight: 600;
    }
    .barcode-text {
      font-family: ui-monospace, monospace;
      font-size: 7.5pt;
      letter-spacing: 0.08em;
      margin-top: 1.2mm;
      padding: 1mm 0;
      border-top: 3px solid #1a221c;
      border-bottom: 3px solid #1a221c;
      text-align: center;
      word-break: break-all;
    }
    .pin {
      font-family: ui-monospace, monospace;
      font-size: 13pt;
      letter-spacing: 0.18em;
      font-weight: 600;
    }
    .qr { width: 26mm; height: 26mm; image-rendering: pixelated; }
    .qr-fallback {
      border: 1px solid #c5cdc6;
      padding: 2mm;
      text-align: center;
      font-size: 8pt;
    }
    .hint { grid-column: 1 / -1; font-size: 7pt; color: #5c6b62; margin: 0; }
    @media print {
      body { background: #fff; }
      .sheet { border: none; }
      .no-print { display: none; }
    }
    .no-print { margin: 12px; font-size: 14px; }
  </style>
</head>
<body>
  <p class="no-print">Print at 100% scale. Thermal: send <code>label.zpl</code>. HeyEddi S/N is primary; OEM matches the chassis sticker.</p>
  <article class="sheet">
    <div>
      <p class="brand">${MANUFACTURER}</p>
      <h1>${PRODUCT_NAME}</h1>
      <table>
        <tr><th>SKU</th><td>${PRODUCT_SKU}</td></tr>
        <tr><th>Model</th><td>${MODEL}</td></tr>
        <tr><th>HHDB</th><td class="serial">${SERIAL}</td></tr>
        <tr><th>OEM</th><td class="serial">${OEM_SERIAL}</td></tr>
        <tr><th>Claim</th><td class="pin">${PIN}</td></tr>
        <tr><th>Made</th><td>${MFG_DATE}</td></tr>
        ${MAC_ROW}
      </table>
      <div class="barcode-text" title="HeyEddi serial">${SERIAL}</div>
    </div>
    <div>
      ${QR_IMG_TAG}
    </div>
    <p class="hint">Setup: ${SETUP_URL_HUB} · OEM chassis match: ${OEM_SERIAL} · PIN single-use</p>
  </article>
</body>
</html>
EOF

# --- ledger ---
if [[ ! -f "${LEDGER}" ]]; then
  echo "timestamp_utc,heyeddi_serial,oem_serial,product_sku,product_model,claim_pin,mac,mfg_date,label_dir,note" > "${LEDGER}"
  chmod 600 "${LEDGER}" || true
fi
echo "${TS},${SERIAL},${OEM_SERIAL},${PRODUCT_SKU},${MODEL},${PIN},${MAC},${MFG_DATE},${OUT},provisioned" >> "${LEDGER}"

chmod 700 "${OUT}" 2>/dev/null || true
chmod 600 "${OUT}/label.zpl" "${OUT}/meta.json" 2>/dev/null || true

cat <<EOF

======== UNIT LABEL PACK ========
Product:        ${PRODUCT_NAME}
SKU:            ${PRODUCT_SKU}
Model:          ${MODEL}
HeyEddi S/N:    ${SERIAL}
OEM chassis:    ${OEM_SERIAL}
Claim PIN:      ${PIN}
MAC:            ${MAC:-n/a}
Made:           ${MFG_DATE}
=================================
Identity files:
  ${ID_FILE}
  ${OEM_FILE}
  ${IDENTITY_FILE}
Label pack:
  ${OUT}/label.html
  ${OUT}/label.zpl
  ${OUT}/meta.json
  ${QR_PNG:-"(no QR png — install qrencode)"}
Ledger:
  ${LEDGER}

Ship rule: sticker on chassis OEM ${OEM_SERIAL} (HeyEddi ${SERIAL}).
Customer: enter Claim PIN at ${SETUP_URL_HUB}
EOF
