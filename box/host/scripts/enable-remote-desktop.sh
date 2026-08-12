#!/usr/bin/env bash
# Start browser remote desktop (webtop) via compose profile.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOX_ROOT="$(cd "${HOST_ROOT}/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"
command -v docker >/dev/null || die "docker required"

install -d -m 0755 /mnt/storage/compose
install -d -m 0755 /mnt/storage/remote-desktop
install -d -m 0755 /mnt/storage/workspace

cd "${BOX_ROOT}"
[[ -f .env ]] || cp .env.example .env

# Mark desired state for the dashboard
python3 - <<'PY' || true
import json
from pathlib import Path
p = Path("/mnt/storage/compose/apps.json")
data = {}
if p.is_file():
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except Exception:
        data = {}
data["remote_desktop"] = True
p.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
p.chmod(0o600)
PY

log "Starting remote-desktop profile (pull may take a few minutes)"
docker compose -f compose/docker-compose.yml --env-file .env --profile remote-desktop up -d remote-desktop

log "Desktop starting. Sign in to the hub, then open http://box.local/desktop/"
log "Install Cursor inside the desktop when you need the Cursor agent."
