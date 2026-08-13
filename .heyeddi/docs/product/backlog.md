# Product backlog

**Last updated:** 2026-08-11

Prioritized by user value. PM owns order: engineering estimates inform but do not override user pain.

## Active track (appliance)

| Priority | Feature / route | User story (summary) | Status | Notes |
|----------|-----------------|--------------------|--------|-------|
| P0 | Stage-1 hub shell | Claim, login, dual-skin Home/Settings | **done** | Host bootstrap + Compose API/dashboard + CI |
| P0 | Browser remote desktop | Authenticated KasmVNC webtop; install Cursor on desktop | **active** | Compose profile + Settings toggle + `/desktop/` auth; enable via `doombox-enable-remote-desktop` |
| P1 | User-configurable remote modes | Owner enables desktop (± later browser VS Code) from Settings / Apps | planned | Same auth + gateway; default off |
| P1 | `/apps` shell | Enable/disable Compose app profiles + resource limits | planned | Needed to toggle remote desktop cleanly |
| P2 | Browser VS Code (code-server) | Optional light tab IDE | later | VS Code–like only; **not** Cursor (no Cursor Agent extension exists) |
| P2 | Network wizard | AP vs bridge; tarpit toggle | planned | `/network` |
| P2 | Local AI | Ollama + small models | planned | `/ai` |
| P2 | Personal cloud slot | Nextcloud or Immich (Insider vote; default Nextcloud) | planned | |
| P3 | Golden image flash | Clone proven disk to sample PCs | **blocked** | Flash only after browser connect + remote desktop works on a real PC |
| P3 | Operator SSH (pubkey) | Optional Advanced remote shell | deferred | Explicitly **not** MVP; console break-glass remains |

## Marketing / campaign (hey-eddi-website)

| Priority | Feature / route | User story (summary) | Status | Notes |
|----------|-----------------|--------------------|--------|-------|
| P0 | Marketing on heyeddi.com | `/projects/doomsday-box` Nuxt landing | **done (UI)** | `hey-eddi-website`; waitlist CF founder-owned |
| P0 | Email + Postmark DOI | Confirm leads; receipts for ≥ $1 | planned | Firebase CF on hey-eddi-website |
| P0 | Stripe custom amount | $0 skip; ≥ $1 Checkout | planned | Same CF |
| P0 | Dual path + disclosure | Not a KS pledge; measure paid_intent KPI | planned | Primary KPI ≥ $1 |
| P0 | Domains | Canonical projects URL + box/doomsday aliases | planned | `marketing-hosting.md` |
| P1 | KS↔Stripe mapping ops | Priority email + early-bird email-match at launch | done (doc) | `ks-stripe-mapping.md` |
| P1 | Concept + table video | Landing creative OK now | planned | Brief exists; appliance MVP is higher priority |
| P1 | Thanks / confirmation | Inline success on same page | planned | |
| P1 | Kickstarter pre-launch CTA | “Notify me on Kickstarter” | blocked | Needs KS approval |
| P2 | Prototype + demo video | Required for KS submit only | later | **Not** a Phase 0 blocker |
| P2 | heyeddi.com hero CTA | Brand site points to projects URL | planned | hey-eddi-website |
| P2 | Campaign analytics | lead vs paid_intent rates | planned | |
| P2 | Insider beta on `box/` | Early access builds | planned | After remote-desktop MVP |
| P3 | Post-KS Late Pledge / InDemand | After campaign | later | |
| P3 | Public OSS v1.0 | At hardware ship | later | |

## Roadmap (north star)

```
Stage-1 hub shell (done)
  → Browser remote desktop + Cursor (MVP, no SSH)
  → Flash golden when browser path works on hardware
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
- **KS goal:** $35,000 USD · 30 days · pledge excl. shipping (BackerKit later) — `campaign-brief.md` / `campaign-economics.md`.
- **Hardware SKU (research 2026-08-13):** single **LattePanda IOTA**; Super EB / Early / KS Special **$299 / $329 / $349**; MSRP **$399**. Re-quote before buy.
- **Support defaults:** `hello@heyeddi.com` · 30-day DOA · 12-month warranty.
- **Privacy contact:** `privacy@heyeddi.com` · no non-essential cookies.

## Decisions locked (2026-08-11) — remote coding MVP

- **First appliance MVP:** use the boxes as remote coding machines via **browser**, not golden flash.
- **Cursor required** for founder workflow → MVP = **authenticated browser full desktop** (Kasm-class); install Cursor on that desktop.
- **No SSH for now** (product path). Console break-glass scripts remain.
- **code-server** is optional later (VS Code–like tab). There is **no** official Cursor Agent extension for VS Code.
- **Golden flash** blocked until claim → browser → remote desktop works on a real PC.
- Remote modes are **user-configurable** (default off); prefer gateway auth on :443; never market EDR evasion.

## Explicitly deferred

- Simultaneous multi-platform live crowdfunding
- Automatic Stripe→KS dollar credit / coupons
- Guaranteed reward lock from site payment alone
- Public Invest CTA / securities offer on the landing
- SSH / Remote-SSH as the primary coding path (may return later under Advanced)
