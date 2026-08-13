# Box software architecture

**Last updated:** 2026-08-13  
**Code root:** `box/`  
**Status:** Stage-1 + remote-desktop software shipped; USB golden image next

## Purpose

Offline-first personal cloud, inline network protection / ad-tarpit, local AI — local dashboard, **no forced cloud**.

**Near-term:** founders code on boxes via authenticated browser desktop (Cursor). **Next:** flashable USB/golden disk so clones boot the hub **without SSH or per-machine bootstrap**.

## Principles

1. Zero telemetry by default  
2. Offline-first  
3. x86_64 primary (N100/N150); keep ARM64-compatible  
4. Lean footprint; always set container `cpus` / `mem_limit`  
5. **Boring host, moving apps** — Debian stable host; product features live in Compose images we control

## Delivery status

| Layer | Status |
|-------|--------|
| Host bootstrap (`box/host/`) | **Shipped** — Debian scripts, mDNS, claim kiosk/label, operator console, compose enable |
| Compose gateway + API + dashboard | **Shipped** — claim/auth, dual skins, Home / Setup / Login / Settings |
| Software CI | **Shipped** — dashboard, API, host smoke, compose smoke |
| Browser remote desktop (KasmVNC webtop) | **Shipped (software)** — Settings toggle, `/desktop/` login redirect, apt cache restore; proven in compose |
| Browser VS Code (code-server) | Later optional profile (not Cursor) |
| `/network`, `/apps`, `/ai`, `/founders` | Not started |
| Boot-on-power compose | **Next** — systemd so hub starts with no manual `compose up` |
| USB / golden appliance image | **Scripts done** — flash proof on N150 still pending (`GOLDEN.md`) |
| Product SSH path | Deferred (console break-glass only for now) |

## Host OS (locked)

| Item | Choice |
|------|--------|
| **Ship / prod host** | **Debian** (bookworm = 12 for v1; next major only after a tested bump) |
| **Not ship** | Arch / CachyOS / other full rolling desktops as the customer appliance OS |
| **Dev** | Debian VM preferred; CachyOS (or any modern Linux) OK for coding if Compose targets Debian |
| **Dev / first reference** | Stock Debian (UEFI) + idempotent `box/host/scripts/bootstrap.sh` |
| **Clone / friend-seed / factory** | USB or `.img.gz` with stack **already in the image**, compose **on boot**, fresh claim PIN per clone (`box/host/GOLDEN.md`) |

Host stays minimal: kernel, Docker Engine, nftables, Wi‑Fi/AP helpers, sysctl. Not a general desktop — the **desktop for Cursor** lives in a Compose workspace, not on the host DE.

**Host smoke:** headless + Docker + `/mnt/storage` + mDNS `box.local`/`doomsday.local` + nginx stub/gateway. Runbook: `box/host/RUNBOOK.md`.

## Updates (locked)

| Layer | What updates | How | Cadence |
|-------|--------------|-----|---------|
| **Compose apps** (primary) | Our service images + pinned upstream tags | Dashboard / compose pull; digests preferred | Frequent; auto-update **within** a tested channel |
| **HeyEddi API + dashboard** | Our images | Same as apps | With app channel |
| **Debian host packages** | security + stable point releases | `unattended-upgrades` (or equivalent) **within the same major** | Auto OK for security; reboot policy explicit |
| **Debian major (LTS → LTS)** | e.g. 12 → 13 | **Manual / gated** major we test on our images + VM + hardware | Never silent; staged channel first |

### Our images (locked)

We **maintain and publish** Doomsday Box images (registry we control), not “always `latest` from random upstreams” on customer boxes.

1. Build/test on CI against **Debian bookworm**-shaped hosts (VM first).  
2. Tag channels e.g. `stable` / `beta` (names TBD).  
3. Auto-update customers only to images we have promoted into their channel.  
4. Before a **Debian major** bump: rebuild host golden image + all our images, run regression (apps, nftables profiles, Ollama footprint), then open a new channel / upgrade path.

Upstream app images (Nextcloud, Kasm-class, Ollama, etc.) may be used as bases, but **what the box pulls** is our tagged/digest-pinned release.

## Stack

```
Vue / PrimeVue dashboard
        ↓
FastAPI
        ↓
Docker Compose services  ← primary update surface (our registry)
  · gateway · api · dashboard
  · remote-desktop (MVP) · later: apps / AI / cloud
        ↓
Debian (stable major) · Docker · nftables · AP/bridge · WireGuard path
```

## Repo tree (current)

```
box/
├── README.md
├── compose/
│   ├── docker-compose.yml
│   ├── docker-compose.dev.yml
│   └── gateway/            # nginx reverse proxy
├── api/                    # FastAPI (claim, auth, status)
├── dashboard/              # Vue / PrimeVue (dual skin)
├── host/                   # Debian bootstrap, security, golden notes
│   ├── scripts/
│   ├── kiosk/
│   └── test/
├── images/                 # Dockerfiles for api + dashboard
├── test/                   # software + compose smoke entrypoints
├── scripts/                # dev claim helpers
└── .env.example
```

