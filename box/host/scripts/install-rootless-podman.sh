#!/usr/bin/env bash
# Optional maker tooling: rootless Podman (no docker group, no root daemon for apps).
set -euo pipefail

ADMIN_USER="${DOOMBOX_ADMIN_USER:-heyeddi}"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"
getent passwd "${ADMIN_USER}" >/dev/null || die "user ${ADMIN_USER} missing — bootstrap first"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y podman uidmap slirp4netns fuse-overlayfs

home="$(getent passwd "${ADMIN_USER}" | cut -d: -f6)"
install -d -m 0755 -o "${ADMIN_USER}" -g "${ADMIN_USER}" "${home}/.config/containers"

# Enable lingering so user services can run without interactive login (optional)
if command -v loginctl >/dev/null 2>&1; then
  loginctl enable-linger "${ADMIN_USER}" 2>/dev/null || true
fi

# Ensure subuid/subgid
if ! grep -q "^${ADMIN_USER}:" /etc/subuid 2>/dev/null; then
  echo "${ADMIN_USER}:100000:65536" >> /etc/subuid
fi
if ! grep -q "^${ADMIN_USER}:" /etc/subgid 2>/dev/null; then
  echo "${ADMIN_USER}:100000:65536" >> /etc/subgid
fi

# Never add docker group
if getent group docker >/dev/null && id -nG "${ADMIN_USER}" | grep -qw docker; then
  gpasswd -d "${ADMIN_USER}" docker || true
fi

cat > "${home}/.config/containers/containers.conf" <<'EOF'
[engine]
cgroup_manager = "systemd"
events_logger = "file"
EOF
chown -R "${ADMIN_USER}:${ADMIN_USER}" "${home}/.config/containers"

log "Rootless Podman installed for ${ADMIN_USER}"
log "As ${ADMIN_USER}: podman info"
log "Host Docker (appliance stack) stays root/systemd — makers do not get docker group"
