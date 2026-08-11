#!/usr/bin/env bash
# Post-bootstrap smoke checks for DoomBox host v0.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

CONTAINER=0
SKIP_DOCKER_CHECK=0
FAILS=0

usage() {
  cat <<'EOF'
Usage: sudo ./scripts/smoke-check.sh [--container]

  --container  Soften checks for Docker-based smoke (no systemd / nested Docker / mDNS)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --container) CONTAINER=1; SKIP_DOCKER_CHECK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'unknown arg: %s\n' "$1" >&2; usage; exit 1 ;;
  esac
done

if doombox_in_container; then
  CONTAINER=1
  SKIP_DOCKER_CHECK=1
fi

pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*"; FAILS=$((FAILS + 1)); }
skip() { printf 'SKIP  %s\n' "$*"; }

if [[ "${EUID}" -ne 0 ]]; then
  printf 'NOTE: some checks are stronger as root (sudo %s)\n' "$0"
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  if [[ "${ID:-}" == "debian" && "${VERSION_ID:-}" == "12" ]]; then
    pass "Debian 12 host"
  else
    fail "expected Debian 12 (got ${ID:-?} ${VERSION_ID:-?})"
  fi
else
  fail "/etc/os-release missing"
fi

ARCH="$(doombox_dpkg_arch)"
case "${ARCH}" in
  amd64|arm64) pass "architecture ${ARCH} (supported)" ;;
  *) fail "unsupported architecture ${ARCH} (need amd64 or arm64)" ;;
esac

if [[ "$(hostname)" == "box" ]] || [[ "$(tr -d ' \n' </etc/hostname 2>/dev/null || true)" == "box" ]]; then
  pass "hostname is box"
else
  fail "hostname should be box (got $(hostname); /etc/hostname=$(cat /etc/hostname 2>/dev/null || echo '?'))"
fi

if [[ -d /mnt/storage/docker && -d /mnt/storage/media ]]; then
  pass "/mnt/storage layout"
else
  fail "/mnt/storage layout incomplete"
fi

REMOTE_ADMIN_MARKER="/var/lib/doombox/remote-admin-enabled"
ssh_listening() {
  if doombox_has_systemd; then
    systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet ssh.service 2>/dev/null
    return $?
  fi
  ss -lntp 2>/dev/null | grep -qE ':22\s' || netstat -lntp 2>/dev/null | grep -q ':22 '
}

if [[ -f "${REMOTE_ADMIN_MARKER}" ]]; then
  if ssh_listening; then
    pass "ssh active (remote admin enabled)"
  else
    fail "remote admin marker set but ssh not listening"
  fi
else
  if ssh_listening; then
    fail "ssh should be off by default (non-tech safe)"
  else
    pass "ssh inactive (default — no remote shell)"
  fi
fi

if [[ "${CONTAINER}" -eq 1 ]]; then
  if pgrep -x avahi-daemon >/dev/null 2>&1 || pgrep -f avahi-daemon >/dev/null 2>&1; then
    pass "avahi-daemon process (container)"
  else
    skip "avahi-daemon (optional in container smoke)"
  fi
  skip "doombox-mdns-alias systemd unit (no systemd in slim container)"
else
  if systemctl is-active --quiet avahi-daemon; then
    pass "avahi-daemon active"
  else
    fail "avahi-daemon not active"
  fi
  if systemctl is-enabled --quiet doombox-mdns-alias.service 2>/dev/null \
    || systemctl is-active --quiet doombox-mdns-alias.service 2>/dev/null; then
    pass "doombox-mdns-alias unit present"
  else
    fail "doombox-mdns-alias unit missing/inactive"
  fi
fi

if curl -fsS -o /dev/null http://127.0.0.1/; then
  pass "HTTP stub responds on :80"
else
  fail "HTTP stub not responding on :80"
fi

if [[ "${SKIP_DOCKER_CHECK}" -eq 1 ]]; then
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    pass "docker info OK"
  else
    skip "docker (bootstrap --skip-docker / container default)"
  fi
else
  if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
      pass "docker info OK"
    else
      fail "docker installed but docker info failed (group/permissions?)"
    fi
  else
    fail "docker not installed"
  fi
