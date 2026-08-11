# Hardware BOM & sourcing

**Last updated:** 2026-07-24  
**Status:** Planning lock — two campaign SKUs; swap $ when OEM quote signs  
**FX planning:** $1 USD ≈ $18 MXN  
**Finance detail:** `.docs/unit-economics-skus.md`

## Platform (locked)

| Item | Decision |
|------|----------|
| CPUs | Intel **N150** primary (N100 OK if cheaper / same quote) |
| Memory SKUs | **Basic = DDR4** · **Premium = DDR5** |
| Storage | **1TB** both SKUs |
| DIY | Keep `box/` software **ARM64-compatible** |
| Networking | Prefer **dual LAN**; else **USB‑ETH dongle included** so every unit has two Ethernet paths |

## SKU quotes (planning)

| SKU | Spec snapshot | OEM box (approx) |
|-----|---------------|-----------------:|
| **Basic** | N150 · DDR4 · 1TB | **$290** |
| **Premium** | N150 · DDR5 · 1TB | **$380** |

## All-in COGS vs pledge (planning)

| Component | Basic (w/ dongle) | Premium (native dual NIC) |
|-----------|------------------:|--------------------------:|
| Raw factory PC | $290 | $380 |
| Packaging + quick-start | $10 | $10 |
| 1m Cat6 | $3 | $3 |
| USB‑ETH dongle | $12 | $0 |
| DDP / import buffer | $30 | $30 |
| **All-in** | **$345** | **$423** |

Backer pays **Kickstarter shipping** (freight). DDP buffer is on us.

**Owner:** founder. Swap table when quote locks; do not cut campaign prices without margin check in `.docs/unit-economics-skus.md`.

## Included in every retail / KS unit (locked)

- Mini PC unit (Basic or Premium as pledged)  
- OEM or 30W-class PSU  
- **1m Ethernet cable (Cat6)**  
- USB‑ETH dongle **if** the board has only one NIC  
- Quick-start guide (EN; ES addendum if time)  
- Matte retail packaging with foam  

## Pricing anchors (locked)

### Basic (DDR4)

| Tier | USD |
|------|-----|
| Super Early Bird (1 box) | $399 (cap 100) |
| Early Bird (1 box) | $429 (soft ~150) |
| Standard (1 box) | $449 |
| Retail MSRP (1 box) | $499 |

### Premium (DDR5)

| Tier | USD |
|------|-----|
| Super Early Bird (1 box) | **$529** (cap **50**) |
| Early Bird (1 box) | **$549** |
| Standard (1 box) | **$579** |
| Retail MSRP (1 box) | **$649** |

### Multi-box (Basic SKU packs)

| Tier | USD |
|------|-----|
| Household Duo Super / Early / Standard | $759 / $819 / $859 |
| Mesh Trio Super / Early / Standard | $1,099 / $1,189 / $1,249 |

Floor: never list **Basic** below $399 or **Premium** below $529 without revisiting fees + all-in COGS.

## Sourcing assumptions (locked until quote)

| Assumption | Value |
|------------|-------|
| Planning MOQ | **50** units first factory order (mix Basic/Premium after KS) |
| Lead time | **6–8 weeks** after deposit |
| Spare / DOA buffer | **2%** extra units in first batch |
| Fulfillment hub | **Zapopan, Jalisco** (self-ship until volume justifies 3PL) |

## Founder actions (not product TBD)

1. Sign OEM quotes for Basic + Premium → paste SKU/MOQ/lead time/NIC count here  
2. Confirm dual-LAN on samples; order dongles only for single-NIC boards  
3. Order friend-seed prototypes if not already on desk  
