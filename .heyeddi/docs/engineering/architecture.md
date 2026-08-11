# Architecture

**Last updated:** 2026-08-11

HeyEddi Doomsday Box — on-device appliance software under `box/`.

## Stack

See `.heyeddi/stack.json`. Summary:

| Layer | Tech | Path |
|-------|------|------|
| Host OS | Debian 12 bootstrap | `box/host/scripts/` |
| Containers | Docker Compose v2 | `box/compose/` |
| API | FastAPI 0.2.x (Python 3.12) | `box/api/app/main.py` |
| Dashboard | Vue 3 + PrimeVue + Vite | `box/dashboard/src/` |
| Gateway | nginx reverse proxy | `box/compose/gateway/` |

Published on appliance at `http://box.local` / `http://doomsday.local` (dual skin, same API).

## Module map

| Layer | Location | Responsibility |
|-------|----------|----------------|
| API routes | `box/api/app/main.py` | Claim, auth, status, operator read-only panel |
| Dashboard views | `box/dashboard/src/views/` | Setup, Login, Home, Settings |
| Router guards | `box/dashboard/src/router.ts` | Redirect unclaimed → `/setup`; authed gate |
| API client | `box/dashboard/src/api.ts` | `fetch` + cookies; no PIN over HTTP |
| Host bootstrap | `box/host/scripts/bootstrap.sh` | Users, mDNS, nginx stub, Docker |
| Host tools | `/usr/local/sbin/doombox-*` | Physical-console-only sensitive ops |

## Data flow (claim ceremony)

1. API startup mints claim PIN → hash in `setup-claim.json`, plaintext in `SETUP_PIN.txt` (host only).
2. User reads PIN from sticker/console/kiosk — **never** from browser API.
3. `POST /api/setup` with PIN + admin password → state file, session cookie, PIN deleted.
4. Post-claim: cookie auth for `/api/me`, `/api/operator-status`, dashboard Home/Settings.

## Security boundaries

- No `/api/factory-reset` — factory reset is physical console only.
- CORS: `allow_origin_regex` for local hostnames only (not `*` + credentials).
- Secrets: PBKDF2-HMAC-SHA256 (600k rounds) for PIN and admin password.
- Maker user (`heyeddi`): limited sudoers, no docker group, SSH off by default.

## Test layers

```
┌─────────────────────────────────────────────────────────┐
│ CI (GitHub Actions) — every PR                          │
│  dashboard: typecheck + build + vitest                  │
│  api: pytest (TestClient, temp DOOMBOX_STORAGE)         │
│  host-smoke: Debian container bootstrap                 │
│  compose-smoke: gateway claim ceremony                  │
├─────────────────────────────────────────────────────────┤
│ Hardware (factory / dev bench) — not CI                 │
│  smoke-check.sh (full): mDNS, SSH policy, docker info   │
│  label export/print, HDMI kiosk                         │
└─────────────────────────────────────────────────────────┘
```

Entrypoints: `box/test/run-software-tests.sh`, `.github/workflows/ci.yml`.

## Boundaries (SOLID)

- Views thin; claim/auth logic lives in API only.
- Host scripts idempotent; `set -euo pipefail`.
- Storage root: `/mnt/storage/` (compose maps `STORAGE_ROOT`).

## What not to build

See `reuse-catalog.md`. Do not add HTTP endpoints for factory reset, claim PIN display, or remote operator enable.
