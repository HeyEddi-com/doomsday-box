# Hardware BOM & sourcing

**Last updated:** 2026-08-13  
**Status:** Research / planning draft — **re-quote OEM, freight, and customs before buying or confirming accounting**  
**FX planning:** $1 USD ≈ **$19 MXN** (research; reconfirm)  
**Related:** `campaign-economics.md`, `campaign-brief.md`, `local-ai-hermes3.md`

Supersedes 2026-07 Basic (DDR4) / Premium (DDR5) dual-SKU planning.

## Platform (research target)

| Item | Decision |
|------|----------|
| Board | **LattePanda IOTA (DFR1227)** — Intel N150, 16GB LPDDR5, 128GB eMMC, RP2040 MCU |
| SKU model | **One retail / KS SKU** (no Basic/Premium split) |
| Storage | Base eMMC; **1TB/2TB NVMe** via M.2 HAT (campaign add-on / include TBD) |
| Networking | **Always two Ethernet paths** (native + USB 3.2 → 2.5G LAN dongle if needed) |
| DIY | Keep `box/` software **ARM64-compatible** |
| Open options | Active cooling, whether extra drive is included by default — **TBD before lock** |

## Landed BOM (research — 200-unit OEM batch)

*Target production batch: 200 units via direct OEM factory sourcing. Unit costs are research estimates only.*

| Component / subsystem | Specs | Unit OEM cost (USD) |
|-----------------------|-------|--------------------:|
| LattePanda IOTA (DFR1227) | N150 · 16GB LPDDR5 · 128GB eMMC · RP2040 | $185.00 |
| Custom aluminum chassis | Anodized extruded shell + CNC front/rear panels | $12.00 |
| USB 3.2 → 2.5G LAN dongle | Realtek RTL8156B (2nd LAN for WAN/LAN split) | $9.00 |
| M.2 NVMe expansion HAT | PCIe 16-pin FPC ribbon HAT for 1TB/2TB AI storage | $8.00 |
| Hardware control interface | 0.96" OLED + heavy-duty toggle / killswitch | $4.00 |
| Power adapter | 30W USB-C PD 15V (US/EU/UK plugs) | $8.00 |
| Packaging & retail box | Printed box, EPE foam, start guide | $4.00 |
| Bulk freight & customs | Air freight to GDL + DTA handling | $10.00 |
| **TOTAL LANDED BOM** | Complete retail appliance unit | **~$240.00** |

**Not yet in table (TBD cost / include):** 2× Ethernet cables (length TBD — not locked to 1m); optional active cooling; pre-loaded NVMe drive (see add-ons).

## Included in every retail / KS unit (planning)

- LattePanda IOTA appliance in aluminum chassis  
- OLED status + physical control / killswitch  
- Dual Ethernet path (board + dongle as required)  
- **2× Ethernet cables** (length TBD; revisit before price lock)  
- OEM / 30W-class USB-C PD PSU  
- Quick-start guide (EN; ES addendum if time)  
- Matte retail packaging with foam  

## Pricing anchors (research)

Sub-$350 campaign tiers aim at impulse / enthusiast buy; **revisit after cooling / storage / cable decisions**.

| Pricing tier | Volume cap | Retail price (USD) | Landed BOM | Net gross margin ($) | Margin (%) | Campaign role |
|--------------|------------|-------------------:|-----------:|---------------------:|-----------:|---------------|
| Super Early Bird | 50 | **$299** | $240 | +$59 | 19.7% | Day-1 funding velocity |
| Early Bird | 100 | **$329** | $240 | +$89 | 27.0% | Day 2–5 velocity |
| Kickstarter Special | 50 | **$349** | $240 | +$109 | 31.2% | Main 30-day volume |
| Post-launch MSRP | Web store | **$399** | $240 | +$159 | 39.8% | D2C retail |

Pledge prices **exclude shipping** — see `campaign-economics.md` (BackerKit collection).

### Multi-box packs (recalculated from single SKU — subject to change)

| Pack | Super EB | Early | KS Special | Soft limit (Super EB) | Snapshot |
|------|---------:|------:|-----------:|----------------------:|----------|
| Household Duo (2×) | **$558** | **$618** | **$658** | ~25 | ~$40 off 2 singles; mesh |
| Mesh Trio (3×) | **$797** | **$887** | **$947** | ~15 | ~$100 off 3 singles; mesh |

Floor: do not list single box below **$299** without revisiting fees + landed BOM in `campaign-economics.md`.

## High-margin pledge-manager add-ons (BackerKit — research)

| Add-on | Price | BOM (est.) | Net | Notes |
|--------|------:|-----------:|----:|-------|
| 1TB NVMe (pre-loaded local AI) | +$89 | ~$50 | +$39 (43.8%) | `hermes3:8b`, `qwen2.5-coder:7b`, security fine-tunes — see `local-ai-hermes3.md` |
| Doomsday Battery UPS HAT (≈8h) | +$59 | ~$25 | +$34 (57.6%) | Dual 18650 + auto-shutdown daemon |

Whether the NVMe is **included** in base SKU vs add-only: **TBD**.

## Sourcing assumptions (research until quote)

| Assumption | Value |
|------------|-------|
| Planning batch | **200** units first factory order |
| Lead time | Reconfirm with OEM (prior planning was 6–8 weeks after deposit) |
| Spare / DOA buffer | **2%** extra units in first batch |
| Fulfillment hub | **Zapopan, Jalisco** (self-ship until volume justifies 3PL) |

## Founder actions (not product TBD)

1. Re-quote LattePanda IOTA + chassis + dongle + HAT + OLED kit → replace table above  
2. Decide: active cooling; base vs add-on NVMe; Ethernet cable length + cost  
3. Confirm dual-LAN on samples; QC dongle path  
4. Order friend-seed / prototype units if not already on desk  
5. Re-run unit economics in `campaign-economics.md` before any purchase PO  