fi

if [[ "${CONTAINER}" -eq 1 ]]; then
  skip "avahi-resolve box.local / doomsday.local (use real hardware/VM)"
else
  if command -v avahi-resolve-host-name >/dev/null 2>&1; then
    if avahi-resolve-host-name -n box.local >/dev/null 2>&1; then
      pass "avahi resolves box.local"
    else
      fail "avahi cannot resolve box.local (is avahi running?)"
    fi
    if avahi-resolve-host-name -n doomsday.local >/dev/null 2>&1; then
      pass "avahi resolves doomsday.local"
    else
      fail "avahi cannot resolve doomsday.local (alias unit?)"
    fi
  else
    fail "avahi-resolve-host-name missing"
  fi
fi

ADMIN_USER="${DOOMBOX_ADMIN_USER:-heyeddi}"
SERVICE_USER="${DOOMBOX_SERVICE_USER:-doombox}"

if getent passwd "${ADMIN_USER}" >/dev/null; then
  pass "maker user ${ADMIN_USER} exists"
  if id -nG "${ADMIN_USER}" | grep -qw sudo; then
    fail "${ADMIN_USER} must NOT be in sudo group (use limited sudoers.d)"
  else
    pass "${ADMIN_USER} not in sudo group"
  fi
  if id -nG "${ADMIN_USER}" | grep -qw docker; then
    fail "${ADMIN_USER} must NOT be in docker group"
  else
    pass "${ADMIN_USER} not in docker group"
  fi
  if [[ -f /etc/sudoers.d/doombox-operator ]] && grep -q "DOOMBOX_HOST_TOOLS" /etc/sudoers.d/doombox-operator; then
    pass "limited sudoers doombox-operator present"
  else
    fail "limited sudoers /etc/sudoers.d/doombox-operator missing"
  fi
else
  fail "maker user ${ADMIN_USER} missing"
fi

if getent passwd "${SERVICE_USER}" >/dev/null; then
  shell="$(getent passwd "${SERVICE_USER}" | cut -d: -f7)"
  if [[ "${shell}" == "/usr/sbin/nologin" || "${shell}" == "/bin/false" ]]; then
    pass "service user ${SERVICE_USER} has nologin shell"
  else
    fail "service user ${SERVICE_USER} shell should be nologin (got ${shell})"
  fi
  if id -nG "${SERVICE_USER}" | grep -qw docker; then
    fail "${SERVICE_USER} must NOT be in docker group"
  else
    pass "${SERVICE_USER} not in docker group"
  fi
else
  fail "service user ${SERVICE_USER} missing"
fi

if [[ -f /etc/ssh/sshd_config.d/doombox.conf ]] && grep -q "DenyUsers ${SERVICE_USER}" /etc/ssh/sshd_config.d/doombox.conf; then
  pass "sshd DenyUsers ${SERVICE_USER}"
else
  fail "sshd DenyUsers ${SERVICE_USER} not configured"
fi

if [[ -f /etc/ssh/sshd_config.d/doombox.conf ]] && grep -qE '^PasswordAuthentication\s+no' /etc/ssh/sshd_config.d/doombox.conf; then
  pass "sshd PasswordAuthentication no"
else
  fail "sshd PasswordAuthentication should be no"
fi

if [[ ! -f "${REMOTE_ADMIN_MARKER}" ]]; then
  if passwd -S "${ADMIN_USER}" 2>/dev/null | grep -q ' L '; then
    pass "${ADMIN_USER} password locked (safe default)"
  elif [[ "${EUID}" -eq 0 ]] && grep -E "^${ADMIN_USER}:" /etc/shadow | grep -qE '^[^:]+:[!*]'; then
    pass "${ADMIN_USER} password locked (shadow)"
  else
    fail "${ADMIN_USER} should be password-locked by default"
  fi
fi

printf '\n'
if [[ "${FAILS}" -eq 0 ]]; then
  printf 'All smoke checks passed.\n'
  exit 0
fi
printf '%s check(s) failed.\n' "${FAILS}"
exit 1
