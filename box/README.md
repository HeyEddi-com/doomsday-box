# `box/` — on-device Doomsday Box software

**Status:** stage-1 hub + optional remote desktop; USB golden image next (`host/GOLDEN.md`)  
**Arches:** amd64 + arm64 from day one  

## Layout

| Path | Role |
|------|------|
| [`host/`](./host/) | Debian bootstrap, users, mDNS, nginx |
| [`compose/`](./compose/) | Docker Compose (api, dashboard, gateway) |
| [`api/`](./api/) | FastAPI |
| [`dashboard/`](./dashboard/) | Vue + PrimeVue shell (hub / doomsday skins) |
| [`images/`](./images/) | Multi-arch Dockerfiles |
| [`.env.example`](./.env.example) | Compose resource limits + ports |

## Quick start (dev workstation)

```bash
cd box
cp .env.example .env
mkdir -p /tmp/doombox-storage/compose
chmod -R a+rwx /tmp/doombox-storage   # api container user needs write access
STORAGE_ROOT=/tmp/doombox-storage docker compose -f compose/docker-compose.yml --env-file .env up -d --build
# open http://127.0.0.1:8080/
```

## Software tests (CI / local)

```bash
# Fast path: dashboard + API unit tests only
cd box/dashboard && npm ci && npm run typecheck && npm test
cd box/api && pip install -r requirements-dev.txt && pytest -q

# Full software gate (includes Docker smokes)
./box/test/run-software-tests.sh

# Skip container smokes when Docker is unavailable
DOOMBOX_SKIP_CONTAINER_TESTS=1 DOOMBOX_SKIP_COMPOSE_TESTS=1 ./box/test/run-software-tests.sh
```

GitHub Actions runs the same gates in `.github/workflows/ci.yml`.

## On appliance (after host bootstrap)

```bash
cd /path/to/heyeddi-doomsday-box/box/host
sudo ./scripts/enable-compose-stack.sh
# http://box.local/  → dashboard + /api

# Browser remote desktop (Cursor host) — optional
sudo ./scripts/enable-remote-desktop.sh
# sign in, then http://box.local/desktop/
```

See [`.heyeddi/docs/product/remote-desktop.md`](../.heyeddi/docs/product/remote-desktop.md).

## Host-only smoke (no compose)

```bash
./host/test/run-container-smoke.sh
```
