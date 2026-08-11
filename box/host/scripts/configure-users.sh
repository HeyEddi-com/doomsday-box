#!/usr/bin/env bash
# Maker (heyeddi) + locked service account (doombox). Idempotent.
#
# Default (non-tech safe):
#   - heyeddi exists but password-LOCKED (no login until enable-operator)
#   - heyeddi is NOT in sudo or docker groups (docker ≈ root)
#   - limited sudoers: only doombox host tools (PASSWD + physical-console checks)
#   - sshd installed but DISABLED/stopped (no remote shell surface)
#   - Customers use browser on box.local — never need Linux login
#
# Tech path: scripts/enable-operator.sh (console password and/or SSH pubkey)
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"
ADMIN_USER="${DOOMBOX_ADMIN_USER:-heyeddi}"
SERVICE_USER="${DOOMBOX_SERVICE_USER:-doombox}"
STATE_DIR="/var/lib/doombox"
REMOTE_ADMIN_MARKER="${STATE_DIR}/remote-admin-enabled"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"

install -d -m 0755 "${STATE_DIR}"

ensure_service_user() {
  log "Ensuring locked service user '${SERVICE_USER}' (no login, no SSH, no docker group)"
  if ! getent passwd "${SERVICE_USER}" >/dev/null; then
    useradd --system \
      --home-dir "${STATE_DIR}" \
      --create-home \
      --shell /usr/sbin/nologin \
      --user-group \
      --comment "HeyEddi Doomsday Box service account" \
      "${SERVICE_USER}"
  else
    usermod \
      --home "${STATE_DIR}" \
      --shell /usr/sbin/nologin \
      "${SERVICE_USER}" || true
  fi

  passwd -l "${SERVICE_USER}" >/dev/null 2>&1 || true
  usermod --lock "${SERVICE_USER}" >/dev/null 2>&1 || true

  for g in sudo docker adm; do
    if getent group "${g}" >/dev/null && id -nG "${SERVICE_USER}" | grep -qw "${g}"; then
      gpasswd -d "${SERVICE_USER}" "${g}" || true
    fi
  done

  chown -R "${SERVICE_USER}:${SERVICE_USER}" "${STATE_DIR}"
  chmod 0750 "${STATE_DIR}"
}

install_operator_sudoers() {
  local src dest
  src="${HOST_ROOT}/conf/sudoers.d/doombox-operator"
  dest="/etc/sudoers.d/doombox-operator"
  install -d /etc/sudoers.d
  # Drop legacy full-root sudoers from earlier bootstraps
  rm -f "/etc/sudoers.d/doombox-${ADMIN_USER}"
  [[ -f "${src}" ]] || die "missing ${src}"
  sed "s/^heyeddi /${ADMIN_USER} /" "${src}" > "${dest}.tmp"
  chmod 440 "${dest}.tmp"
  if visudo -cf "${dest}.tmp" >/dev/null; then
    mv "${dest}.tmp" "${dest}"
    log "Installed limited sudoers: host tools only (PASSWD), no ALL, no docker"
  else
    rm -f "${dest}.tmp"
    die "sudoers validation failed for ${src}"
  fi
}

install_maker_readme() {
  local home readme tmp
  home="$(getent passwd "${ADMIN_USER}" | cut -d: -f6)"
  doombox_assert_safe_home_dir "${home}" "${ADMIN_USER}" || die "unsafe home for ${ADMIN_USER}"
  readme="${home}/README-MAKER.txt"
  if [[ -f "${HOST_ROOT}/docs/MAKER.txt" ]]; then
    tmp="$(mktemp)"
    install -m 0644 "${HOST_ROOT}/docs/MAKER.txt" "${tmp}"
    chown "${ADMIN_USER}:${ADMIN_USER}" "${tmp}"
    [[ ! -L "${readme}" ]] || { rm -f "${tmp}"; die "refusing to overwrite symlink ${readme}"; }
    mv -fT "${tmp}" "${readme}"
  fi
}

