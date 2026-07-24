# Landing copy brief (single-page SPA)

**Last updated:** 2026-07-23  
**Surface:** `heyeddi-tool/hey-eddi-website` · route `/doomsday-box` 
**Status:** Locked for craft  
**Phase:** Market intent first. **No prototype video required** for this page

## Brand

- **Product:** HeyEddi Doomsday Box  
- **Line:** Sovereign hub: offline cloud · network protection · local AI

## Hero (locked)

| Element | Copy |
|---------|------|
| Brand | HeyEddi Doomsday Box |
| Headline | Your network. Your data. Offline when it matters. |
| Support | Stream to your TVs, run local compute, keep AI on-box, stay useful offline, and put protection on the path. Open source when units ship. |
| Primary CTA | Join with $0 or show intent from $1 |
| Visual | Optional: concept motion graphics + real table B-roll (`video-creative.md`). No fake working demo. |

Do **not** claim a live working demo until software boots on camera. Concept graphics must be labeled as concept.

## Capability section (locked)

**Headline:** Built for sovereignty  

Five pillars (stream · compute · AI · offline · network):

1. **Streaming**: personal video/audio library; play on LAN devices including connected TVs/speakers; no forced cloud account.  
2. **Computing**: Docker-friendly N100/N150 stack; lean always-on home services; ARM64 DIY path.  
3. **Local AI**: on-box models (Ollama-class) without shipping prompts to a vendor cloud.  
4. **Offline**: knowledge archives (Kiwix-style) and core services reachable on the LAN with no uplink. Do **not** mix firewall/tarpit into this pillar.  
5. **Network**: dual topology (inline bridge ISP→box→mesh/LAN **or** Wi‑Fi AP mode); explain **ad-tarpit** (hold tracker connections so they waste time/bandwidth, not only block); host firewall (nftables); VPN-ready (WireGuard/Gluetun optional profile); **multi-box mesh**: two or three boxes can join as nodes for coverage, load split, and household redundancy (pairs with Duo/Trio KS packs).

One-liner: Designed for Intel N100/N150; DIY on ARM64-compatible boards.

## Open-source honesty (locked)

**Headline:** Pay for speed and voice, not a permanent software lock  

Kickstarter Insiders will get early software access and a say in the roadmap. When physical boxes ship, v1.0 is published free on GitHub under GPLv3.

## Planned perks (locked table (reference only))

**Headline:** Planned Kickstarter rewards  
**Label:** Subject to change. Supporting here does **not** lock a reward.

Hardware uses **three stages** (Super Early Bird → Early Bird → Standard), then retail context. Multi-box packs for mesh / multi-node homes.

| Perk | Planned price | Snapshot |
|------|---------------|----------|
| Founding Insider (digital) | $49 | Early builds, VIP channel, feature votes, credit |
| Super Early Bird (1 box) | $399 | First ~100 hardware units |
| Early Bird (1 box) | $429 | Next staged discount |
| Standard (1 box) | $449 | Rest of campaign |
| Household Duo (2 boxes) | $759 / $819 / $859 | Staged; mesh multi-node; saves vs 2 singles |
| Mesh Trio (3 boxes) | $1,099 / $1,189 / $1,249 | Staged; mesh multi-node; saves vs 3 singles |
| Retail (context, 1 box) | $499 | After campaign, not a pre-sale |

## Intent / support block (locked)

**Headline:** Show us the demand  

- Email: required  
- Amount (USD): number input, default **1**, allow **0**, allow any amount **≥ 0** (no artificial cap in UI)  
- Button: **Continue**  
  - If **0** → double-opt-in email only (“You’re on the list”)  
  - If **≥ 1** → Stripe pay → receipt ("Thanks. This is support, not a Kickstarter pledge")  

Microcopy:

> $0 joins the invite list. $1 or more shows serious demand and funds campaign prep (not a Kickstarter pledge; KS totals will not include it). ≥ $1 get first launch email; same email helps early-bird priority when you pledge on Kickstarter.

## Kickstarter pre-launch button

Only when `VITE_KICKSTARTER_PRELAUNCH_URL` is set. Hidden until then.

## Footer (locked)

- Optional concept graphics + table B-roll (`video-creative.md`).  
- Planned rewards may change; site support ≠ Kickstarter pledge.  
- Off-site funds disclosed on the campaign when it launches; ≥ $1 mapping in `ks-stripe-mapping.md`.  
- `privacy@heyeddi.com` · Postmark · Stripe · box.heyeddi.com  

## heyeddi.com hero handoff (locked)

CTA: **Doomsday Box: join the launch** → `https://heyeddi.com/doomsday-box?src=heyeddi-hero`  
(`box.heyeddi.com` aliases to the same page.)
