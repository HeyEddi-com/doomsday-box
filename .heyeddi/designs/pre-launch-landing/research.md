# Research: `/projects/doomsday-box` pre-launch landing

**Date:** 2026-08-13  
**Feature:** `pre-launch-landing`  
**Route:** `heyeddi.com/projects/doomsday-box` (aliases: `box.heyeddi.com`)  
**Register:** brand  
**Primary persona:** Casey (early backer)

## Audience fit (required)

| Signal | Implication |
|--------|-------------|
| Casey anxiety | Paying without clarity; being sold a fake demo |
| Success feeling | Joined at $0 or showed paid intent in under a minute without a fake demo |
| Trust | Honest “not a Kickstarter pledge”; subject-to-change perks; no working-demo claim |
| Reject | Countdown spam, purple SaaS chrome, prepper panic, fifteen near-identical tiers |

Casey needs **one obvious action** (email + amount → Continue). Alex/Morgan outcomes (sovereignty pillars) support belief; they are not the primary CTA owners on this route.

## Trend summary (2025–2026)

- Pre-launch pages are **lead instruments**, not brand sites: one CTA, no exit-nav ([LaunchBoom](https://www.launchboom.com/crowdfunding-tips/best-pre-launch-landing-page-examples/), [Kickstarter/LaunchBoom lessons](https://updates.kickstarter.com/launchboom-lessons/how-to-build-your-pre-launch-page/)).
- Category + benefit + who-for in **five seconds**; tech pages: one strong image/GIF, early-bird range, simple capture ([BackerRock](https://backerrock.com/blogs/founders-playbook/kickstarter-pre-launch-email-list-playbook-tech-founders)).
- Paid / deposit intent outranks email-only vanity; custom amount is a valid willingness-to-pay signal ([DEV validation pattern](https://dev.to/software_mvp-factory/validating-your-startup-idea-with-a-landing-page-waitlist-and-stripe-test-mode-in-one-weekend-257)).
- Hardware crowdfunding: honest prototype status; limited early-bird caps; 3–5 clear tiers beat a wall of options ([BoostYourCampaign 2026](https://www.boostyourcampaign.com/crowdfunding-marketing/complete-guide)).
- Category peers (Umbrel): aluminum product photography + calm sovereignty copy; browser-first product story ([umbrel.com](https://umbrel.com/)).

## Patterns to adopt

1. **Single scroll, one primary CTA** — hero path into email + amount; secondary KS button only when URL exists.  
2. **Hero as thesis** — brand name + locked headline + aluminum appliance as subject (not KPI strip).  
3. **Intent segmentation in UI** — default $1, allow $0; microcopy that $0 = list, ≥$1 = paid intent / prep capital.  
4. **Lean perk ladder** — Super EB / Early / KS Special / retail + Insider; Duo/Trio secondary; label subject to change + shipping later.  
5. **Honesty blocks** — OSS at ship; not-a-pledge; optional concept visuals labeled as concept.

## Patterns to avoid

- Multi-page Features / Pricing / Sign-in nav  
- Fake live demo or “working AI firewall” claims ahead of ship  
- Purple-on-white SaaS gradient hero; cream+terracotta AI default; acid-green dark glow  
- Card grid in the hero; floating badge clusters; stat strips  
- Leading with remote-access / tunnel brands  
- Decision paralysis from too many hardware SKUs (Basic/Premium dropped)

## References (what to borrow)

| Source | Borrow |
|--------|--------|
| Framework Laptop | Honest materials storytelling; no fake gloss |
| Umbrel marketing | Clear personal-cloud category in one glance; product-as-object hero |
| Kickstarter hardware campaigns | Early-bird clarity without scammy scarcity theater |
| Linear / Vercel (technique only) | Tight type hierarchy; generous whitespace; one high-contrast CTA |
| LaunchBoom / KS pre-launch guides | One CTA; high-quality imagery; copy over decoration |

## Implications for HeyEddi stack

- Surface lives in **hey-eddi-website** (Nuxt), not `box/` PrimeVue appliance.  
- Map capture to native form controls + Stripe Checkout / CF; keep `en`+`es` i18n.  
- Visual language should **rhyme** with appliance `design.md` (IBM Plex, moss/stone, aluminum honesty) without cloning Hub/Survival skins.  
- Motion: one orchestrated hero reveal; respect `prefers-reduced-motion`.  
- Deferred: real LattePanda product photos until shoot; use concept + table B-roll rules from `video-creative.md`.

## Research → explore decisions

1. Prefer **aluminum chassis as signature moment** over abstract sovereignty gradients.  
2. Keep **intent form reachable from hero** (scroll target or inline mid-hero on desktop).  
3. Perk table is proof of planned campaign, not a storefront checkout.
