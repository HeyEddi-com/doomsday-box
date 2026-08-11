# Reuse catalog

**Last updated:** 2026-08-11

**DRY rule:** search this file before creating a new component, composable, helper, or test harness.

| Name | Path | Use when |
|------|------|----------|
| API test fixture | `box/api/tests/conftest.py` | `box` fixture: reloads `app.main` with temp `DOOMBOX_STORAGE` |
| Claim PIN helper | `claim_pin(storage)` in conftest | Read minted PIN in pytest (not via HTTP) |
| Router guard tests | `box/dashboard/src/router.test.ts` | Mock `fetchStatus`; vitest + happy-dom |
| Host container smoke | `box/host/test/run-container-smoke.sh` | Debian 12 bootstrap without real hardware |
| Compose stack smoke | `box/test/run-compose-smoke.sh` | Full gateway + claim via curl |
| Full software gate | `box/test/run-software-tests.sh` | Local CI parity |
| Post-bootstrap checks | `box/host/scripts/smoke-check.sh` | On hardware after `bootstrap.sh` |
| Physical console gate | `box/host/scripts/lib/physical-console.sh` | Refuse SSH for PIN/reset/label ops |

## Test patterns

- **API:** set `DOOMBOX_STORAGE` / `DOOMBOX_HOST_STATE` env vars, `importlib.reload(app.main)`, use `TestClient`.
- **Compose smoke:** `chmod a+rwx` storage dir; read PIN via `docker compose exec -T api cat …` (mode 600 on host mount).
- **Skip Docker locally:** `DOOMBOX_SKIP_CONTAINER_TESTS=1 DOOMBOX_SKIP_COMPOSE_TESTS=1`.

## Anti-patterns

- Asserting claim PIN via HTTP — forbidden by design.
- `allow_origins=["*"]` with `allow_credentials=True` — Starlette crashes.
- Reading `SETUP_PIN.txt` from host path in compose smoke without exec — permission denied.
