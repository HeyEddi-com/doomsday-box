#!/usr/bin/env bash
# Image a block device to a gzipped .img (artifacts stay OFF git).
# Prefer running from a live USB / second machine after doombox-prepare-golden.
set -euo pipefail

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '==> %s\n' "$*"; }

usage() {
  cat <<'EOF'
Usage: sudo doombox-bake-golden --device /dev/sdX --output /path/doombox-amd64-YYYYMMDD.img.gz

  --device   Source block device (entire disk, not a partition)
  --output  Destination .img.gz path (must not already exist)
  --confirm YES   Required safety latch

Example (from a live USB, after prepare-golden on the reference disk):
  sudo doombox-bake-golden --device /dev/nvme0n1 \
    --output /mnt/usb/doombox-amd64-$(date +%Y%m%d).img.gz --confirm YES

Never commit the .img.gz into the git repo.
EOF
}

DEVICE=""
OUTPUT=""
CONFIRM=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) DEVICE="${2:-}"; shift 2 ;;
    --output) OUTPUT="${2:-}"; shift 2 ;;
    --confirm) CONFIRM="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown arg: $1" ;;
  esac
done

[[ "${EUID}" -eq 0 ]] || die "run as root"
[[ -n "${DEVICE}" && -n "${OUTPUT}" ]] || { usage; exit 1; }
[[ "${CONFIRM}" == "YES" ]] || die "pass --confirm YES after double-checking the device"
[[ -b "${DEVICE}" ]] || die "not a block device: ${DEVICE}"
[[ ! -e "${OUTPUT}" ]] || die "output already exists: ${OUTPUT}"

# Refuse imaging the live root disk when / is mounted from it.
root_src="$(findmnt -n -o SOURCE / 2>/dev/null || true)"
if [[ -n "${root_src}" ]]; then
  root_disk="$(lsblk -no PKNAME "${root_src}" 2>/dev/null || true)"
  dev_base="$(basename "${DEVICE}")"
  if [[ -n "${root_disk}" && "${root_disk}" == "${dev_base}" ]]; then
    die "refusing to image the live root disk (${DEVICE}). Boot a live USB and bake from there."
  fi
  if [[ "${root_src}" == "${DEVICE}"* ]]; then
    die "refusing to image a device that backs / (${root_src}). Use a live USB."
  fi
fi

install -d -m 0755 "$(dirname "${OUTPUT}")"

log "Imaging ${DEVICE} → ${OUTPUT}"
log "This can take a long time. Verify the device name twice."
dd if="${DEVICE}" bs=64M status=progress | gzip -c >"${OUTPUT}"
sync
log "Done: ${OUTPUT} ($(du -h "${OUTPUT}" | awk '{print $1}'))"
log "Flash with: gunzip -c ${OUTPUT} | sudo dd of=/dev/TARGET bs=64M status=progress conv=fsync"
