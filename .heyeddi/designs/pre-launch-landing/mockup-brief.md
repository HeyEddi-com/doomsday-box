# Mockup brief: Pre-launch landing (HeyEddi Doomsday Box)

Authored from product docs + tailored wireframe. Colors from `.heyeddi/design.md` when present.

## Audience (from product.md)

- **Primary persona:** Casey
- **Mindset:** Curious about the box; deciding whether to leave email or put money down
- **Success feeling:** I understand the product and can join the launch or reserve in under a minute
- **Register:** brand · Direction: `heyeddi-design/reference/audience-design.md`

## Designer read (first impression)

One scroll composition: brand-first hero, dual CTA, then capabilities → OSS honesty → perk table → capture → disclosure footer. No SaaS sidebar, no multi-page nav.

## Layout topology

### Desktop
| Zone | Size / position | Behavior |
|------|-----------------|----------|
| Hero | Full-bleed visual + brand/headline/support | Path into email + amount capture |
| Body | Single column ~720–960px | Sections stacked, one job each |
| Footer | Full width | Disclosure + privacy |

### Mobile
| Zone | Behavior |
|------|----------|
| Hero | Stacked brand → copy → full-width CTAs |
| Body | Same sections, compact perk rows |
| Footer | Disclosure |

## Region map

### Desktop
| Region | What the user sees | Build |
|--------|-------------------|-------|
| Hero | Brand, locked headline, dual CTA | Custom hero, not cards |
| Capabilities | 3 bullets | Simple list |
| OSS | Short honesty block | Text |
| Perks | Planned rewards table | Table / definition list |
| Waitlist / support | Email + amount (default 1, allow 0) + Continue | Form → DOI and/or Stripe |
| Footer | Disclosure | Static · demand-first, no video |

### Mobile
Same regions stacked; CTAs full width.

## Implementation spec

| Concern | Spec |
|---------|------|
| Package | `website/` Vue 3 + Vite |
| Routes | `/` only |
| Email | Double opt-in via Postmark (`postmark-runbook.md`) |
| Pay | Stripe custom amount: $0 skip / ≥ $1 (`stripe-reservation-policy.md`) |
| KPI | `paid_intent` (≥ $1) vs `lead_email` ($0) |
| Video | None required for Phase 0 |
| Copy | Locked in `landing-copy-brief.md` |
| KS button | Only if `VITE_KICKSTARTER_PRELAUNCH_URL` set |
| Anti-patterns | No fake demo video; no reward-lock claims; no multi-route IA |

## Handoff

Wireframe: `wireframe.md` · Product AC: `.heyeddi/docs/product/features/home.md`
