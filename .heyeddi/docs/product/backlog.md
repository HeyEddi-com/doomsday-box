# Product backlog

**Last updated:** 2026-08-10

Prioritized by user value. PM owns order: engineering estimates inform but do not override user pain.

| Priority | Feature / route | User story (summary) | Status | Notes |
|----------|-----------------|--------------------|--------|-------|
| P0 | Marketing on heyeddi.com | `/doomsday-box` Nuxt landing | **done (UI)** | `hey-eddi-website`; waitlist CF founder-owned |
| P0 | Email + Postmark DOI | Confirm leads; receipts for ≥ $1 | planned | Firebase CF on hey-eddi-website |
| P0 | Stripe custom amount | $0 skip; ≥ $1 Checkout | planned | Same CF |
| P0 | Dual path + disclosure | Not a KS pledge; measure paid_intent KPI | planned | Primary KPI ≥ $1 |
| P0 | Domains | `heyeddi.com/doomsday-box`; box/doomsday aliases | planned | `marketing-hosting.md` |
| P1 | KS↔Stripe mapping ops | Priority email + early-bird email-match at launch | done (doc) | `ks-stripe-mapping.md` |
| P1 | Concept + table video | Landing creative OK now | planned | Brief exists (`product-imagery-brief.md`); paused — active track is host Linux image |
| P1 | Thanks / confirmation | Inline success on same page | planned | |
| P1 | Kickstarter pre-launch CTA | “Notify me on Kickstarter” | blocked | Needs KS approval |
| P1 | Host golden image | Debian bookworm appliance on sample PCs | **active** | `box/host/` bootstrap + RUNBOOK scaffolded; flash sample next |
| P1 | `box/` scaffold | FastAPI + Vue dashboard shell | planned | After host v0 smoke on sample PC |
| P2 | Prototype + demo video | Required for KS submit only | later | **Not** a Phase 0 blocker |
| P2 | heyeddi.com hero CTA | Brand site points to `/doomsday-box` | planned | hey-eddi-website |
| P2 | Campaign analytics | lead vs paid_intent rates | planned | |
| P2 | Insider beta on `box/` | Early access builds | planned | |
| P3 | Post-KS Late Pledge / InDemand | After campaign | later | |
| P3 | Public OSS v1.0 | At hardware ship | later | |

## Decisions locked (2026-07-24)

- **This repo:** `box/` appliance software + `.heyeddi` product docs. Marketing folder `website/` **deleted**.
- **Surface (Phase 0):** `heyeddi.com/doomsday-box` in hey-eddi-website; waitlist via Firebase CF.
- **Distribution:** heyeddi.com hero → `/doomsday-box` (`box.heyeddi.com` alias).
- **Crowdfunding:** Kickstarter primary; no simultaneous identical Indiegogo campaign.
- **Money:** Custom USD amount — **$0** = lead, **≥ $1** = paid market intent (up to ∞); not a Kickstarter pledge.
- **Phase 0:** Market intent first — **no prototype video** required for the landing.
- **KS mapping:** Locked in `ks-stripe-mapping.md` — prep capital + priority email + early-bird email-match; no $ off pledges.
- **Video:** Concept graphics + table B-roll OK for landing (`video-creative.md`); working prototype required before KS submit.
- **Perks on page:** Planned references only; payment does not lock a reward.
- **OSS:** Early access during campaign; public release at physical ship. GPLv3 · `heyeddi/doomsday-box` at hardware ship.
- **Email:** Postmark via hey-eddi Cloud Functions; **double opt-in**; Firestore owns the list.
- **KS goal:** $35,000 USD · 30 days · shipping table in `campaign-brief.md`.
- **Support defaults:** `hello@heyeddi.com` · 30-day DOA · 12-month warranty.
- **Privacy contact:** `privacy@heyeddi.com` · no non-essential cookies.

## Explicitly deferred

- Simultaneous multi-platform live crowdfunding
- Automatic Stripe→KS dollar credit / coupons
- Guaranteed reward lock from site payment alone
- Public Invest CTA / securities offer on the landing
