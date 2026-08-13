# Wireframes: `/projects/doomsday-box`

**Fidelity:** mid-fi markdown  
**Winning explore lean:** Probe A (aluminum thesis) + Probe C capture discipline (intent reachable without hunting)  
**Probes:** `probe-a-aluminum-thesis.png`, `probe-b-editorial-type.png`, `probe-c-intent-first.png` (session assets)

## Desktop (1440) — default

```
+--------------------------------------------------------------------+
| [skip]  HeyEddi · Doomsday Box                    [en|es] (quiet)  |
+--------------------------------------------------------------------+
| FULL-BLEED HERO (aluminum appliance plane — edge to edge)          |
|                                                                    |
|   HEYEDDI DOOMSDAY BOX          (brand = hero-level)               |
|   Your network. Your data.                                         |
|   Offline when it matters.                                         |
|   Support: stream · compute · AI · offline · protect —             |
|   open source when units ship.                                     |
|                                                                    |
|   [ Continue with email + amount ]  → #intent                      |
|   [ See other rewards ]             → #perks                       |
+--------------------------------------------------------------------+
| #capabilities  Built for sovereignty                               |
|   Stream | Compute | Local AI (Hermes) | Offline | Network         |
|   (one column or 5 text pillars — NOT card collage; no 01/02/03)   |
|   Remote access: do NOT lead; optional later line, no brands       |
+--------------------------------------------------------------------+
| #oss  Pay for speed and voice, not a permanent software lock       |
+--------------------------------------------------------------------+
| #perks  Planned Kickstarter rewards · Subject to change            |
|   Insider $49 | Super $299 | Early $329 | KS $349 | Retail $399    |
|   Duo / Trio rows compact; shipping charged later note             |
+--------------------------------------------------------------------+
| #intent  Show us the demand                                        |
|   [ email ]  [ amount USD default 1 ]  [ Continue ]                |
|   Micro: $0 list · ≥$1 prep capital · not a KS pledge              |
|   (hidden) [ Notify me on Kickstarter ] if env set                 |
+--------------------------------------------------------------------+
| footer  disclosure · privacy@ · Postmark · Stripe · box alias      |
+--------------------------------------------------------------------+
```

**Primary action:** Continue (email + amount)  
**PrimeVue / Nuxt map:** custom hero; `InputText`/`InputNumber` equivalents; primary Button; DataTable or definition list for perks; Message for errors

## Mobile (375) — stack order

1. Brand  
2. Hero visual (full bleed, shorter crop)  
3. Headline + support  
4. Continue (scroll to #intent or sticky secondary)  
5. Pillars (stacked verbs)  
6. OSS honesty  
7. Perks (compact rows)  
8. Intent form (full-width fields + Continue)  
9. Footer disclosure  

Touch targets ≥44px; no horizontal scroll on perks (wrap rows).

## States

| State | Design |
|-------|--------|
| Default | Hero + empty form |
| Validation | Inline email / amount errors |
| Loading | Continue disabled + busy |
| Success $0 | “You’re on the list” + check email (DOI) |
| Success ≥$1 | Receipt path: thanks; not a KS pledge |
| Stripe cancel | Return to #intent with calm message |
| Empty perks | N/A (static planned table) |
| KS button absent | Hide control entirely |

## Anti-patterns (wire)

- No Features/Pricing/Sign-in multi-nav  
- No hero card grid / badges / KPI strip  
- No fake live demo video required  
- No Basic/Premium dual SKU chrome  
