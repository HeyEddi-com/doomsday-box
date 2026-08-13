# Design brief: `/projects/doomsday-box` (pre-launch landing)

**Status:** Confirmed 2026-08-13  
**Feature folder:** `pre-launch-landing`  
**Surface:** `heyeddi-tool/hey-eddi-website` · route `/projects/doomsday-box`  
**Register:** brand  
**Related:** `research.md`, `wireframes/desktop-mobile.md`, `../../docs/product/landing-copy-brief.md`, `../../docs/product/gtm-positioning.md`, `../../product.md`

## Feature summary

Single-scroll market-intent landing for the HeyEddi Doomsday Box. Casey joins at $0 or shows paid intent from $1+ without a prototype video. The page must feel like a real aluminum appliance campaign, not a SaaS waitlist template, while staying honest about research pricing and non-pledge Stripe support.

## Audience

- **Primary persona:** Casey (early backer / Kickstarter supporter)  
- **Secondary:** Alex/Morgan as belief builders (pillars), not CTA owners  
- **Route intent:** Curious; may pay $1+ without a demo video · Success: joined or paid intent in under a minute without a fake demo  
- **Direction row:** Evaluator / buyer (homepage) → credibility + clarity  
- **Secondary row:** Umbrel-style product clarity  
- **Differentiation:** One box = cloud + path protection + local Hermes AI; under-$300 Super EB research price; OSS at ship — vs mini-PC DIY and subscription firewalls

## Design signature (this project only)

- **Aesthetic energy:** Calm material honesty (aluminum + stone-moss), campaign-capable without prepper panic  
- **Subject / page job:** The physical Doomsday Box as focused hero object; page job = capture email + amount  
- **Signature moment:** Full-bleed aluminum single-unit chassis (Probe A) with brand as hero-level signal  
- **Aesthetic risk:** Hero stays product-first; secondary control **See other rewards** reveals Duo/Trio/Insider without crowding the first viewport with a store grid  
- **Borrow:** Framework Laptop materials honesty; Umbrel “what it is in five seconds”; KS early-bird clarity without fake scarcity theater  
- **Avoid:** Purple SaaS gradient; cream+terracotta AI default; acid-green dark cyber; hero card grids / badge clusters; leading with remote-access brands  
- **Memorable detail:** Moss CTA on aluminum-forward hero + IBM Plex Serif display (rhyme with appliance `design.md`, not clone Hub/Survival skins)

## Primary user action

Enter email + amount (default $1, allow $0) → **Continue** ($0 DOI list / ≥$1 Stripe).

## Design direction

- **Color strategy:** Restrained — stone canvas, moss accent, aluminum neutrals; optional quiet brass highlight  
- **Scene sentence:** Soft workshop daylight on a matte aluminum mini PC; calm confidence, not bunker fear  
- **Anchors:** Framework · Umbrel · honest KS hardware pages  
- **Explore winner (locked):** **Probe A** — aluminum product thesis hero (see below)  
- **Motion:** One orchestrated hero fade; respect `prefers-reduced-motion`

### What Probe A is

Three visual lanes were generated in shape:

| Probe | Idea |
|-------|------|
| **A (chosen)** | Full-bleed **aluminum appliance** as the first-viewport subject; brand + headline on that plane; calm workshop light |
| B | Type-first editorial (big serif, product small) |
| C | Form-first (email/amount dominate the hero) |

**We chose A:** Casey should instantly see *the box*, not a SaaS waitlist or a wall of type.

## Confirmed layout decisions (2026-08-13)

1. **Hero:** Focused single product (one Doomsday Box). Primary path = **Continue with email + amount** → `#intent`. Secondary control = **See other rewards** (or “See packs”) → `#perks` / expands other planned products (Insider, Duo, Trio) without replacing the hero object.  
2. **Perks:** **Show Duo/Trio** on Phase 0 (with Insider + single-box ladder + retail). Label subject to change; shipping later.  
3. **Direction:** Probe A locked.

## Scope

| Axis | Choice |
|------|--------|
| Fidelity | Production-ready for craft |
| Breadth | One scroll route |
| Interactivity | Shipped-quality form + Stripe/DOI; hero secondary → other rewards |
| Time intent | Ship-ready brief |

## Layout strategy

1. Brand-first full-bleed hero (**one focused product**)  
2. Hero CTAs: Continue → intent · See other rewards → perks  
3. Capability pillars (five verbs; not fake numbered chrome)  
4. OSS honesty  
5. Planned perk ladder **including Duo/Trio**  
6. Intent capture (email + amount)  
7. Disclosure footer  

## Key states

Default · validation · loading · success $0 · success ≥$1 · Stripe cancel · KS button hidden when unset · perks target highlight when arriving from “See other rewards”

## Interaction model

- Hero primary → `#intent`  
- Hero secondary → `#perks` (smooth scroll; optional brief highlight)  
- Continue branches on amount  
- Optional KS pre-launch control only if env set  
- Locale quiet toggle `en`/`es`  
- Skip link; keyboard-complete form

## Content requirements

Lock from `landing-copy-brief.md`. Show full perk table including Duo/Trio. No tunnel brand names. No “under $300” as absolute MSRP without Super EB context.

## Component map

| Region | Build |
|--------|-------|
| Hero | Custom full-bleed focused product; primary Button → #intent; secondary Button/link → #perks |
| Pillars | Text list / simple icon+label row (not Card grid) |
| OSS | Prose block |
| Perks | Table or definition list (single + Duo/Trio + Insider + retail) |
| Intent | Email + number + Button; Message for errors/success |
| Footer | Static disclosure |
| i18n | All user strings |

## Deferred wiring

| UI shipped in craft | Backend / later |
|---------------------|-----------------|
| Full page regions + states | Real LattePanda product photography |
| Perk table incl. Duo/Trio | Final cooling / NVMe / cable length TBD flags |
| KS button slot | `VITE_KICKSTARTER_PRELAUNCH_URL` |
| Amount Continuum UX | Postmark DOI + Stripe CF |
| Hermes claims | Soften to planned if overclaim risk |

## Open questions

None blocking craft.

---

**Next:** `@heyeddi-design craft /projects/doomsday-box`
