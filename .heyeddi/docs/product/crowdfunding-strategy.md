# Crowdfunding & pre-launch strategy

**Last updated:** 2026-08-13  
**Status:** Locked phasing — perk prices are **research** (see `hardware-bom.md`, `campaign-economics.md`)

## Phasing (locked)

| Phase | Goal | Needs prototype video? |
|-------|------|------------------------|
| **0 — Market intent** | Landing live; measure ≥ $1 paid intent | **No** |
| **1 — Build prototype** | Hardware on desk + film demo | Yes (for KS, not for Phase 0) |
| **2 — Kickstarter** | Submit / pre-launch / live | Yes — KS requires working prototype |
| **3 — Fulfill + OSS** | Ship + public GPLv3 | — |

## Platform choice

| Decision | Choice |
|----------|--------|
| Primary campaign | **Kickstarter** |
| Simultaneous dual launch | **No** |
| After Kickstarter | Late Pledges and/or Indiegogo InDemand |

## Email (Postmark)

| Stream | Use |
|--------|-----|
| Transactional | DOI confirm, $0 welcome, ≥ $1 support receipt |
| Broadcast | Launch invite, updates |

Double opt-in required before Broadcast.

## Pre-launch funnel (`heyeddi.com/projects/doomsday-box`)

```
heyeddi.com hero
        ↓
box.heyeddi.com  ←── doomsday.heyeddi.com
        ↓
  email + amount (USD)
        ├── $0     → lead (curiosity)
        └── ≥ $1   → paid intent (primary KPI) via Stripe
```

### Off-site money

- **Is:** campaign **prep capital** + demand signal ($0 lead / ≥ $1 paid intent).  
- **Is not:** a Kickstarter pledge; does not move the KS progress bar.  
- **Mapping (locked):** `ks-stripe-mapping.md` — disclose totals; ≥ $1 get priority launch email + Super Early Bird email-match when they pledge on KS within 48h.  
- **No** automatic $ off KS pledges.

### KPI

**Paid-intent rate** = (≥ $1 submits) / (all email submits). Email list size is secondary.

## Planned perk references

Shown as planned only — site payment does **not** lock a reward.

| Ref | Planned price |
|-----|---------------|
| Founding Insider | $49 |
| Super EB / Early / KS Special (single LattePanda SKU) | $299 / $329 / $349 |
| Household Duo (2×) | $558 / $618 / $658 (staged; subject to change) |
| Mesh Trio (3×) | $797 / $887 / $947 (staged; subject to change) |
| Tee (optional) | ~$29 / thank-you — **only if campaign success allows** |
| Retail MSRP | $399 |

Single SKU; open options (cooling, base vs add-on NVMe, cable length) TBD. Multi-box packs support **mesh / multi-node** homes. Economics: `campaign-economics.md`. Positioning: `gtm-positioning.md`.

## Domain

| Host / path | Role |
|-------------|------|
| `heyeddi.com/projects/doomsday-box` | **Primary** landing |
| `box.heyeddi.com` | Alias → landing (CNAME / Firebase `box` redirect) |
| `doomsday.heyeddi.com` | Alias → landing |
| heyeddi.com | Hero CTA, `/projects/doomsday-box`, blog post |

## Timeline

1. **Now:** SPA + $0 / ≥ $1 intent collection (no video)  
2. Build prototype + film when hardware ready  
3. KS submit when prototype + video exist  
4. Launch → email paid-intent first, then $0 leads  
5. Fulfill → OSS  

## Out of scope here

Friend-seed signing · exact ad CPA · final KS↔Stripe credit mechanism (tracked as open in payment policy)
