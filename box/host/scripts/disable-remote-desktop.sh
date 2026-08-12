#!/usr/bin/env bash
# Stop browser remote desktop compose profile.
set -euo pipefail

HOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOX_ROOT="$(cd "${HOST_ROOT}/.." && pwd)"
# shellcheck source=lib/host-env.sh
source "${HOST_ROOT}/scripts/lib/host-env.sh"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "run as root"
command -v docker >/dev/null || die "docker required"

cd "${BOX_ROOT}"
[[ -f .env ]] || cp .env.example .env

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
data["remote_desktop"] = False
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
p.chmod(0o600)
PY

log "Stopping remote-desktop"
docker compose -f compose/docker-compose.yml --env-file .env --profile remote-desktop stop remote-desktop || true

log "Remote desktop stopped."
