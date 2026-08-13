# Golden appliance image (USB / disk clone)

**Last updated:** 2026-08-13  
**Status:** **active** — bake scripts shipped; hardware flash proof still pending on N150  
**Arches:** separate **amd64** (N100/N150) and **arm64** blobs — same scripts  
**Do not** commit multi-GB `.img` files to git

## Goal (locked)

Flash a USB (or clone a disk) → write to the PC → **plug in power** → hub is reachable at `http://box.local`. Founder does **not** SSH in, does **not** run `bootstrap.sh`, does **not** `docker compose up` on each unit.

Remote desktop image is **pre-pulled**. Desktop stays **off** until claimed + enabled in Settings (lean N150). Cursor is installed inside that desktop after first enable (or baked into cache on the golden).

## What must be in the image

| Layer | In the golden |
|-------|----------------|
| Debian 12 (bookworm), UEFI, headless | yes |
| Bootstrap already applied | users, mDNS, Docker, nginx |
| Compose project + `.env` | **`/opt/doombox`** (`box/` tree: `compose/`, `host/`, `.env`) |
| Docker images | **pre-pulled**: api, dashboard, nginx, webtop |
| systemd | `doombox-first-boot.service` + `doombox-compose.service` |
| Claim state | **empty** — first boot mints a new PIN |
| sshd | **off** |

## Build once (reference unit or VM)

1. Install Debian 12 + run `box/host/scripts/bootstrap.sh`.  
2. Install the **`box/`** tree at `/opt/doombox` (not the whole monorepo root):

   ```bash
   sudo rsync -a --delete ./box/ /opt/doombox/
   cd /opt/doombox/host
   sudo ./scripts/enable-compose-stack.sh --pull-remote-desktop
   ```

   That builds/starts the core stack, points nginx at the gateway, writes `/etc/default/doombox`, and **enables compose on boot**.

3. Prove on this reference: claim → Settings → remote desktop → Cursor (once).  
4. Generalize for imaging (physical console only):

   ```bash
   sudo doombox-prepare-golden   # type PREPARE
   # Power off. Do not reboot into multi-user before imaging.
   ```

5. Image the disk from a **live USB / second machine** (verify device names):

   ```bash
   sudo doombox-bake-golden --device /dev/nvme0n1 \
     --output /mnt/usb/doombox-amd64-$(date +%Y%m%d).img.gz --confirm YES
   ```

   Or equivalent `dd | gzip`. Artifacts stay outside git.

6. Flash clones; first boot runs `doombox-first-boot` (new `machine-id`, SSH host keys, wipe claim leftovers) then `doombox-compose` brings the hub up. Read PIN with `doombox-show-setup-pin` / label export.

## Units & helpers

| Unit / command | Role |
|----------------|------|
| `doombox-first-boot.service` | Oneshot when `/var/lib/doombox/first-boot.done` is missing |
| `doombox-compose.service` | `docker compose up -d` for core stack (no `--build`) |
| `doombox-prepare-golden` | Stop stack, wipe claim, empty machine-id, arm first-boot |
| `doombox-bake-golden` | Safe `dd\|gzip` wrapper (refuses live root disk) |
| `/etc/default/doombox` | `DOOMBOX_BOX_ROOT` (default `/opt/doombox`) |

## Until bake is proven on hardware (dev only)

Debian **netinst USB** + `RUNBOOK.md` + bootstrap. That is **not** the clone path.

## Do not

- Ship Arch/CachyOS as the customer image  
- Require SSH or founder presence to start services  
- Commit `.img` / `.iso` blobs into this repo  
- Reboot the reference unit after `prepare-golden` before imaging (first-boot would mint a PIN into the golden)
