#!/usr/bin/env bash
# After webtop recreate: reinstall extra apt packages from persisted cache.
set -uo pipefail

DEB_DIR="/config/cache/debs"
EXTRA="/config/cache/apt/extra-packages.txt"

mkdir -p "${DEB_DIR}" /config/cache/apt /config/cache/apt-archives/partial

install_deb_if_missing() {
  local deb="$1"
  [[ -f "${deb}" ]] || return 0
  local pkg
  pkg="$(dpkg-deb -f "${deb}" Package 2>/dev/null || true)"
  [[ -n "${pkg}" ]] || return 0
  if dpkg -s "${pkg}" >/dev/null 2>&1; then
    return 0
  fi
  echo "[doombox] restoring ${pkg} from $(basename "${deb}")"
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${deb}" || \
    echo "[doombox] warning: could not restore ${pkg}"
}

shopt -s nullglob
for deb in "${DEB_DIR}"/*.deb; do
  install_deb_if_missing "${deb}"
done
shopt -u nullglob

if [[ -s "${EXTRA}" ]]; then
  mapfile -t pkgs <"${EXTRA}" || true
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    echo "[doombox] installing extra packages from manifest (${#pkgs[@]})"
    DEBIAN_FRONTEND=noninteractive apt-get update -qq || true
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" || \
      echo "[doombox] warning: some extra packages failed"
  fi
fi

exit 0
