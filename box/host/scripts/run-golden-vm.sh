#!/usr/bin/env bash
# Boot a Debian 12 QEMU lab VM that mimics a flashed golden clone.
# Artifacts stay in <repo>/.golden/ (gitignored). Not the factory USB blob.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOX_ROOT="$(cd "${HOST_ROOT}/.." && pwd)"
REPO_ROOT="$(cd "${BOX_ROOT}/.." && pwd)"
GOLDEN_DIR="${DOOMBOX_GOLDEN_DIR:-${REPO_ROOT}/.golden}"

HTTP_PORT="${DOOMBOX_LAB_HTTP_PORT:-18080}"
SERIAL_PORT="${DOOMBOX_LAB_SERIAL_PORT:-18700}"
MEM_MB="${DOOMBOX_LAB_MEM_MB:-8192}"
CPUS="${DOOMBOX_LAB_CPUS:-4}"
DISK_GB="${DOOMBOX_LAB_DISK_GB:-32}"
PULL_REMOTE="${DOOMBOX_PULL_REMOTE:-1}"

DEBIAN_URL="${DOOMBOX_DEBIAN_CLOUD_URL:-https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2}"
OVMF_CODE="${DOOMBOX_OVMF_CODE:-/usr/share/edk2/x64/OVMF_CODE.4m.fd}"
OVMF_VARS_SRC="${DOOMBOX_OVMF_VARS:-/usr/share/edk2/x64/OVMF_VARS.4m.fd}"

BASE_IMG="${GOLDEN_DIR}/debian-12-genericcloud-amd64.qcow2"
DISK_IMG="${GOLDEN_DIR}/doombox-lab.qcow2"
OVMF_VARS="${GOLDEN_DIR}/ovmf-vars.fd"
SEED_IMG="${GOLDEN_DIR}/seed-cidata.img"
SERIAL_LOG="${GOLDEN_DIR}/serial.log"
PID_FILE="${GOLDEN_DIR}/qemu.pid"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage: $0 [--rebuild] [--stop] [--status]

  Boot a local UEFI QEMU VM: Debian 12 + bootstrap + compose-on-boot,
  then simulate a clone (prepare-golden + reboot).

  Hub:    http://127.0.0.1:${HTTP_PORT}/
  Serial: telnet 127.0.0.1 ${SERIAL_PORT}   (lab root password: doombox)

  Pre-pulls the webtop image during first provision (DOOMBOX_PULL_REMOTE=0 to skip).

  --rebuild  Wipe the lab disk and provision again
  --stop     Stop the running lab VM
  --status   Print qemu pid / HTTP check

Artifacts: ${GOLDEN_DIR}
EOF
}

