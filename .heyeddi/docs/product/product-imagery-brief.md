# Product imagery brief — sample PCs (Phase 0)

**Last updated:** 2026-08-10  
**Status:** Locked for shoot — execute with sample chassis now  
**Scope:** Real stills + table B-roll (not OS/Docker golden images)  
**Related:** `video-creative.md`, `landing-copy-brief.md`, `campaign-brief.md`, `hardware-bom.md`

## Decisions (2026-08-10)

| Decision | Value |
|----------|-------|
| Primary goal | Phase 0 landing / ads creative |
| Formats | **Stills + short B-roll** (same shoot) |
| Hardware | Sample PCs on hand = **early hardware / prototype chassis** |
| Retail finish | Do **not** imply final matte packaging or branded shell unless that is what you have |
| Demo claims | **No** fake live dashboard, boot UI, or “working demo” until software boots on camera |
| Shooter | Founder phone/camera OK if checklist below is followed |
| Reuse | Landing first → ads cuts → KS video “table” chapter later |

## Honesty captions (must ship with assets)

**On-page / on-video (default):**

> Early hardware. Concept graphics show how it will work. Working demo comes with the Kickstarter prototype.

**Still alt text / file metadata:**

> HeyEddi Doomsday Box sample chassis — early hardware, not final retail unit.

**Forbidden language near these assets:** “working demo,” “live dashboard,” “shipped product,” “final design” (unless that claim is true on camera).

## Shot list (must-have)

Keyed to the locked 45–75s cut in `video-creative.md` (table B-roll = 15–20s). Prefer landscape 16:9 for video; shoot stills in both landscape and a few vertical 4:5 for ads.

| ID | Shot | Still | Video | Notes |
|----|------|-------|-------|-------|
| T1 | Hero desk presence | ✓ | ✓ 3–5s hold | Box centered on clean desk; one composition; brand-adjacent props only (mug, notebook) — no clutter |
| T2 | Scale vs hand | ✓ | ✓ | Hand rests near / lifts briefly — shows size without “unboxing theater” |
| T3 | Scale vs coffee mug | ✓ | ✓ | Same lighting family as T1 |
| T4 | Front / face | ✓ | — | Straight-on; no heavy vignette |
| T5 | ¾ angle (primary product still) | ✓ | slow push-in | Default landing still if only one image ships |
| T6 | Rear / ports cluster | ✓ | ✓ | Ethernet ×2 (or 1 + dongle), HDMI, USB, power — label in edit if dongle is temporary |
| T7 | Side profile thickness | ✓ | — | Slimness / footprint |
| T8 | Dual-path story | ✓ | ✓ | Cable in WAN-ish port + LAN out (or AP mode: antenna / Wi‑Fi stick if present) — **do not** show a lit fake UI |
| T9 | Power brick + Cat6 in frame | ✓ | — | Accessory honesty; dongle if single-NIC sample |
| T10 | Quiet idle presence | — | ✓ 5s | LEDs only if real; no screen mirror of unfinished software |

### Nice-to-have (same session)

| ID | Shot | Notes |
|----|------|-------|
| N1 | Two chassis side-by-side | Basic vs Premium story later (DDR4 vs DDR5) — only if both samples available |
| N2 | Soft packaging / foam (if any) | Honest “sample packaging” if not retail |
| N3 | Desk + router / mesh node context | Suggests network role without claiming mesh software works |

### Explicitly out of scope this shoot

- Photoreal CGI pretending to be the final retail box  
- Screen recordings of features that do not boot yet  
- Overlay badges, fake “AI online” chips, or promo stickers on the hero frame  
- Claiming N150/DDR5/1TB on camera unless that exact sample is labeled in caption when specs differ

## Capture checklist (shoot day)

### Before record

- [ ] Wipe fingerprints; matte surfaces preferred over glossy glare  
- [ ] Note sample SKU on a card off-camera: CPU (N100/N150), RAM gen, NIC count, serial/label photo for your records  
- [ ] Decide hero surface: wood desk or neutral mat — avoid busy patterns  
- [ ] White balance lock; disable aggressive “beauty” / HDR if it invents glow  
- [ ] Phone: 4K or highest stills; stabilize (tripod or lean); lock exposure on the chassis  
- [ ] Soft key light 45°; fill from opposite; avoid mixed color temps  

