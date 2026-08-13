# Product backlog

**Last updated:** 2026-08-13

Prioritized by user value. PM owns order: engineering estimates inform but do not override user pain.

## Active track (appliance)

| Priority | Feature / route | User story (summary) | Status | Notes |
|----------|-----------------|--------------------|--------|-------|
| P0 | Stage-1 hub shell | Claim, login, dual-skin Home/Settings | **done** | Host bootstrap + Compose API/dashboard + CI |
| P0 | Browser remote desktop | Authenticated webtop; Cursor on desktop; no SSH | **done (software)** | Settings toggle, `/desktop/` login gate, apt cache restore. Proven in compose. |
| P0 | Boot-on-power compose | Hub + API + gateway start with no SSH / no manual `compose up` | **done (software)** | `doombox-compose.service` via `enable-compose-stack.sh` / `install-compose-boot.sh` |
| P0 | Appliance USB / golden image | Flash stick → write disk → plug in → hub is up; fresh claim PIN per clone | **active** | Scripts in `GOLDEN.md`; hardware flash proof still pending |
| P0 | First-boot generalize | New `machine-id`, SSH keys, claim PIN on every clone | **done (software)** | `doombox-first-boot.service` + `doombox-prepare-golden` |
| P1 | `/apps` shell | Enable/disable Compose app profiles + resource limits | planned | Remote desktop already has a Settings toggle |
| P2 | Browser VS Code (code-server) | Optional light tab IDE | later | Not Cursor |
| P2 | Network wizard | AP vs bridge; tarpit toggle | planned | `/network` |
| P2 | Local AI | Ollama + small models | planned | `/ai` |
| P2 | Personal cloud slot | Nextcloud or Immich (Insider vote; default Nextcloud) | planned | |
| P3 | Operator SSH (pubkey) | Optional Advanced remote shell | deferred | Console break-glass only |

## Marketing / campaign (hey-eddi-website)

| Priority | Feature / route | User story (summary) | Status | Notes |
|----------|-----------------|--------------------|--------|-------|
| P0 | Marketing on heyeddi.com | `/projects/doomsday-box` Nuxt landing | **done (UI)** | `hey-eddi-website`; waitlist CF founder-owned |
| P0 | Email + Postmark DOI | Confirm leads; receipts for ≥ $1 | planned | Firebase CF on hey-eddi-website |
| P0 | Stripe custom amount | $0 skip; ≥ $1 Checkout | planned | Same CF |
| P0 | Dual path + disclosure | Not a KS pledge; measure paid_intent KPI | planned | Primary KPI ≥ $1 |
| P0 | Domains | Canonical projects URL + box/doomsday aliases | planned | `marketing-hosting.md` |
| P1 | KS↔Stripe mapping ops | Priority email + early-bird email-match at launch | done (doc) | `ks-stripe-mapping.md` |
| P1 | Concept + table video | Landing creative OK now | planned | Brief exists; appliance USB is higher priority |
| P1 | Thanks / confirmation | Inline success on same page | planned | |
| P1 | Kickstarter pre-launch CTA | “Notify me on Kickstarter” | blocked | Needs KS approval |
| P2 | Prototype + demo video | Required for KS submit only | later | **Not** a Phase 0 blocker |
| P2 | heyeddi.com hero CTA | Brand site points to projects URL | planned | hey-eddi-website |
| P2 | Campaign analytics | lead vs paid_intent rates | planned | |
| P2 | Insider beta on `box/` | Early access builds | planned | After USB image exists |
| P3 | Post-KS Late Pledge / InDemand | After campaign | later | |
| P3 | Public OSS v1.0 | At hardware ship | later | |

## Roadmap (north star)

```
Stage-1 hub shell (done)
  → Browser remote desktop + Cursor (software done)
  → Boot-on-power + USB golden image (scripts done; flash proof active) — flash, don't SSH each box
  → Household hub features (network / apps / AI / cloud)
  → KS with working prototype demo
  → Hardware ship + public OSS v1.0
```

Parallel: Phase 0 market intent on heyeddi.com (Stripe / email).

## Decisions locked (2026-07-24)

- **This repo:** `box/` appliance software + `.heyeddi` product docs. Marketing folder `website/` **deleted**.
- **Surface (Phase 0):** `heyeddi.com/projects/doomsday-box` in hey-eddi-website; waitlist via Firebase CF.
- **Distribution:** heyeddi.com hero → projects URL (`box.heyeddi.com` alias).
- **Crowdfunding:** Kickstarter primary; no simultaneous identical Indiegogo campaign.
- **Money:** Custom USD amount — **$0** = lead, **≥ $1** = paid market intent (up to ∞); not a Kickstarter pledge.
- **Phase 0:** Market intent first — **no prototype video** required for the landing.
- **KS mapping:** Locked in `ks-stripe-mapping.md` — prep capital + priority email + early-bird email-match; no $ off pledges.
- **Video:** Concept graphics + table B-roll OK for landing (`video-creative.md`); working prototype required before KS submit.
- **Perks on page:** Planned references only; payment does not lock a reward.
- **OSS:** Early access during campaign; public release at physical ship. GPLv3 · public repo at hardware ship.
- **Email:** Postmark via hey-eddi Cloud Functions; **double opt-in**; Firestore owns the list.
- **KS goal:** $35,000 USD · 30 days · shipping table in `campaign-brief.md`.
- **Support defaults:** `hello@heyeddi.com` · 30-day DOA · 12-month warranty.
- **Privacy contact:** `privacy@heyeddi.com` · no non-essential cookies.

## Decisions locked (2026-08-11) — remote coding MVP

- **First appliance MVP:** use the boxes as remote coding machines via **browser**.
- **Cursor required** → authenticated **browser full desktop** (webtop / KasmVNC); install Cursor on that desktop.
- **No SSH for now** (product path). Console break-glass scripts remain.
- **code-server** is optional later. There is **no** official Cursor Agent extension for VS Code.
- Remote desktop is **user-configurable** (default off); gateway auth; never market EDR evasion.

## Decisions locked (2026-08-13) — flash, don't babysit

- Founder must **not** power on each PC to run bootstrap or `compose up`.
- **Ship path:** USB / golden disk with Debian + bootstrap already applied + Compose images **pre-pulled** + stack **starts on boot**.
- Clone first-boot mints a **new claim PIN** (and machine-id / SSH host keys). No shared identity across sticks.
- **Do not** commit multi-GB `.img` files to git. Bake artifacts stay off-repo (`GOLDEN.md`).
- Separate **amd64** (N150) and **arm64** images — same scripts, different blobs.
- Debian netinst + manual bootstrap remains the **dev** path, not the clone path.

## Explicitly deferred

- Simultaneous multi-platform live crowdfunding
- Automatic Stripe→KS dollar credit / coupons
- Guaranteed reward lock from site payment alone
- Public Invest CTA / securities offer on the landing
- SSH / Remote-SSH as the primary coding path (may return later under Advanced)
