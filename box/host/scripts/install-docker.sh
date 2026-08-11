#!/usr/bin/env bash
# Install Docker Engine from Docker's official Debian repo (idempotent).
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"

export DEBIAN_FRONTEND=noninteractive

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  log "Docker already installed and responding"
else
  log "Installing Docker Engine (official apt repo)"
  apt-get update -y
  apt-get install -y --no-install-recommends ca-certificates curl gnupg

  install -m 0755 -d /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
  fi

  # shellcheck source=/dev/null
  . /etc/os-release
  ARCH="$(doombox_dpkg_arch)"
  case "${ARCH}" in
    amd64|arm64) ;;
    *) die "Docker Engine apt repo: unsupported arch ${ARCH} (need amd64 or arm64)" ;;
  esac
  CODENAME="${VERSION_CODENAME:-bookworm}"
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian %s stable\n' \
    "${ARCH}" "${CODENAME}" > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y --no-install-recommends \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
fi

systemctl enable --now docker

# Prefer Docker data under unified storage root when empty/new.
DOCKER_ROOT="/mnt/storage/docker"
install -d -m 0711 "${DOCKER_ROOT}"
DAEMON_JSON="/etc/docker/daemon.json"
if [[ ! -f "${DAEMON_JSON}" ]]; then
  log "Writing ${DAEMON_JSON} (data-root ${DOCKER_ROOT})"
  cat > "${DAEMON_JSON}" <<EOF
{
  "data-root": "${DOCKER_ROOT}",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
  systemctl restart docker
elif ! grep -q "${DOCKER_ROOT}" "${DAEMON_JSON}"; then
  log "WARNING: ${DAEMON_JSON} exists without data-root ${DOCKER_ROOT}; leaving as-is"
fi

# Keep product accounts OUT of docker (docker group ≈ root).
# Compose/stack is operated by root/systemd, not by the maker login.
SERVICE_USER="${DOOMBOX_SERVICE_USER:-doombox}"
ADMIN_USER="${DOOMBOX_ADMIN_USER:-heyeddi}"
if getent group docker >/dev/null; then
  for u in "${SERVICE_USER}" "${ADMIN_USER}"; do
    if getent passwd "${u}" >/dev/null && id -nG "${u}" | grep -qw docker; then
      gpasswd -d "${u}" docker || true
      log "Removed ${u} from docker group (required)"
    fi
  done
fi

log "Docker ready: $(docker --version)"
