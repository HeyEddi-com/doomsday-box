# Host security model (dual audience)

**Last updated:** 2026-08-11  
**Status:** Locked for host v0+

## Who uses what

| Audience | How they use the box | Linux `heyeddi`? | SSH? |
|----------|----------------------|------------------|------|
| Non-tech (Morgan/Casey) | Browser → `box.heyeddi.local` (or `box.local`) | Never | No — sshd stays off |
| Tech (Alex / founder) | Settings → Advanced, or console break-glass | Optional | Pubkey only, opt-in |

**Default after bootstrap:** `heyeddi` exists but is **password-locked**; **sshd is disabled**. A box that never enables operator features has **no remote shell surface**. “Never set a Linux password” households are fine.

## Accounts

| Account | Login | Rights |
|---------|-------|--------|
| `heyeddi` | Locked until enable-operator | **Maker:** `$HOME` tooling, user-space installs. **Not** in `sudo` or `docker` groups. Limited sudoers (PASSWD): show-pin / export-label / factory-reset / disable-remote only — those tools refuse SSH |
| `doombox` | Impossible (nologin + locked + SSH DenyUsers) | Owns app data under `/mnt/storage/…` — **not** docker, **not** sudo |
| `root` | Console / break-glass only | Full host; runs `doombox-enable-operator`; claim tools |

`docker` group ≈ root. **Nobody** in product accounts gets it. Host Compose is operated by root/systemd, not by `heyeddi`.

Sensitive scripts install as `0750 root:root` under `/usr/local/sbin`. Claim files are mode `600` (service UID). Stolen maker credentials cannot read PIN files or run blanket `apt`/`sudo`.

**Claim PIN display:** `doombox-enable-claim-kiosk` serves PIN at `http://127.0.0.1:7901/` only (HDMI/local browser). Never on `box.local`.

**Dashboard auth:** after claim, session cookie required for Home/Settings. Login uses the password set at claim. No reclaim/PIN endpoints.

See [docs/MAKER.txt](./docs/MAKER.txt) (also copied to `~/README-MAKER.txt` on the box).

## Browser remote compute (product framing)

**Purpose:** reachability and UX — use a browser when installing a VPN client is impractical; prefer authenticated HTTPS on **:443**.

| Locked | |
|--------|--|
| Do | Authenticated, opt-in, hardened container (no docker.sock), gateway on 443 when published |
| Don't | Claim invisibility to CrowdStrike / EDR, or document bypass of corporate security tools |
| Side effect | If restrictive networks treat it like normal HTTPS, that is an incidental win — **not** a design or marketing claim |

SSH and WireGuard remain available for users who want them. We do not position browser remote as “stealthier than VPN.”

## Internet-facing services (separate from SSH)

1. **Do not** expose SSH (port 22) to the internet.  
2. **Do** expose only intentional app entrypoints (VPN listen and/or reverse-proxy with auth).  
3. App processes run as `doombox` / container users with bind mounts limited to needed dirs.  
4. WAN / browser-remote publish is **opt-in** (setup wizard or Settings → Advanced) — off at bootstrap.

Mental model:

```
Internet → [HTTPS :443 gateway / VPN] → authenticated apps (incl. optional browser desktop)
                ✗ never → sshd / raw heyeddi login
LAN      → box.heyeddi.local / box.local dashboard
LAN      → ssh heyeddi@… only if tech enabled pubkey SSH
```

## Operator enable / disable

**Product path (preferred):** dashboard **Settings → Advanced** on `box.heyeddi.local`.

**Host break-glass (v0 / recovery):**

```bash
# As root on the local console (not over SSH as heyeddi):
sudo doombox-enable-operator --set-password
sudo doombox-enable-operator --pubkey 'ssh-ed25519 AAAA…' --enable-ssh
# Later, at the box (maker may use limited sudo):
sudo doombox-disable-remote-admin
```

Maker account has **no full root**. Packages/libs: user-space only (`pip --user`, nvm, flatpak, …). Details: [docs/MAKER.txt](./docs/MAKER.txt).

## First-run claim (anti-hijack)

Open LAN setup without a secret is **claimable by anyone on the network**. Locked model:

1. On first API start, the box mints a **one-time claim PIN** (not available over HTTP).  
2. Owner reads it from **HDMI kiosk**, **sticker**, or console: `doombox-show-setup-pin` / `SETUP_PIN.txt` on the box.  
3. `/api/setup` requires that PIN + dashboard admin password.  
4. After success: PIN file deleted, claim marked consumed, further setup returns **403** until factory reset.  
5. Admin password stored as salted hash only.

```bash
sudo doombox-show-setup-pin          # physical/console
sudo doombox-export-claim-label      # HTML + ZPL pack (SKU, S/N, PIN, QR, Code128)
sudo doombox-factory-reset-claim     # physical console only — typed RESET (refuses SSH)
```

### Anti-brick (lost plaintext PIN)

If the box is **still unclaimed** and `SETUP_PIN.txt` is missing but `setup-claim.json` remains, the API **remints** a new PIN on next start. The old sticker code stops working; run `doombox-show-setup-pin` / re-export the label. After a successful claim, missing plaintext is normal (do not remint).

### Factory reset: physical only (no remote, no API)

| Path | Allowed? |
|------|----------|
| Local console / HDMI / serial + `doombox-factory-reset-claim` | Yes |
| SSH / remote admin (even when opted in) | **No** — script refuses when `SSH_*` is set |
| HTTP / dashboard / `/api/*` | **No** — there is no factory-reset API; do not add one |
| Stolen dashboard password alone | **Cannot** reclaim the box over the network |

Remote admin is for break-glass shell work, not reclaim. A leaked admin password must not unlock factory reset. (A remote attacker who already has **root via SSH** can still destroy files by hand — that is why sshd stays off by default and should be disabled after use.)

### Matching a box to its PIN

PINs are **not** a shared master list. Each unit mints its own code on first API start.

| Stage | Action |
|-------|--------|
| Product env | `/etc/doombox/product.env` (SKU, name) from `conf/product.env.example` |
| Provision | Boot unit, start compose once, run `doombox-export-claim-label` |
| Label pack | `/mnt/storage/backups/labels/<SERIAL>/` → `label.html` + `label.zpl` + `meta.json` |
| Codes | Code128 = serial; QR = claim PIN |
| Ledger | CSV under `/mnt/storage/backups/claim-ledger.csv` (offline / USB) |
| Ship | Sticker on *that* chassis; PIN file remains until customer claims |
| Claim | Customer types/scans PIN; box deletes `SETUP_PIN.txt` |
| Retest | Physical console: `doombox-factory-reset-claim` → restart API → new PIN → new label |

See [label/README.md](./label/README.md). Never put claim PINs in the public repo, marketing site, or an open cloud sheet.
