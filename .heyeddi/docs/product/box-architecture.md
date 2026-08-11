# Box software architecture

**Last updated:** 2026-08-10  
**Code root:** `box/`  
**Status:** Locked layout; host v0 bootstrap active

## Purpose

Offline-first personal cloud, inline network protection / ad-tarpit, local AI — local dashboard, **no forced cloud**.

## Principles

1. Zero telemetry by default  
2. Offline-first  
3. x86_64 primary (N100/N150); keep ARM64-compatible  
4. Lean footprint; always set container `cpus` / `mem_limit`  
5. **Boring host, moving apps** — Debian stable host; product features live in Compose images we control

## Host OS (locked)

| Item | Choice |
|------|--------|
| **Ship / prod host** | **Debian** (bookworm = 12 for v1; next major only after a tested bump) |
| **Not ship** | Arch / CachyOS / other full rolling desktops as the customer appliance OS |
| **Dev** | Debian VM preferred; CachyOS (or any modern Linux) OK for coding if Compose targets Debian |
| **v0 image method** | Stock Debian (UEFI) + idempotent `box/host/scripts/bootstrap.sh` |
| **Factory image** | Cloned golden disk **after** bootstrap is proven (`box/host/GOLDEN.md`) |

Host stays minimal: kernel, Docker Engine, nftables, Wi‑Fi/AP helpers, sysctl. Not a general desktop.

**Host v0 smoke:** headless + Docker + `/mnt/storage` + SSH + mDNS `box.local`/`doomsday.local` + nginx stub. Runbook: `box/host/RUNBOOK.md`.

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
2. Tag channels e.g. `stable` / `beta` (names TBD at scaffold).  
3. Auto-update customers only to images we have promoted into their channel.  
4. Before a **Debian major** bump: rebuild host golden image + all our images, run regression (apps, nftables profiles, Ollama footprint), then open a new channel / upgrade path.

Upstream app images (Nextcloud, Ollama, etc.) may be used as bases, but **what the box pulls** is our tagged/digest-pinned release.

## Stack

```
Vue / PrimeVue dashboard
        ↓
FastAPI
        ↓
Docker Compose services  ← primary update surface (our registry)
        ↓
Debian (stable major) · Docker · nftables · AP/bridge · WireGuard path
```

## Repo tree (locked)

```
box/
├── README.md
├── compose/
│   ├── docker-compose.yml
│   ├── docker-compose.dev.yml
│   └── services/           # modular overrides
├── api/                    # FastAPI
├── dashboard/              # Vue / PrimeVue
├── host/                   # install, nftables, sysctl, Debian golden image notes
│   └── scripts/
├── images/                 # Dockerfiles / bake for our published images (at scaffold)
└── .env.example
```

## Capability areas (locked v1 scope)

| Area | v1 |
|------|----|
| Personal cloud | Compose app slots; Nextcloud **or** Immich first via Insider vote defaulting to **Nextcloud** if no vote; LAN media playback to household devices / TVs |
| Offline archives | Optional Kiwix-style knowledge packs; core services reachable with no WAN |
| Network | Dual-port bridge **and** single-port AP mode documented; ship wizard picks one |
| Multi-box mesh | Optional: 2–3 boxes as mesh nodes (coverage, load split, redundancy); pairs with Duo/Trio KS packs |
| Ad-tarpit | Enabled as optional profile; holds tracker connections (starve), not only block |
| VPN | WireGuard/Gluetun optional profile |
| Local AI | Ollama + `llama3.2:3b` + `all-minilm` |
| Scaling | Detect RAM/CPU; single-user default under 16GB |
| Browser remote compute | Optional Compose app (Kasm-class): **authenticated**, prefer **HTTPS :443**; convenience when a VPN client cannot be installed — **not** an EDR-evasion feature |

## First-run unboxing (locked)

1. Plug in power + network (or use AP setup path).  
2. Wait for boot (~1–2 minutes).  
3. On a phone/laptop browser, open any of:
   - `http://box.heyeddi.local` (preferred branded) or short `http://box.local` — hub skin  
   - `http://doomsday.heyeddi.local` or short `http://doomsday.local` — doomsday skin  
4. Complete `/setup` (network mode, **dashboard admin password**, apps). No Linux desktop login required.  
5. Advanced / operator toggles live under **Settings** (web) — not required for household use.

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
| Position as **reachability + UX** (no VPN client, works on HTTPS :443 networks) | Claim “invisible to CrowdStrike / EDR” or market bypass of corp security tools |
| Require **dashboard auth**; default **off**; prefer access via our gateway on 443 | Expose an unauthenticated desktop port on the raw WAN |
| Treat accidental friendliness to restrictive networks as a **side-effect win** | Design or document evasion techniques |

SSH and WireGuard remain first-class for tech users who want them. Browser remote is the household-friendly path.

## Operator / advanced (web-first)

| Path | Who |
|------|-----|
| **Settings → Advanced** on `box.heyeddi.local` | Product path: enable browser remote, publish profiles, optional remote shell (pubkey) |
| `doombox-enable-operator` on console | Break-glass / early host v0 before dashboard exists |

Non-tech users never open Advanced → Linux `heyeddi` stays locked, sshd stays off (`box/host/SECURITY.md`).

## Dashboard routes (locked for first IA)

| Route | Purpose |
|-------|---------|
| `/` | Status home |
| `/setup` | First-run wizard |
| `/network` | AP vs bridge, tarpit toggle |
| `/apps` | Enable/disable Compose apps |
| `/ai` | Model status / simple chat |
| `/settings` | Updates, supporters credit, power, **Advanced / operator** |
| `/founders` | Founding Supporters list |

## Non-goals (v1)

- Cloud account requirement  
- Phone-home analytics  
- Billing inside the appliance  
- Shipping Arch/CachyOS as the appliance host  
- Silent Debian major upgrades  
- **Marketing or engineering for EDR / CrowdStrike evasion**  

## Related

- Epic: `features/box-hub.md`  
- Host security: `box/host/SECURITY.md`  
- OSS: `oss-release-promise.md`  
- Pointer: `.docs/architecture.md`  
