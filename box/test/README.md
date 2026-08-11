# Software tests

Automated tests for the on-device stack (no real hardware required).

| Script | What it runs |
|--------|----------------|
| [`run-software-tests.sh`](./run-software-tests.sh) | Dashboard + API + host container + compose smokes |
| [`run-compose-smoke.sh`](./run-compose-smoke.sh) | `docker compose up` + claim ceremony via gateway |

Host-only bootstrap smoke lives in [`../host/test/`](../host/test/).

## Local prerequisites

- Node 22+ and `npm ci` in `box/dashboard`
- Python **3.12** and `pip install -r requirements-dev.txt` in `box/api`
- Docker for container smokes

Set `DOOMBOX_SKIP_CONTAINER_TESTS=1` and/or `DOOMBOX_SKIP_COMPOSE_TESTS=1` to skip Docker jobs locally.