qemu_running() {
  [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null
}

cmd_stop() {
  if [[ ! -f "${PID_FILE}" ]]; then
    log "Lab VM is not running"
    return 0
  fi
  local pid
  pid="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [[ -z "${pid}" ]] || ! kill -0 "${pid}" 2>/dev/null; then
    log "Lab VM is not running"
    rm -f "${PID_FILE}"
    return 0
  fi
  log "Stopping lab VM pid ${pid}"
  kill "${pid}" 2>/dev/null || true
  sleep 1
  if kill -0 "${pid}" 2>/dev/null; then
    kill -9 "${pid}" 2>/dev/null || true
  fi
  rm -f "${PID_FILE}"
}

cmd_status() {
  if qemu_running; then
    log "QEMU running pid=$(cat "${PID_FILE}")"
  else
    log "QEMU not running"
  fi
  if curl -fsS -o /dev/null --max-time 3 "http://127.0.0.1:${HTTP_PORT}/"; then
    log "Hub OK  http://127.0.0.1:${HTTP_PORT}/"
  else
    log "Hub not answering yet on :${HTTP_PORT}"
  fi
}

ensure_tools() {
  command -v qemu-system-x86_64 >/dev/null || die "qemu-system-x86_64 required"
  command -v qemu-img >/dev/null || die "qemu-img required"
  command -v mkfs.vfat >/dev/null || die "mkfs.vfat required"
  command -v mcopy >/dev/null || die "mcopy (mtools) required"
  [[ -r "${OVMF_CODE}" ]] || die "OVMF code missing: ${OVMF_CODE}"
  [[ -r "${OVMF_VARS_SRC}" ]] || die "OVMF vars missing: ${OVMF_VARS_SRC}"
  [[ -e /dev/kvm ]] || die "/dev/kvm missing — enable KVM"
}

ensure_base_image() {
  install -d -m 0755 "${GOLDEN_DIR}"
  if [[ -f "${BASE_IMG}" && -s "${BASE_IMG}" ]]; then
    log "Debian cloud image present ($(du -h "${BASE_IMG}" | awk '{print $1}'))"
    return 0
  fi
  log "Downloading Debian 12 genericcloud amd64"
  curl -fL --retry 3 --continue-at - -o "${BASE_IMG}.partial" "${DEBIAN_URL}"
  mv -f "${BASE_IMG}.partial" "${BASE_IMG}"
}

write_seed_disk() {
  local seed="${GOLDEN_DIR}/seed"
  rm -rf "${seed}"
  install -d -m 0755 "${seed}"

  cat >"${seed}/meta-data" <<'EOF'
instance-id: doombox-lab-001
local-hostname: box
EOF

  cat >"${seed}/user-data" <<'EOF'
#cloud-config
hostname: box
fqdn: box.local
manage_etc_hosts: true
ssh_pwauth: true
disable_root: false
chpasswd:
  expire: false
  list: |
    root:doombox
runcmd:
  - [ bash, -lc, "mkdir -p /mnt/cidata; mount /dev/disk/by-label/CIDATA /mnt/cidata 2>/dev/null || mount /dev/disk/by-label/cidata /mnt/cidata; exec bash /mnt/cidata/provision.sh" ]
EOF

  cat >"${seed}/provision.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exec > >(tee -a /var/log/doombox-lab-provision.log /dev/console) 2>&1
MARKER=/var/lib/doombox/lab-provision.done
if [[ -f "${MARKER}" ]]; then
  echo "==> lab provision already done; skipping"
  exit 0
fi
echo "==> doombox lab provision start $(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p /mnt/cidata /opt/doombox /mnt/storage /var/lib/doombox
if ! mountpoint -q /mnt/cidata; then
  mount /dev/disk/by-label/CIDATA /mnt/cidata 2>/dev/null || mount /dev/disk/by-label/cidata /mnt/cidata
fi
tar -xzf /mnt/cidata/box.tar.gz -C /opt/doombox
export DEBIAN_FRONTEND=noninteractive
cd /opt/doombox/host
./scripts/bootstrap.sh
./scripts/enable-compose-stack.sh
printf 'PREPARE\n' | /usr/local/sbin/doombox-prepare-golden
date -u +%Y-%m-%dT%H:%M:%SZ > "${MARKER}"
echo "==> doombox lab provision done; rebooting into clone first-boot"
sync
systemctl reboot
EOF
  chmod 0755 "${seed}/provision.sh"
  if [[ "${PULL_REMOTE}" == "1" ]]; then
    sed -i 's|./scripts/enable-compose-stack.sh|./scripts/enable-compose-stack.sh --pull-remote-desktop|' \
      "${seed}/provision.sh"
  fi

  log "Packing box/ into cidata disk (no node_modules / .venv)"
  tar -czf "${seed}/box.tar.gz" \
    --exclude=node_modules \
    --exclude=.venv \
    --exclude=dist \
    --exclude=__pycache__ \
    --exclude='.env' \
    --exclude='*.pyc' \
    -C "${BOX_ROOT}" .

  local fat_mb
  fat_mb="$(du -sm "${seed}" | awk '{print $1 + 16}')"
  rm -f "${SEED_IMG}"
  qemu-img create -f raw "${SEED_IMG}" "${fat_mb}M"
  mkfs.vfat -n CIDATA "${SEED_IMG}"
  mcopy -oi "${SEED_IMG}" "${seed}/user-data" ::user-data
  mcopy -oi "${SEED_IMG}" "${seed}/meta-data" ::meta-data
  mcopy -oi "${SEED_IMG}" "${seed}/provision.sh" ::provision.sh
  mcopy -oi "${SEED_IMG}" "${seed}/box.tar.gz" ::box.tar.gz
  local label="CIDATA"
  if command -v dosfslabel >/dev/null 2>&1; then
    label="$(dosfslabel "${SEED_IMG}" 2>/dev/null || echo CIDATA)"
  fi
  log "cidata disk $(du -h "${SEED_IMG}" | awk '{print $1}') label=${label}"
}

prepare_disk() {
  if [[ -f "${DISK_IMG}" ]]; then
    log "Reusing ${DISK_IMG} (pass --rebuild to wipe)"
    return 0
  fi
  log "Creating ${DISK_GB}G lab disk from Debian cloud image"
  qemu-img create -f qcow2 -F qcow2 -b "${BASE_IMG}" "${DISK_IMG}" "${DISK_GB}G"
  cp -f "${OVMF_VARS_SRC}" "${OVMF_VARS}"
}

boot_vm() {
  if qemu_running; then
    log "Lab VM already running pid=$(cat "${PID_FILE}")"
    return 0
  fi
  [[ -f "${OVMF_VARS}" ]] || cp -f "${OVMF_VARS_SRC}" "${OVMF_VARS}"
  : >"${SERIAL_LOG}"
  log "Starting QEMU (KVM, UEFI, ${CPUS} cpu, ${MEM_MB} MiB)"
  log "HTTP  http://127.0.0.1:${HTTP_PORT}/"
  log "Serial telnet 127.0.0.1 ${SERIAL_PORT}  (root / doombox)"
  qemu-system-x86_64 \
    -name doombox-lab \
    -machine q35,accel=kvm,smm=off \
    -cpu host \
    -smp "${CPUS}" \
    -m "${MEM_MB}" \
    -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}" \
    -drive if=pflash,format=raw,file="${OVMF_VARS}" \
    -drive if=none,id=sysdisk,file="${DISK_IMG}",format=qcow2,cache=writeback,discard=unmap \
    -device virtio-blk-pci,drive=sysdisk,bootindex=1 \
    -drive if=none,id=cidata,file="${SEED_IMG}",format=raw,readonly=on \
    -device virtio-blk-pci,drive=cidata \
    -smbios type=1,serial=ds=nocloud \
    -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:${HTTP_PORT}-:80" \
    -device virtio-net-pci,netdev=net0 \
    -device virtio-rng-pci \
    -display none \
    -chardev "socket,id=serial0,host=127.0.0.1,port=${SERIAL_PORT},server=on,wait=off,telnet=on,logfile=${SERIAL_LOG},logappend=on" \
    -serial chardev:serial0 \
    -pidfile "${PID_FILE}" \
    -daemonize
}

