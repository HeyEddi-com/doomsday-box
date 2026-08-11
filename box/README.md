# `box/` — on-device Doomsday Box software

**Status:** stage-1 usable stack (host + API + dashboard)  
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
# use a local storage dir for compose state
mkdir -p /tmp/doombox-storage/compose
STORAGE_ROOT=/tmp/doombox-storage docker compose -f compose/docker-compose.yml --env-file .env up -d --build
# open http://127.0.0.1:8080/
```

## On appliance (after host bootstrap)

```bash
cd /path/to/heyeddi-doomsday-box/box/host
sudo ./scripts/enable-compose-stack.sh
# http://box.local/  → dashboard + /api
```

## Host-only smoke (no compose)

```bash
./host/test/run-container-smoke.sh
```
