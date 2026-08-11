#!/usr/bin/env bash
# Unlock maker account and optionally enable remote SSH (tech users only).
# Does NOT grant full sudo or docker. Does NOT open password-based SSH.
#
# Run as root on the local console (not via maker sudoers).
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

ADMIN_USER="${DOOMBOX_ADMIN_USER:-heyeddi}"
STATE_DIR="/var/lib/doombox"
REMOTE_ADMIN_MARKER="${STATE_DIR}/remote-admin-enabled"
SET_PASSWORD=0
ENABLE_SSH=0
PUBKEY="${DOOMBOX_ADMIN_SSH_PUBKEY:-}"
PUBKEY_FILE=""

usage() {
  cat <<'EOF'
Usage: sudo doombox-enable-operator [options]

  --set-password         Set/unlock a console password for heyeddi (local login)
  --pubkey 'ssh-ed25519 …'   Install SSH public key for heyeddi
  --pubkey-file PATH     Install pubkey from file
  --enable-ssh           Start & enable sshd (requires a pubkey already or via --pubkey*)
  --help                 This help

Examples:
  # Tech: console password only (still no SSH, still no full root)
  sudo doombox-enable-operator --set-password

  # Tech: remote shell via key (recommended). Still no docker / no ALL sudo.
  sudo doombox-enable-operator --pubkey "$(cat ~/.ssh/id_ed25519.pub)" --enable-ssh

Notes:
  - Maker gets limited sudoers (claim/label/reset/disable-remote only) + PASSWD.
  - Those tools refuse SSH. Stolen credentials ≠ factory reset over the network.
  - SSH password login stays OFF. Remote access is pubkey-only.
  - For packages/libs: use user-space installs — see ~/README-MAKER.txt
EOF
}

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root (local console). Maker sudoers does not include this command."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --set-password) SET_PASSWORD=1; shift ;;
    --enable-ssh) ENABLE_SSH=1; shift ;;
    --pubkey) PUBKEY="${2:-}"; shift 2 ;;
    --pubkey-file) PUBKEY_FILE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown arg: $1" ;;
  esac
done

getent passwd "${ADMIN_USER}" >/dev/null || die "maker user ${ADMIN_USER} missing — run bootstrap first"

# Defense in depth: never leave maker in docker / sudo group
for g in sudo docker; do
  if getent group "${g}" >/dev/null && id -nG "${ADMIN_USER}" | grep -qw "${g}"; then
    log "Removing ${ADMIN_USER} from ${g} (not permitted for makers)"
    gpasswd -d "${ADMIN_USER}" "${g}" || true
  fi
done

if [[ -n "${PUBKEY_FILE}" ]]; then
  [[ -f "${PUBKEY_FILE}" ]] || die "pubkey file not found: ${PUBKEY_FILE}"
  PUBKEY="$(tr -d '\n' < "${PUBKEY_FILE}")"
fi

install_pubkey() {
  doombox_install_authorized_key "${ADMIN_USER}" "${PUBKEY}" \
    || die "failed to install SSH pubkey for ${ADMIN_USER}"
  log "Installed SSH pubkey for ${ADMIN_USER}"
}

set_password_interactive() {
  local pass confirm
  log "Set console password for ${ADMIN_USER} (local login + limited sudo PASSWD — not for SSH)"
  while true; do
    read -r -s -p "New password: " pass
    printf '\n'
    read -r -s -p "Confirm: " confirm
    printf '\n'
    [[ -n "${pass}" ]] || { printf 'Empty password not allowed.\n' >&2; continue; }
    [[ "${pass}" == "${confirm}" ]] || { printf 'Mismatch.\n' >&2; continue; }
    break
  done
  usermod --unlock "${ADMIN_USER}" >/dev/null 2>&1 || true
  printf '%s:%s\n' "${ADMIN_USER}" "${pass}" | chpasswd
  log "Password set; account unlocked for console + limited sudo"
}

has_authorized_keys() {
  local home aks
  home="$(getent passwd "${ADMIN_USER}" | cut -d: -f6)"
  aks="${home}/.ssh/authorized_keys"
  [[ -s "${aks}" ]]
}

if [[ "${SET_PASSWORD}" -eq 0 && -z "${PUBKEY}" && "${ENABLE_SSH}" -eq 0 ]]; then
  usage
  die "specify --set-password and/or --pubkey/--pubkey-file and/or --enable-ssh"
fi

if [[ -n "${PUBKEY}" ]]; then
  [[ "${PUBKEY}" == ssh-* ]] || [[ "${PUBKEY}" == ecdsa-* ]] || die "pubkey does not look like an OpenSSH public key"
  install_pubkey
  usermod --unlock "${ADMIN_USER}" >/dev/null 2>&1 || true
  if [[ "${SET_PASSWORD}" -eq 0 ]]; then
    passwd -l "${ADMIN_USER}" >/dev/null 2>&1 || true
    log "Password hash locked (SSH will be pubkey-only; limited sudo needs --set-password for PASSWD prompts)"
  fi
fi

if [[ "${SET_PASSWORD}" -eq 1 ]]; then
  set_password_interactive
fi

if [[ "${ENABLE_SSH}" -eq 1 ]]; then
  has_authorized_keys || die "refusing to enable sshd without an authorized_keys entry for ${ADMIN_USER}"
  if ! sshd -t 2>/dev/null; then
    die "sshd config invalid — fix /etc/ssh/sshd_config.d/doombox.conf"
  fi
  systemctl enable --now ssh 2>/dev/null || systemctl enable --now sshd
  systemctl reload ssh 2>/dev/null || systemctl reload sshd 2>/dev/null || true
  install -d -m 0755 "${STATE_DIR}"
  touch "${REMOTE_ADMIN_MARKER}"
  chmod 644 "${REMOTE_ADMIN_MARKER}"
  log "sshd enabled. Remote login: ssh ${ADMIN_USER}@box.local (pubkey only, no full root)"
else
  log "sshd left unchanged (use --enable-ssh to expose remote shell)"
fi

log "Maker rights: user-space installs + limited host tools. See /home/${ADMIN_USER}/README-MAKER.txt"
log "Disable remote shell later: sudo doombox-disable-remote-admin (local console)"
