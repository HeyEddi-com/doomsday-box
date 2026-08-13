# Kickstarter campaign economics (research)

**Last updated:** 2026-08-13  
**Status:** Research / planning draft — **re-do fees, FX, BOM, and attachment assumptions before buying or confirming accounting**  
**FX planning:** $1 USD ≈ **$19 MXN**  
**Related:** `hardware-bom.md`, `campaign-brief.md`

## 200-unit campaign revenue projection

Assuming full sell-out of the initial **200-unit** manufacturing batch (single LattePanda SKU):

| Tier | Units × price | USD |
|------|---------------|----:|
| Super Early Bird | 50 × $299 | $14,950 |
| Early Bird | 100 × $329 | $32,900 |
| Kickstarter Special | 50 × $349 | $17,450 |
| **Gross campaign revenue** | Average pledge ~$326.50 | **$65,300** |

Public funding **goal remains $35,000 USD** (honest minimum batch + buffer) — see `campaign-brief.md`. Sell-out projection is a capacity scenario, not the public goal.

## Platform fees & payout waterfall (research)

| Line item | Calculation | Amount (USD) |
|-----------|-------------|-------------:|
| Gross raised | Total KS pledges | **+$65,300.00** |
| Kickstarter platform fee | Flat 5.0% | −$3,265.00 |
| Payment processing | ~3.5% + transaction fees | −$2,285.50 |
| Uncollectible pledge buffer | ~3.0% (expired/declined cards) | −$1,959.00 |
| **Net cash deposited** | Actual liquid capital | **+$57,790.50** |

Reconfirm current Kickstarter + processor fee schedules before lock.

## Manufacturing & profit reconciliation (research)

| Financial stage | USD | MXN (~19.0 FX) |
|-----------------|----:|---------------:|
| Liquid capital received | +$57,790.50 | ~$1,098,000 |
| 200-unit landed BOM ($240/unit) | −$48,000.00 | −$912,000 |
| **Base hardware net profit** | **+$9,790.50** | **~$186,000** |
| Add-on upsell profit (40% attachment rate) | +$5,160.00 | +$98,000 |
| **Total take-home net profit** | **+$14,950.50** | **~$284,000** |

Add-on mix assumes BackerKit attach of NVMe / UPS HAT per `hardware-bom.md`. Attachment rate and mix are **unverified**.

## Shipping & logistics policy (research)

| Policy | Detail |
|--------|--------|
| Campaign pledge price | **Excludes shipping** (“price + shipping charged later”) |
| Collection | Shipping, local taxes, and duties calculated and collected in **BackerKit ~30 days before dispatch** |
| Mexican import credit | Commercial import (*Pedimento A1*): 16% import IVA treated as **100% creditable** (*IVA a favor*); net tax liability planning ≈ DTA processing fee (~**$3/unit**) — **verify with broker / accountant** |

Supersedes prior planning that put ~$30/unit DDP buffer inside product COGS and collected freight on the Kickstarter shipping table at pledge time. Regional shipping rate cards remain TBD in BackerKit.

## Owner checklist before accounting lock

1. Re-quote landed BOM (`hardware-bom.md`)  
2. Re-run fee % against live KS + processor docs  
3. Confirm Pedimento / IVA credit with Mexican counsel or accountant  
4. Lock cable length, cooling, and base-vs-add-on storage (affects margin)  
5. Do not issue factory PO until this sheet is marked **quote-locked**  
