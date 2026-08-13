#!/usr/bin/env bash
# Install a .deb (VS Code / Cursor) inside linuxserver webtop.
# Apt's _apt user cannot read ~/Downloads — copy to /tmp first.
# Also caches the .deb under ~/cache/debs so a container recreate can reinstall.
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run as desktop user (abc), not root. Example:"
  echo "  $0 ~/Downloads/code_*.deb"
  exit 1
fi

shopt -s nullglob
files=("$@")
if [[ ${#files[@]} -eq 0 ]]; then
  echo "Usage: $0 ~/Downloads/code_*.deb"
  echo "   or: $0 ~/Downloads/cursor*.deb"
  exit 1
fi

deb=""
for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue
  deb="$f"
  break
done
[[ -n "${deb}" ]] || { echo "No .deb file found: $*"; exit 1; }

tmp="/tmp/$(basename "${deb}")"
cache="${HOME}/cache/debs"
mkdir -p "${cache}"

echo "==> Copying $(basename "${deb}") to /tmp for apt"
cp -f "${deb}" "${tmp}"
chmod a+r "${tmp}"

echo "==> Caching copy in ${cache} (survives desktop recreate)"
cp -f "${deb}" "${cache}/$(basename "${deb}")"
chmod a+r "${cache}/$(basename "${deb}")"

echo "==> Installing (sudo apt)"
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${tmp}"
echo "==> Done. Open it from the applications menu (or: code   /   cursor)."