wait_for_hub() {
  local timeout_s="${DOOMBOX_LAB_TIMEOUT_S:-2700}"
  local start now elapsed
  start="$(date +%s)"
  log "Waiting up to ${timeout_s}s for hub on :${HTTP_PORT} (bootstrap + compose build + clone reboot)"
  while true; do
    now="$(date +%s)"
    elapsed=$((now - start))
    if (( elapsed > timeout_s )); then
      die "timed out after ${elapsed}s — see ${SERIAL_LOG}"
    fi
    if ! qemu_running; then
      die "QEMU exited during provision — see ${SERIAL_LOG}"
    fi
    # Avoid `curl | grep -q` under pipefail (SIGPIPE / flaky false negatives).
    local health
    health="$(curl -fsS --max-time 3 "http://127.0.0.1:${HTTP_PORT}/api/health" 2>/dev/null || true)"
    if [[ "${health}" == *'"ok"'* ]]; then
      log "Hub is up after ${elapsed}s → http://127.0.0.1:${HTTP_PORT}/"
      log "Claim PIN: telnet 127.0.0.1 ${SERIAL_PORT}  then  doombox-show-setup-pin"
      return 0
    fi
    sleep 8
  done
}

main() {
  local rebuild=0
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
    --stop) cmd_stop; exit 0 ;;
    --status) cmd_status; exit 0 ;;
    --rebuild) rebuild=1 ;;
    "") ;;
    *) die "unknown arg: $1" ;;
  esac

  ensure_tools
  if [[ "${rebuild}" -eq 1 ]]; then
    cmd_stop
    rm -f "${DISK_IMG}" "${OVMF_VARS}" "${SEED_IMG}" "${GOLDEN_DIR}/seed.iso"
    log "Wiped lab disk"
  fi

  ensure_base_image
  write_seed_disk
  prepare_disk
  boot_vm
  wait_for_hub
}

main "$@"
