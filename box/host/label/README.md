# Factory / sample labels

**Last updated:** 2026-08-11

Each unit mints its own claim PIN. You label **after** mint, on **that** chassis.

## What goes on the sticker

| Field | Why |
|-------|-----|
| Product name | Customer recognition |
| SKU / product number | SKU, warranty, replacements |
| Model (N100 / N150 / ARM64) | Hardware variant |
| **HeyEddi S/N** (`HHDB-…`) | Primary barcode / support id (datestamp + 4 chars) |
| **OEM serial** | Matches the serial printed on the bare chassis / motherboard |
| Claim PIN | First-run anti-hijack (also in QR) |
| Manufacture date | Batch / RMA |
| MAC (when present) | Network identity |

**HeyEddi serial format:** `HHDB-YYYYMMDDTHHMMSSZ-XXXX`  
Example: `HHDB-20260811T062901Z-K7MP`  
Assigned once on first `doombox-export-claim-label` and kept in `/mnt/storage/compose/BOX_ID` (+ `OEM_SERIAL`, `identity.json`).

**Not on the sticker:** dashboard admin password, SSH keys, ledger path.

## Codes

- **Code128 (ZPL):** HeyEddi `HHDB-…` serial — scan into inventory (`doombox-print-claim-label` → CUPS raw)
- **QR (ZPL + PNG):** claim PIN (+ HHDB + OEM + setup hint)

## Print

```bash
sudo doombox-export-claim-label
sudo DOOMBOX_LABEL_PRINTER=zebra doombox-print-claim-label
# or open …/labels/<SERIAL>/label.html and print from a browser
```

## Station flow

1. Boot unit; start compose once so `SETUP_PIN.txt` exists.
2. Optional: install `qrencode` on the box (`apt-get install -y qrencode`) for PNG art in HTML.
3. Install product identity once per image:
   ```bash
   sudo mkdir -p /etc/doombox
   sudo cp conf/product.env.example /etc/doombox/product.env
   # edit PRODUCT_SKU / PRODUCT_MODEL if needed
   ```
4. Export:
   ```bash
   sudo doombox-export-claim-label
   ```
5. Print:
   - **Office / inkjet:** open `…/labels/<SERIAL>/label.html` → Print at 100% scale (100×50 mm card).
   - **Thermal (Zebra etc.):** send `label.zpl` to the printer (`lp -d Zebra -o raw label.zpl` or vendor tool).
6. Stick on **that** chassis (or sealed bag card tied to that S/N).
7. Next unit → repeat (new PIN, new folder).

## Reprint

`meta.json` in the label folder has every field. Do not reuse a PIN on a different serial.
