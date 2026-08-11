# Host container smoke test

**Purpose:** run `bootstrap.sh` inside `debian:bookworm` on your workstation.  
**Arches:** **amd64 and arm64** from day one (same Dockerfile).  
**Not:** the factory golden disk image or a full mDNS/hardware proof.

```bash
./run-container-smoke.sh
```

Both platforms (needs Docker buildx + QEMU/`binfmt`):

```bash
DOOMBOX_TEST_PLATFORMS=linux/amd64,linux/arm64 ./run-container-smoke.sh
```

Optional nested Docker Engine (slow, needs privilege):

```bash
DOOMBOX_TEST_WITH_DOCKER=1 ./run-container-smoke.sh
```

Exit 0 = container smoke OK. Still flash real hardware before calling host v0 done on that arch.
