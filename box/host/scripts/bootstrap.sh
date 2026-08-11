#!/usr/bin/env bash
# DoomBox host bootstrap — idempotent. Run as root on Debian 12.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"
SKIP_DOCKER=0
FORCE=0

usage() {
  cat <<'EOF'
Usage: sudo ./scripts/bootstrap.sh [--skip-docker] [--force]

  --skip-docker  Skip Docker Engine install
  --force        Allow non-Debian-12 hosts (dev only)

Default (non-tech safe):
  heyeddi  locked maker (no full sudo/docker) — ignore forever OK
  doombox  service account (no login)
  sshd     disabled until: doombox-enable-operator --pubkey '…' --enable-ssh

See host/SECURITY.md and host/docs/MAKER.txt
EOF
}

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

require_root() {
  [[ "${EUID}" -eq 0 ]] || die "run as root (sudo)"
}

assert_debian_bookworm() {
  [[ -r /etc/os-release ]] || die "/etc/os-release missing"
  # shellcheck source=/dev/null
  . /etc/os-release
  if [[ "${ID:-}" != "debian" || "${VERSION_ID:-}" != "12" ]]; then
    if [[ "${FORCE}" -eq 1 ]]; then
      log "WARNING: expected Debian 12; continuing with --force (${ID:-unknown} ${VERSION_ID:-unknown})"
      return 0
    fi
    die "expected Debian 12 (bookworm); got ${ID:-unknown} ${VERSION_ID:-unknown}. Re-run with --force only for experiments."
  fi
}

apt_base_packages() {
  log "Installing base packages"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    openssh-server \
    avahi-daemon \
    avahi-utils \
    libnss-mdns \
    nginx \
    unattended-upgrades \
    apt-listchanges \
    sudo \
    iproute2 \
    iptables \
    nftables \
    wireless-tools \
    iw \
    rfkill \
    dbus \
    openssl
  # Install OpenSSH but do not leave it enabled — configure-users disables sshd
  # unless remote admin was previously opted in.
  doombox_service_disable_now ssh
  doombox_service_disable_now sshd
  doombox_service_enable_now unattended-upgrades
}

configure_hostname() {
  log "Setting hostname to box (box.local via Avahi)"
  doombox_set_hostname box
  if grep -qE '^127\.0\.1\.1[[:space:]]+box(\s|$)' /etc/hosts; then
    return 0
  fi
  if grep -qE '^127\.0\.1\.1' /etc/hosts; then
    sed -i -E 's/^127\.0\.1\.1.*/127.0.1.1\tbox/' /etc/hosts
  else
    printf '127.0.1.1\tbox\n' >> /etc/hosts
  fi
}

install_sysctl() {
  log "Installing sysctl defaults"
  install -d /etc/sysctl.d
  install -m 0644 "${HOST_ROOT}/conf/sysctl/99-doombox.conf" /etc/sysctl.d/99-doombox.conf
  if doombox_in_container; then
    log "Skipping sysctl apply in container (kernel keys often read-only)"
    return 0
  fi
  sysctl --system >/dev/null || sysctl -p /etc/sysctl.d/99-doombox.conf || true
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-docker) SKIP_DOCKER=1; shift ;;
      --force) FORCE=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown arg: $1" ;;
    esac
  done

  require_root
  assert_debian_bookworm
  doombox_assert_supported_arch
  log "Architecture: $(doombox_dpkg_arch) (amd64 + arm64 supported)"
  apt_base_packages
  configure_hostname
  install_sysctl

  "${HOST_ROOT}/scripts/configure-users.sh"
  "${HOST_ROOT}/scripts/configure-storage.sh"
  "${HOST_ROOT}/scripts/configure-mdns.sh"
  "${HOST_ROOT}/scripts/install-stub-http.sh"

  if [[ "${SKIP_DOCKER}" -eq 0 ]]; then
    "${HOST_ROOT}/scripts/install-docker.sh"
  else
    log "Skipping Docker (--skip-docker)"
  fi

  log "Bootstrap complete."
  log "Non-tech: open http://box.local — no Linux password needed."
  log "Tech remote admin: sudo doombox-enable-operator --help"
  log "Smoke: sudo ${HOST_ROOT}/scripts/smoke-check.sh"
}

main "$@"
