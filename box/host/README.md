# Host OS — Debian golden path (v0)

**Status:** active  
**Target:** Debian 12 (bookworm)  
**CPU:** **amd64 (x86_64)** primary (N100/N150) **and arm64** DIY from day one — same bootstrap, no arch fork  
**Method:** stock Debian install → idempotent `scripts/bootstrap.sh`  
**Later:** clone a known-good disk to a factory golden `.img` **per arch**

## Staged usable image

| Stage | What you get | Proof |
|-------|--------------|-------|
| **Now** | Host bootstrap + compose API/dashboard/gateway | `./test/run-container-smoke.sh` · `docker compose … up` → :8080 |
| **Next** | Same on sample mini PC / Pi | `RUNBOOK.md` + `enable-compose-stack.sh` |
| **Then** | Apps (cloud/AI/network) + Advanced settings | Compose services |
| **Factory** | Flashable `.img` per arch | `GOLDEN.md` |

One script path for both arches — never “amd64-only until later.”

## What v0 delivers

| Capability | v0 |
|------------|----|
| Headless appliance (no desktop DE) | yes |
| Operator `heyeddi` locked by default (OK forever for non-tech) | yes |
| Opt-in remote admin (pubkey SSH only) | yes — `doombox-enable-operator` |
| Locked service user `doombox` | yes |
| Docker Engine | yes |
| `/mnt/storage/` layout | yes |
| sshd **off** by default | yes |
| mDNS `box.local` + `doomsday.local` | yes |
| Stub HTTP on port 80 | yes (replaced by compose gateway via `enable-compose-stack.sh`) |
| Setup wizard / Compose core | **stage-1** (`/setup`, `/api/status`) |
| Network profiles / Ollama / cloud apps | **not yet** |

## On appliance (after host bootstrap)

```bash
sudo ./scripts/enable-compose-stack.sh
```

Brings up API + dashboard + gateway and points host nginx `:80` at compose `:8080`.

See [RUNBOOK.md](./RUNBOOK.md). Short version:

1. Install Debian 12 (UEFI, wipe disk, SSH server, no desktop).  
2. Copy or clone this repo onto the box (or scp `box/host`).  
3. `sudo ./scripts/bootstrap.sh`  
4. `sudo ./scripts/smoke-check.sh`  
5. From another device: open `http://box.local` or `http://doomsday.local`.

## Layout

```
host/
├── README.md           # this file
├── RUNBOOK.md          # sample PC install
├── GOLDEN.md           # when/how to bake a flashable image
├── scripts/
│   ├── bootstrap.sh    # orchestrator (idempotent)
│   ├── configure-users.sh
│   ├── enable-operator.sh
│   ├── disable-remote-admin.sh
│   ├── install-docker.sh
│   ├── configure-storage.sh
│   ├── configure-mdns.sh
│   ├── publish-doomsday-mdns.sh
│   ├── install-stub-http.sh
│   └── smoke-check.sh
├── conf/
│   ├── sysctl/99-doombox.conf
│   ├── nginx/doombox-stub.conf
│   ├── ssh/sshd_doombox.conf
│   └── systemd/doombox-mdns-alias.service
└── stub/
    └── index.html
```

## Users (locked for v0)

| Account | Role | Login? | Notes |
|---------|------|--------|-------|
| `heyeddi` | Maker | **locked by default** | No `sudo`/`docker` groups; limited host-tool sudoers; tech: `doombox-enable-operator` |
| `doombox` | Service | **no** | nologin, SSH denied, not in `docker` |
| `root` | Break-glass | console only | Full host; enables operator |

Full dual-audience + internet rules: [SECURITY.md](./SECURITY.md). Maker path: [docs/MAKER.txt](./docs/MAKER.txt).

`docker` group membership is root-equivalent — **neither** product account gets it. Compose runs via root/systemd; app files owned by `doombox`.

## Local container smoke (dev)

Not a substitute for a real mini PC, but catches bootstrap regressions fast:

```bash
cd box/host
./test/run-container-smoke.sh
# both arches (needs buildx + qemu):
DOOMBOX_TEST_PLATFORMS=linux/amd64,linux/arm64 ./test/run-container-smoke.sh
```

| Covered | Not covered (use sample PC / VM) |
|---------|----------------------------------|
| Debian 12 packages, users, storage, nginx stub, ssh off | Real Avahi/mDNS on LAN |
| Idempotent bootstrap scripts | Nested Docker Engine (optional `DOOMBOX_TEST_WITH_DOCKER=1 --privileged`) |
| Locked `heyeddi` / `doombox` policy | Hardware NICs, bridge/AP, UEFI flash |

See [test/README.md](./test/README.md).

- Boring host; product features move to Compose under `box/compose/` later.  
- No telemetry packages.  
- Customer path is browser setup — not a Linux desktop login.  
- Storage root: `/mnt/storage/` (see project conventions).
