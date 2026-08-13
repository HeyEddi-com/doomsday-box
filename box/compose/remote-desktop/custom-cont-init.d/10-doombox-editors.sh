#!/usr/bin/env bash
# linuxserver custom init (root): helpers, apt cache paths, baseline snapshot.
set -euo pipefail

HELP="/usr/local/share/doombox-desktop-help"

mkdir -p \
  /config/Downloads /config/Desktop /config/workspace /config/bin \
  /config/cache/debs /config/cache/apt /config/cache/apt-archives/partial
chmod a+rX /config /config/Downloads /config/Desktop /config/workspace \
  /config/cache /config/cache/debs /config/cache/apt /config/cache/apt-archives || true

if [[ -d "${HELP}" ]]; then
  install -m 0755 "${HELP}/install-linux-editor.sh" /config/bin/install-linux-editor.sh
  install -m 0644 "${HELP}/INSTALL-EDITORS.txt" /config/Desktop/INSTALL-EDITORS.txt
  install -m 0644 "${HELP}/99doombox-apt" /etc/apt/apt.conf.d/99doombox-apt
  install -m 0755 "${HELP}/doombox-sync-apt-cache.sh" /usr/local/bin/doombox-sync-apt-cache
  install -m 0755 "${HELP}/doombox-restore-apt-cache.sh" /usr/local/bin/doombox-restore-apt-cache
fi

if [[ -x /usr/local/bin/doombox-sync-apt-cache ]]; then
  /usr/local/bin/doombox-sync-apt-cache || true
fi

if id abc >/dev/null 2>&1; then
  chown -R abc:abc /config/Desktop /config/bin /config/workspace /config/Downloads /config/cache || true
  chmod a+rX /config/Downloads /config/cache/debs /config/cache/apt-archives || true
fi
