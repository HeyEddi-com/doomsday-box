#!/usr/bin/env bash
# Shared helpers for host scripts (source from other scripts).
# shellcheck shell=bash

doombox_has_systemd() {
  [[ -d /run/systemd/system ]] && command -v systemctl >/dev/null 2>&1
}

doombox_in_container() {
  [[ "${DOOMBOX_TEST_MODE:-}" == "container" ]] && return 0
  [[ -f /.dockerenv ]] && return 0
  grep -qaE '(docker|lxc|containerd)' /proc/1/cgroup 2>/dev/null && return 0
  return 1
}

doombox_service_enable_now() {
  local unit="$1"
  if doombox_has_systemd; then
    systemctl enable --now "${unit}" 2>/dev/null || systemctl start "${unit}" || true
    return 0
  fi
  # Best-effort without systemd (container smoke).
  case "${unit}" in
    nginx) nginx || service nginx start || true ;;
    avahi-daemon) avahi-daemon -D 2>/dev/null || service avahi-daemon start || true ;;
    ssh|sshd) true ;; # intentionally not started by default
    docker) dockerd >/var/log/dockerd-test.log 2>&1 & ;;
    unattended-upgrades) true ;;
    *) true ;;
  esac
}

doombox_service_disable_now() {
  local unit="$1"
  if doombox_has_systemd; then
    systemctl disable --now "${unit}" 2>/dev/null || systemctl stop "${unit}" 2>/dev/null || true
    return 0
  fi
  case "${unit}" in
    ssh|sshd) service ssh stop 2>/dev/null || true ;;
    *) true ;;
  esac
}

doombox_set_hostname() {
  local name="$1"
  if command -v hostnamectl >/dev/null 2>&1 && hostnamectl set-hostname "${name}" 2>/dev/null; then
    return 0
  fi
  printf '%s\n' "${name}" > /etc/hostname
  if hostname "${name}" 2>/dev/null; then
    return 0
  fi
  # Docker often ignores hostname(1) unless started with --hostname; /etc/hostname is still set.
  if doombox_in_container; then
    printf '==> WARNING: could not change runtime hostname (container); /etc/hostname=%s\n' "${name}"
    return 0
  fi
  return 1
}

# Supported appliance arches from day one (N100/N150 + Pi / Orange Pi DIY).
doombox_assert_supported_arch() {
  local arch
  arch="$(dpkg --print-architecture 2>/dev/null || uname -m)"
  case "${arch}" in
    amd64|arm64) return 0 ;;
    x86_64) return 0 ;; # uname fallback
    aarch64) return 0 ;;
    *)
      printf 'ERROR: unsupported architecture "%s" (need amd64/x86_64 or arm64/aarch64)\n' "${arch}" >&2
      return 1
      ;;
  esac
}

doombox_dpkg_arch() {
  dpkg --print-architecture 2>/dev/null || {
    case "$(uname -m)" in
      x86_64) printf 'amd64\n' ;;
      aarch64|arm64) printf 'arm64\n' ;;
      *) uname -m ;;
    esac
  }
}