Modular Compose overrides under `compose/services/` arrive with app profiles (remote desktop first).

## Capability areas (locked v1 scope)

| Area | v1 | Now |
|------|----|-----|
| Browser remote compute | Kasm-class desktop; **authenticated**; prefer **HTTPS :443**; user-toggleable | **MVP** |
| Personal cloud | Compose app slots; Nextcloud **or** Immich (vote; default Nextcloud) | later |
| Offline archives | Optional Kiwix-style packs | later |
| Network | Dual-port bridge **and** single-port AP; tarpit optional | later |
| Multi-box mesh | Optional 2–3 nodes | later |
| VPN | WireGuard/Gluetun optional | later |
| Local AI | Ollama + `llama3.2:3b` + `all-minilm` | later |
| Scaling | Detect RAM/CPU; single-user default under 16GB | design when desktop lands |
| Browser VS Code | Optional code-server profile | later; not Cursor |
| SSH Remote | Optional Advanced pubkey | deferred |

## First-run unboxing (locked)

1. Plug in power + network (or use AP setup path).  
2. Wait for boot (~1–2 minutes).  
3. On a phone/laptop browser, open any of:
   - `http://box.heyeddi.local` (preferred branded) or short `http://box.local` — hub skin  
   - `http://doomsday.heyeddi.local` or short `http://doomsday.local` — doomsday skin  
4. Complete `/setup` (**dashboard admin password**, claim PIN from sticker/console/kiosk — never from an API). No Linux desktop login required.  
5. Enable **Remote desktop** from Settings / Apps when ready to code on the box.  
6. Other Advanced toggles stay optional for household use.

Fallback: device IP (kiosk / router list) if mDNS fails. Optional HDMI kiosk shows branded URLs when ready.

## Local hostnames + dual UI (locked)

Same appliance, same API, same features. **Hostname picks the dashboard skin** (Host header / mDNS name).

| Hostname | Skin | Focus (IA / copy / visual) |
|----------|------|----------------------------|
| **`box.heyeddi.local`** (alias **`box.local`**) | Hub / “happy” | Media, personal cloud, family-friendly status, everyday apps |
| **`doomsday.heyeddi.local`** (alias **`doomsday.local`**) | Doomsday | Offline readiness, network protection, tarpit/VPN, resilience |

Rules:

1. One codebase (`dashboard/`); theme + nav order + home widgets switch by hostname (user can also toggle skin in settings).  
2. **No feature fork** — every capability reachable from both skins; only emphasis and layout differ.  
3. Advertise **branded names first** on quick-start / kiosk; keep short `.local` aliases for convenience.  
4. Setup wizard works on any of the four names; after setup, bookmarks to any are fine.  
5. Windows mDNS can be flaky for multi-label names — always show IP fallback in UI.

## Browser remote compute (locked product framing)

| Do | Don't |
|----|-------|
| Position as **reachability + UX** (work on the box from a browser) | Claim “invisible to CrowdStrike / EDR” or market bypass of corp security tools |
| Require **dashboard auth**; default **off**; prefer access via our gateway on 443 | Expose an unauthenticated desktop port on the raw WAN |
| Ship **full desktop** first so **Cursor** (desktop app) can run | Pretend code-server or a VS Code extension is Cursor |
| Treat accidental friendliness to restrictive networks as a **side-effect win** | Design or document evasion techniques |
| Offer optional code-server later as a light VS Code tab | Claim Cursor Agent exists as a VS Code extension (it does not) |

**MVP constraint (2026-08-11):** no product SSH path yet. WireGuard/SSH may return later under Advanced. Console `doombox-enable-operator` remains break-glass only.

## Operator / advanced (web-first)

| Path | Who |
|------|-----|
| **Settings → Advanced** / Apps | Product path: enable browser remote desktop; later other profiles |
| `doombox-enable-operator` on console | Break-glass only |

Non-tech users never open Advanced → Linux `heyeddi` stays locked, sshd stays off by default (`box/host/SECURITY.md`).

## Dashboard routes

| Route | Purpose | Status |
|-------|---------|--------|
| `/` | Status home | shipped |
| `/setup` | First-run claim wizard | shipped |
| `/settings` | Updates, power, Advanced | shipped (partial) |
| `/network` | AP vs bridge, tarpit toggle | planned |
| `/apps` | Enable/disable Compose apps (incl. remote desktop) | planned (MVP enabler) |
| `/ai` | Model status / simple chat | planned |
| `/founders` | Founding Supporters list | planned |

## Non-goals (v1)

- Cloud account requirement  
- Phone-home analytics  
- Billing inside the appliance  
- Shipping Arch/CachyOS as the appliance host  
- Silent Debian major upgrades  
- **Marketing or engineering for EDR / CrowdStrike evasion**  
- SSH-first coding for the current MVP  

## Related

- Epic: `features/box-hub.md`  
- Backlog / roadmap: `backlog.md`  
- Host security: `box/host/SECURITY.md`  
- Engineering notes: `.heyeddi/docs/engineering/`  
- OSS: `oss-release-promise.md`  
- Pointer: `.docs/architecture.md`  