ensure_admin_user() {
  log "Ensuring maker/operator user '${ADMIN_USER}' (locked; no docker; limited sudo)"
  if ! getent passwd "${ADMIN_USER}" >/dev/null; then
    useradd --create-home \
      --shell /bin/bash \
      --user-group \
      --comment "HeyEddi Doomsday Box maker (no full root)" \
      "${ADMIN_USER}"
  else
    usermod --shell /bin/bash "${ADMIN_USER}" || true
  fi

  for g in sudo docker; do
    if getent group "${g}" >/dev/null && id -nG "${ADMIN_USER}" | grep -qw "${g}"; then
      log "Removing ${ADMIN_USER} from group ${g}"
      gpasswd -d "${ADMIN_USER}" "${g}" || true
    fi
  done

  if [[ ! -f "${REMOTE_ADMIN_MARKER}" ]]; then
    passwd -l "${ADMIN_USER}" >/dev/null 2>&1 || true
    usermod --lock "${ADMIN_USER}" >/dev/null 2>&1 || true
    log "Maker '${ADMIN_USER}' is locked (safe default). Non-tech users can ignore it."
  else
    log "Remote admin previously enabled (${REMOTE_ADMIN_MARKER})"
  fi

  install_operator_sudoers
  install_maker_readme
}

install_ssh_policy() {
  log "Installing sshd policy (keys only; service user denied)"
  install -d /etc/ssh/sshd_config.d
  install -m 0644 "${HOST_ROOT}/conf/ssh/sshd_doombox.conf" /etc/ssh/sshd_config.d/doombox.conf
  sed -i "s/^DenyUsers .*/DenyUsers ${SERVICE_USER}/" /etc/ssh/sshd_config.d/doombox.conf
  sed -i "s/^AllowUsers .*/AllowUsers ${ADMIN_USER}/" /etc/ssh/sshd_config.d/doombox.conf
}

disable_sshd_by_default() {
  if [[ -f "${REMOTE_ADMIN_MARKER}" ]]; then
    log "Remote admin marker present — leaving sshd as configured by enable-operator"
    return 0
  fi
  log "Disabling sshd by default (no remote shell until enable-operator)"
  doombox_service_disable_now ssh
  doombox_service_disable_now sshd
}

maybe_preseed_pubkey() {
  if [[ -z "${DOOMBOX_ADMIN_SSH_PUBKEY:-}" ]]; then
    return 0
  fi
  log "Pre-seeding SSH pubkey for ${ADMIN_USER} (still need enable-operator --enable-ssh)"
  doombox_install_authorized_key "${ADMIN_USER}" "${DOOMBOX_ADMIN_SSH_PUBKEY}" \
    || die "failed to install SSH pubkey for ${ADMIN_USER}"
}

install_host_tools() {
  log "Installing host tools (mode 750 root:root; physical-console policy)"
  install -d -m 0755 /usr/local/sbin
  install -d -m 0755 /usr/local/lib/doombox
  install -m 0644 "${HOST_ROOT}/scripts/lib/physical-console.sh" /usr/local/lib/doombox/physical-console.sh
  install -m 0644 "${HOST_ROOT}/scripts/lib/host-env.sh" /usr/local/lib/doombox/host-env.sh

  # enable-operator stays root-only (not in maker sudoers) — bootstrap / console root
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/enable-operator.sh" /usr/local/sbin/doombox-enable-operator
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/disable-remote-admin.sh" /usr/local/sbin/doombox-disable-remote-admin
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/show-setup-pin.sh" /usr/local/sbin/doombox-show-setup-pin
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/factory-reset-claim.sh" /usr/local/sbin/doombox-factory-reset-claim
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/export-claim-label.sh" /usr/local/sbin/doombox-export-claim-label
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/print-claim-label.sh" /usr/local/sbin/doombox-print-claim-label
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/enable-claim-kiosk.sh" /usr/local/sbin/doombox-enable-claim-kiosk
  install -m 0750 -o root -g root "${HOST_ROOT}/scripts/install-rootless-podman.sh" /usr/local/sbin/doombox-install-rootless-podman
  install -m 0755 "${HOST_ROOT}/kiosk/claim_kiosk.py" /usr/local/lib/doombox/claim_kiosk.py
}

ensure_service_user
ensure_admin_user
install_ssh_policy
maybe_preseed_pubkey
disable_sshd_by_default
install_host_tools

log "Users ready: ${ADMIN_USER}=locked maker (limited sudo) · ${SERVICE_USER}=service (no login)"
log "Non-tech: use http://box.local — no Linux password needed"
log "Tech: root doombox-enable-operator --help · see ~${ADMIN_USER}/README-MAKER.txt"
