#!/usr/bin/env bash
# Keep persisted apt cache + extra-package manifest up to date.
# Safe to run from apt Post-Invoke or a background loop (root).
set -uo pipefail

CACHE_ROOT="/config/cache"
DEB_DIR="${CACHE_ROOT}/debs"
APT_DIR="${CACHE_ROOT}/apt"
ARCHIVES="${CACHE_ROOT}/apt-archives"
BASELINE="${APT_DIR}/baseline-manual.txt"
CURRENT="${APT_DIR}/current-manual.txt"
EXTRA="${APT_DIR}/extra-packages.txt"

mkdir -p "${DEB_DIR}" "${APT_DIR}" "${ARCHIVES}/partial"
chmod a+rX "${CACHE_ROOT}" "${DEB_DIR}" "${APT_DIR}" "${ARCHIVES}" || true

copy_debs_from() {
  local src="$1"
  [[ -d "${src}" ]] || return 0
  shopt -s nullglob
  local f
  for f in "${src}"/*.deb; do
    [[ -f "${f}" ]] || continue
    cp -n "${f}" "${DEB_DIR}/$(basename "${f}")" 2>/dev/null || true
  done
  shopt -u nullglob
}

copy_debs_from /var/cache/apt/archives
copy_debs_from "${ARCHIVES}"

if command -v apt-mark >/dev/null 2>&1; then
  apt-mark showmanual 2>/dev/null | sort -u >"${CURRENT}.tmp" || true
  if [[ -s "${CURRENT}.tmp" ]]; then
    mv -f "${CURRENT}.tmp" "${CURRENT}"
  else
    rm -f "${CURRENT}.tmp"
  fi
fi

if [[ -s "${CURRENT}" && ! -s "${BASELINE}" ]]; then
  cp -f "${CURRENT}" "${BASELINE}"
fi

: >"${EXTRA}.tmp"
if [[ -s "${BASELINE}" && -s "${CURRENT}" ]]; then
  comm -13 "${BASELINE}" "${CURRENT}" >>"${EXTRA}.tmp" || true
fi
# Cached .debs are always restore targets (covers baseline taken after first install).
shopt -s nullglob
for deb in "${DEB_DIR}"/*.deb; do
  pkg="$(dpkg-deb -f "${deb}" Package 2>/dev/null || true)"
  [[ -n "${pkg}" ]] && printf '%s\n' "${pkg}" >>"${EXTRA}.tmp"
done
shopt -u nullglob
if [[ -s "${EXTRA}.tmp" ]]; then
  sort -u "${EXTRA}.tmp" -o "${EXTRA}"
else
  : >"${EXTRA}"
fi
rm -f "${EXTRA}.tmp"

# Download extra packages not yet in the deb cache (offline restore later).
if [[ -s "${EXTRA}" ]] && command -v apt-get >/dev/null 2>&1; then
  local_n=0
  while IFS= read -r pkg || [[ -n "${pkg}" ]]; do
    [[ -n "${pkg}" ]] || continue
    shopt -s nullglob
    existing=("${DEB_DIR}/${pkg}_"*.deb "${DEB_DIR}/${pkg}"*.deb)
    shopt -u nullglob
    if [[ ${#existing[@]} -gt 0 && -f "${existing[0]}" ]]; then
      continue
    fi
    local_n=$((local_n + 1))
    if [[ "${local_n}" -gt 15 ]]; then
      break
    fi
    (cd "${ARCHIVES}" && apt-get download "${pkg}" -qq) || true
  done <"${EXTRA}"
  copy_debs_from "${ARCHIVES}"
fi

chmod a+r "${DEB_DIR}"/*.deb 2>/dev/null || true
exit 0
