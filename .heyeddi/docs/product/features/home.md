# Doomsday Box pre-launch landing (single-page Vue)

**Route:** `/` · **Updated:** 2026-07-23

## Problem / user job

Casey needs to show demand for the Doomsday Box **before** a prototype video exists — leave email at $0 or pay ≥ $1 as definitive market intent — without a multi-page site.

## User stories

- As Casey, I want to enter $0 and my email so that I can join the Kickstarter invite list without paying.
- As Casey, I want to pay $1 or more (any amount) with my email so that I can signal serious demand and support campaign prep.
- As the founder, I want paid-intent (≥ $1) counted separately from $0 leads so that I can measure real market intent.
- As Casey, I want planned perk references visible so that I know what Kickstarter may offer — without thinking site payment locks a reward.
- As Casey, I want clear copy that this is not a Kickstarter pledge so that I’m not confused at launch.
- As a visitor from heyeddi.com, I want the page to match the hero promise so that the CTA is not a bait-and-switch.

## Acceptance criteria

1. Single page at `heyeddi.com/doomsday-box` (Nuxt in hey-eddi-website); `box.heyeddi.com` aliases/redirects here
2. Above-the-fold: brand, locked headline, support line, path into email + amount capture (no prototype video required); hero links into feature pillars (stream / compute / AI / offline / network)
3. Amount input: default `$1`, allows `$0`, allows any amount ≥ `$0` (USD); email required
4. `$0` path: store lead + Postmark **double opt-in**; no Stripe charge
5. `≥ $1` path: Stripe charge; store amount; Postmark receipt; copy states not a KS pledge; mapping per `ks-stripe-mapping.md` (priority email + early-bird email-match)
6. Analytics distinguish `lead_email` vs `paid_intent` (primary KPI = paid intent)
7. Planned perk table with Subject to change; no claim that payment alone locks a KS reward without pledging
8. Optional concept graphics + table B-roll allowed; no fake live-demo claims (`video-creative.md`); landing shows graphic feature rows for streaming (incl. LAN/TV playback), computing, local AI, offline archives (no tarpit mix-in), and network (bridge vs AP, ad-tarpit explained, firewall, VPN-ready)
9. Kickstarter pre-launch button only if `VITE_KICKSTARTER_PRELAUNCH_URL` set
10. Footer: disclosure, mapping honesty, privacy@heyeddi.com, Postmark, Stripe, heyeddi.com/doomsday-box (+ box alias)

## Success metric

**Paid-intent rate** = (submits with amount ≥ $1) / (all email submits). Optimize for paid intent, not list vanity.

## Alternatives considered

- Fixed $5 reservation locking early-bird perk: **rejected** for Phase 1; replaced by $0 / ≥$1 infinite support
- Requiring prototype video before collecting intent: **rejected** — market intent first
- Automatic Kickstarter dollar credit from Stripe: **rejected**; locked mapping is prep capital + priority email + early-bird email-match (`ks-stripe-mapping.md`)

## Out of scope

- Prototype / campaign video  
- Full Kickstarter page hosting  
- Shopify retail  
- Box dashboard (`box/`)  
- Guaranteed reward lock from site payment  
- Simultaneous Indiegogo  

## PM review checklist

- [ ] `@ux-flow-auditor`: $0 and ≥$1 paths within click budget
- [ ] `@heyeddi-design critique`: fits Casey; amount UX clear
- [ ] `@visual-auditor audit_contrast --check`
- [ ] `@engineering-excellence`: no over-engineering
- [ ] `check_features`: status not placeholder
