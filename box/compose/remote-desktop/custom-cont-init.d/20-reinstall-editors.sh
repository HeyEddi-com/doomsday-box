#!/usr/bin/env bash
# Restore extra apt software after webtop container recreate.
set -euo pipefail

if [[ -x /usr/local/bin/doombox-restore-apt-cache ]]; then
  /usr/local/bin/doombox-restore-apt-cache || true
elif [[ -x /usr/local/share/doombox-desktop-help/doombox-restore-apt-cache.sh ]]; then
  /usr/local/share/doombox-desktop-help/doombox-restore-apt-cache.sh || true
fi
