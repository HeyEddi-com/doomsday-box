# Sample PC runbook — Debian → DoomBox host

**Last updated:** 2026-08-13  
**Hardware:** Intel N100/N150 (**amd64**) or ARM64 DIY (Pi / Orange Pi class). **Same bootstrap** — no arch fork.

## 0. What you need

- Sample mini PC or ARM board + keyboard/HDMI **or** iPXE/USB-only + serial (HDMI easier for first unit)
- USB stick ≥ 4GB
- Debian 12 netinst for **your arch**: https://www.debian.org/download  
- Another machine on the same LAN for `http://box.local`

## 1. Flash installer USB

On your workstation (example):

```bash
# Identify the USB carefully — wrong device wipes the wrong disk
lsblk
# amd64 (N100/N150):
sudo cp debian-12.*-amd64-netinst.iso /dev/sdX
# arm64:
# sudo cp debian-12.*-arm64-netinst.iso /dev/sdX
sync
```

Prefer the graphical or text **netinst**; skip desktop environments.

## 2. Install Debian 12 (UEFI)

During install:

| Prompt | Choice |
|--------|--------|
| Firmware | UEFI (not legacy BIOS) |
| Disk | Guided — use entire disk, wipe OK on prototypes |
| Partitioning | All files in one partition is fine for v0; leave room later for a data disk |
| Software selection | **SSH server** + standard system utilities. **Uncheck** GNOME/KDE/Xfce |
| Root / sudo | Optional installer user is fine; bootstrap also creates **`heyeddi`** |

Finish and reboot. Confirm you land in a text console or can SSH in.

## 3. First network

Plug Ethernet into the LAN (or configure Wi‑Fi manually). Note the DHCP IP from your router if mDNS fails later.

```bash
hostname -I
ip -br a
```

## 4. Get the bootstrap tree onto the box

**Option A — git clone** (if the box has internet):

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/heyeddi/heyeddi-doomsday-box.git
cd heyeddi-doomsday-box/box/host
```

**Option B — scp from workstation** (offline-friendly):

```bash
# on workstation, from repo root
scp -r box/host founder@<box-ip>:~/doombox-host
# on box
cd ~/doombox-host
```

## 5. Bootstrap

```bash
sudo ./scripts/bootstrap.sh
```

Creates:

- **`heyeddi`** — maker, **password-locked** (no full sudo/docker; non-tech ignore forever)
- **`doombox`** — locked service account
- **sshd off** — no remote shell until a tech user opts in

Re-run anytime; scripts are idempotent. Optional flags:

```bash
sudo ./scripts/bootstrap.sh --skip-docker
sudo ./scripts/bootstrap.sh --force
```

Security model: [SECURITY.md](./SECURITY.md).

## 6. Smoke check

```bash
sudo ./scripts/smoke-check.sh
```

From a phone/laptop on the same LAN:

- http://box.local  
- http://doomsday.local  

Both should show the stub page. Fallback: `http://<box-ip>/`.

## 7. Maker / operator access (tech only)

Non-tech households: stop at the browser. Do nothing here.

`heyeddi` is a **maker** account: shell + user-space installs, **not** full root and **not** in the docker group. See `docs/MAKER.txt`.

```bash
# As root on the local console:
sudo doombox-enable-operator --set-password

# Remote shell (pubkey only — never password SSH). Still no full root.
sudo doombox-enable-operator --pubkey 'ssh-ed25519 AAAA…' --enable-ssh

ssh heyeddi@box.local
# coding / pip --user / npm / flatpak OK
# claim PIN + factory-reset: local console only (sudo host tools refuse SSH)

# Back to household-safe default (local console)
sudo doombox-disable-remote-admin
```

Internet app access (VPN / published services) is separate and will not use SSH — see SECURITY.md.

## Failures

| Symptom | Check |
|---------|--------|
| No `.local` resolution | Client OS mDNS (macOS OK; Linux needs `libnss-mdns`; Windows may need Bonjour or use IP) |
| Port 80 refused | `systemctl status nginx` |
| Docker missing | Re-run bootstrap without `--skip-docker`; check `docker info` |
| Wrong OS | Bootstrap expects Debian 12; use `--force` only for experiments |

## 8. Claim PIN — how to test + match boxes

Codes are **minted by the box**, not checked into git. There is no universal test PIN.

### A) Laptop / compose (no hardware)

```bash
cd box
cp -n .env.example .env   # set STORAGE_ROOT if needed
docker compose -f compose/docker-compose.yml --env-file .env up -d
./scripts/dev-claim-pin.sh          # prints working PIN
# open http://127.0.0.1:8080/setup — enter PIN + a password ≥8 chars
./scripts/dev-reset-claim.sh        # wipe + mint a fresh PIN for another try
```

### B) Sample PC (after bootstrap + compose stack)

```bash
sudo doombox-show-setup-pin           # read PIN on console / HDMI
# from phone/laptop on LAN: http://box.local/setup
# At the box console only (refuses SSH on purpose — no remote reclaim)
sudo doombox-factory-reset-claim      # type RESET when prompted
# restart API/compose, then show-setup-pin again
```

### HDMI claim kiosk (loopback only)

```bash
sudo doombox-enable-claim-kiosk
# optional local Chromium seat:
sudo doombox-enable-claim-kiosk --with-browser
```

Serves `http://127.0.0.1:7901/` on the box only. **Not** reachable via `box.local` / LAN. After claim, the page shows “already claimed.”

### Dashboard auth

After claim, Home/Settings require the dashboard password (`/login`). Sessions are HttpOnly cookies. There is still **no** factory-reset or claim-PIN API.

### C) Match each chassis to its PIN (sample batch / factory)

1. Power the unit; start the appliance stack once (API mints `SETUP_PIN.txt`).
2. Optional once per image: `sudo cp conf/product.env.example /etc/doombox/product.env` (SKU / name).
3. On that machine: `sudo doombox-export-claim-label`
4. Print from the pack under `/mnt/storage/backups/labels/<SERIAL>/`:
   - `label.html` — packing card (browser print)
   - `label.zpl` — thermal printer (Code128 serial + QR claim PIN)
5. Apply sticker to **that** chassis. Ledger: `/mnt/storage/backups/claim-ledger.csv`.
6. Ship. Customer claims with the sticker PIN. Details: [label/README.md](./label/README.md).

Rule: **one sticker ↔ one serial ↔ one live PIN**. Do not reuse a PIN across units. Do not publish the ledger.

## 9. Compose on boot (appliance / golden)

After bootstrap, install the **`box/`** tree and enable the stack (nginx + systemd):

```bash
# Recommended appliance path:
sudo rsync -a --delete /path/to/repo/box/ /opt/doombox/
cd /opt/doombox/host
sudo ./scripts/enable-compose-stack.sh --pull-remote-desktop
systemctl is-enabled doombox-compose.service
```

Reboot once on the reference unit and confirm `http://box.local` comes back with **no** SSH and **no** manual `compose up`.

Clone path (after the reference is proven): [GOLDEN.md](./GOLDEN.md) — `doombox-prepare-golden` → `doombox-bake-golden` → flash → power on.

## Next after v0 smoke

1. Point host nginx at the compose gateway (`enable-compose-stack.sh`).  
2. HDMI claim kiosk: `sudo doombox-enable-claim-kiosk` (optional `--with-browser`).  
3. When one sample is known-good, follow [GOLDEN.md](./GOLDEN.md) for a clonable image.
