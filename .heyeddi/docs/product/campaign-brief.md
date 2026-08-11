# Kickstarter campaign brief

**Last updated:** 2026-07-23  
**Status:** Planning locked for when we enter KS phase  
**Now:** Phase 0 market intent — **no prototype video required**

**Related:** `crowdfunding-strategy.md`, `hardware-bom.md`, `stripe-reservation-policy.md`

## Basics (locked)

| Field | Value |
|-------|-------|
| Project title | HeyEddi Doomsday Box — Sovereign Home Hub |
| Category | Technology → Gadgets |
| Location | Zapopan, Jalisco, Mexico |
| Duration | **30 days** |
| Funding model | All-or-nothing |
| Currency | **USD** |

## Funding goal (locked)

| Tier | Amount | Role |
|------|--------|------|
| **Public goal** | **$35,000 USD** | Minimum honest batch + fees buffer (between micro and moderate scenarios) |
| Stretch 1 | $75,000 USD | Aligns with moderate Scenario B planning |
| Stretch 2 | $150,000 USD | Viral / inventory headroom — only announce if Stretch 1 hit |

Public goal is **$35k**, not vanity. Revisit only if locked OEM quote proves fulfillment impossible at that raise.

## Prototype / review readiness (Kickstarter phase — not Phase 0)

| Item | When required |
|------|----------------|
| Working prototype on desk | Before KS **submit** |
| Demo video | **Landing now:** concept graphics + table B-roll (`video-creative.md`). **KS submit later:** must show working prototype for claimed features |
| Risks & challenges | KS page |
| Shipping table | KS page (estimates below) |
| Disclose off-site support totals | KS launch (Stripe ≥ $1 sum) |

**Phase 0 (now):** ship landing + measure paid intent. Build hardware/video in parallel or after demand signal is clear.

## Rewards (locked for campaign page)

Kickstarter is the **market test**: Basic (DDR4) vs Premium (DDR5). Same N150 + 1TB story; memory (and price) is the upgrade.

### Digital

| Reward | Price | Limit | Est. delivery |
|--------|-------|-------|---------------|
| Founding Insider (digital) | $49 | Unlimited soft | Month 2–3 after campaign end |

### Single box — Basic (N150 · DDR4 · 1TB)

| Stage | Price | Limit | Est. delivery |
|-------|-------|-------|---------------|
| Super Early Bird | **$399** | **100** | Month 4–6 after campaign end |
| Early Bird | **$429** | Soft ~150 | Month 4–6 after campaign end |
| Standard | **$449** | — | Month 4–6 after campaign end |

### Single box — Premium (N150 · DDR5 · 1TB)

| Stage | Price | Limit | Est. delivery |
|-------|-------|-------|---------------|
| Super Early Bird | **$529** | **50** | Month 4–6 after campaign end |
| Early Bird | **$549** | Soft ~75 | Month 4–6 after campaign end |
| Standard | **$579** | — | Month 4–6 after campaign end |

Every hardware reward includes **1m Cat6**; USB‑ETH dongle included if that board has only one NIC (two Ethernet paths required).

### Multi-box mesh packs (Basic SKU, staged)

| Pack | Super EB | Early | Standard | Soft limit (Super EB) | Snapshot |
|------|----------|-------|----------|------------------------|----------|
| Household Duo (2× Basic) | **$759** | **$819** | **$859** | ~25 | Saves ~$40 vs 2 singles; multi-node mesh |
| Mesh Trio (3× Basic) | **$1,099** | **$1,189** | **$1,249** | ~15 | Saves ~$100 vs 3 singles; multi-node mesh |

Premium multi-box packs: TBD after mix signal.

### Context (not a KS reward)

| Item | Price |
|------|-------|
| Retail MSRP Basic (1 box) | **$499** |
| Retail MSRP Premium (1 box) | **$649** |

### Add-ons & thank-you merch (conditional)

| Item | Planned price | Who | Notes |
|------|---------------|-----|-------|
| **Doomsday / Hub tee** | **~$29** add-on (TBD) | Optional KS add-on if offered | **Only if campaign success / margins allow** — decide after funding (or as a stretch). Soft merch; ships with or after hardware wave |
| **Intent thank-you tee** | Included (not a discount) | Segment A (≥ $1) who also pledge, **if we green-light merch** | Same gate: not promised on the landing as guaranteed. Size survey only after we commit |

Make-good if Super Early Bird oversubscribes: prefer next hardware tier / clear ops message first; tee only if merch is green-lit.

Default v1 add-ons without merch: Duo/Trio packs only. Tee is a **success-dependent option**, not a locked deliverable.

## Shipping (locked planning estimates)

**Freight:** backer pays via Kickstarter shipping table.  
**DDP / import:** on us for offered regions — **~$30/unit** planning buffer inside product COGS (see `hardware-bom.md`). Not a license to eat unlimited EU VAT; revisit broker quotes before launch.

| Region | Shipping (USD) | Notes |
|--------|----------------|-------|
| Mexico | **$25** | Domestic freight |
| United States | **$45** | Freight; DDP buffer in COGS |
| Canada | **$55** | Freight; DDP buffer in COGS |
| EU / UK | **$65** | Freight; confirm DDP/VAT with broker before promising |
| Rest of world | **Not offered at launch** | Add post-campaign if demand |

## Risks & challenges (locked outline for KS)

- OEM lead times and DDR4 vs DDR5 board availability  
- Import/customs variance vs ~$30 DDP buffer / all-in COGS in `hardware-bom.md`  
- Software beta quality before public OSS cut  
- Home network topologies (AP vs inline bridge) vary by household  
- Shipping delays outside our control  
- Single-NIC boards requiring dongle QC  

## Post-campaign

Kickstarter Late Pledges first; Indiegogo InDemand only **after** KS ends if needed. No simultaneous dual live campaigns.

## Founder calendar (targets)

| Milestone | Target |
|-----------|--------|
| Market-intent landing live | **Now** (no video) |
| Decide KS money-mapping (A/B/C/D) | Before KS launch |
| Prototype + video | Before KS submit |
| KS submit / review | When prototype ready |
| Pre-launch page live | After KS approval |
| Launch | Email ≥ $1 payers first, then $0 leads |
