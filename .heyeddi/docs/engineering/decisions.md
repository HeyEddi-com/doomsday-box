# Engineering decisions

**Last updated:** 2026-08-11

Engineering ADRs: separate from the **Design Decision log** in `.heyeddi/design.md`.

### 2026-08-11: Layered software tests (CI vs hardware)

**Context:** Stage-1 stack needs regression tests for claim security, host bootstrap, and compose integration without requiring N100 hardware on every PR.

**Decision:** Four CI jobs — dashboard (typecheck/build/vitest), API (pytest with isolated temp storage), host container smoke (existing Debian Docker harness), compose smoke (gateway + claim ceremony). Hardware-only checks (mDNS resolve, SSH policy on systemd) stay in `smoke-check.sh` full mode.

**Consequences:** Fast PR feedback (~2–5 min). Factory still runs full `smoke-check.sh` on real hardware per `box/host/GOLDEN.md`. Compose smoke reads claim PIN via `docker exec` because API writes `SETUP_PIN.txt` mode 600.

### 2026-08-11: API secret hashing

**Context:** HeyEddi CI flagged single-round SHA-256 for PIN and admin passwords.

**Decision:** PBKDF2-HMAC-SHA256 with 600,000 iterations; salt per secret in state files.

**Consequences:** Slightly slower login/setup (~sub-second on N100). Invalidates any dev hashes from pre-change builds.

### 2026-08-11: CORS for local-only appliance

**Context:** Starlette rejects `allow_origins=["*"]` with `allow_credentials=True`.

**Decision:** `allow_origin_regex` matching `box.local`, `doomsday.local`, `*.heyeddi.local`, `localhost`, `127.0.0.1`.

**Consequences:** Dashboard session cookies work only from legitimate local origins.