### Framing

- [ ] Leave headroom for website crop (hero may crop bottom/sides)  
- [ ] Keep the box as the only hero subject — one composition, not a dashboard of props  
- [ ] Scale reference in at least two shots (hand + mug)  
- [ ] Ports readable at 1080p; shoot a tighter crop of the port row if needed  

### Video specifics

- [ ] 24 or 30 fps; shutter ~180° rule if controllable  
- [ ] Moves: slow push-in, slow orbit 15–20°, static holds — no whip pans  
- [ ] Record 3–5s pads before/after each move for edit  
- [ ] Room tone 10s if you might add VO later  

### After shoot

- [ ] Pick selects the same day (fatigue fades detail)  
- [ ] Name files per Asset handoff below  
- [ ] Write one-line honesty caption into a `CAPTIONS.txt` next to the folder  
- [ ] Do **not** upscale/AI “finish” the chassis into a fake retail shell  

## Asset handoff

### Where assets live

| Location | Role |
|----------|------|
| Local working (founder) | `~/Media/heyeddi/doomsday-box/sample-pcs-2026-08/` (or equivalent) — masters + selects |
| This repo (optional small refs) | `.heyeddi/docs/product/assets/imagery/` — **web-optimized selects only** (no multi‑GB masters) |
| Marketing site | `heyeddi-tool/hey-eddi-website` — route `/projects/doomsday-box` media (canonical consumer) |

Do **not** commit raw 4K masters into `heyeddi-doomsday-box` git.

### Naming

```
ddbox-sample-{YYYYMMDD}-{shotId}-{still|clip}-{n}.{jpg|png|mp4|mov}
```

Examples: `ddbox-sample-20260810-T5-still-01.jpg`, `ddbox-sample-20260810-T6-clip-01.mp4`

### Website consumption (Phase 0)

| Placement | Asset | Notes |
|-----------|-------|-------|
| Hero visual (optional) | T5 still **or** muted T1/T5 loop | Must not overpower brand + locked headline (`landing-copy-brief.md`) |
| Below-fold “See the direction” | B-roll cut or still strip | Caption from Honesty section |
| Ads | T5 + T2/T3 | Same honesty line in ad body |
| KS later | Table chapter from T1–T10 | Add working prototype chapter before submit |

### Deliverable package (definition of done for this shoot)

1. ≥ 6 selects covering T1, T2 or T3, T5, T6, T8, T9  
2. ≥ 20s usable B-roll (can be concatenated holds)  
3. `CAPTIONS.txt` with honesty line + sample SKU notes  
4. One recommended **hero still** called out (filename)  
5. Copy path sent for website PR (hey-eddi-website), not assumed merged here  

## KS honesty bar (review)

| Claim | Phase 0 with this shoot | KS submit |
|-------|-------------------------|-----------|
| Real mini-PC chassis on desk | ✓ | ✓ |
| Ports / dual Ethernet path visible | ✓ | ✓ |
| Concept motion for cloud / AI / protection | ✓ if labeled Concept | ✓ if labeled; plus functional proof for promised features |
| Software features working on camera | ✗ until true | Required for claimed features **or** explicit “not built yet” |
| Final retail packaging / shell | Only if you have it | Prefer final or clearly “prototype enclosure” |

**Verdict:** This shoot is **sufficient for Phase 0 landing** when captions stay honest. It is **not** by itself Kickstarter Trust & Safety complete.

## Shoot-day one-pager (print)

1. Clean desk → T1 hero hold  
2. Hand + mug scale → T2, T3  
3. ¾ product still → T5  
4. Ports + dual-path cables → T6, T8  
5. PSU + Cat6 (+ dongle if needed) → T9  
6. Quiet idle clip → T10  
7. Write captions → pick hero still → hand off to website  

## Open questions (non-blocking)

Fill when known; do not block the shoot:

- Exact sample CPU / RAM / NIC per unit  
- Whether any sample matches Premium (DDR5) for N1  
- Preferred hero surface (wood vs mat) for brand continuity with heyeddi.com
