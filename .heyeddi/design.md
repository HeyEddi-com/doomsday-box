---
name: HeyEddi Doomsday Box — Appliance UI
description: >
  On-device dashboard for a privacy-first home appliance that runs in two modes
  from one codebase. Hub mode (box.heyeddi.local / box.local) is the everyday
  personal cloud: calm light surfaces, soft stone ink, moss accent, plain-language
  outcomes for household operators. Survival mode (doomsday.heyeddi.local /
  doomsday.local) is the same power with offline and protection first: deep charcoal
  canvas, brass accent, denser status language for self-hosters. First-run is a
  physical claim ceremony (one-time code from the box), never an open LAN signup.
  Typography is IBM Plex Sans + IBM Plex Serif. Components are PrimeVue Aura
  mapped to semantic tokens. Register is product for claimed routes; brand-calm
  for claim. No purple SaaS chrome, no prepper panic, no founder CLI on the
  primary path.
colors:
  hub-canvas: "#f4f6f3"
  hub-canvas-soft: "#e8ece6"
  hub-ink: "#1a221c"
  hub-muted: "#5c6b62"
  hub-accent: "#3d7a62"
  hub-accent-soft: "#d5e6dc"
  hub-danger: "#a33b3b"
  hub-border: "rgba(26, 34, 28, 0.12)"
  survival-canvas: "#0e1014"
  survival-canvas-soft: "#161a20"
  survival-ink: "#e8e6e1"
  survival-muted: "#9a968c"
  survival-accent: "#c4a574"
  survival-accent-soft: "rgba(196, 165, 116, 0.16)"
  survival-danger: "#e08a8a"
  survival-border: "rgba(255, 255, 255, 0.1)"
typography:
  display-lg: "600 clamp(1.75rem, 4vw, 2.35rem)/1.15 \"IBM Plex Serif\", Georgia, serif"
  display-md: "600 1.5rem/1.2 \"IBM Plex Serif\", Georgia, serif"
  body-md: "400 1rem/1.55 \"IBM Plex Sans\", \"Segoe UI\", sans-serif"
  body-sm: "400 0.875rem/1.5 \"IBM Plex Sans\", \"Segoe UI\", sans-serif"
  label: "500 0.8rem/1.4 \"IBM Plex Sans\", \"Segoe UI\", sans-serif"
  mono: "500 1.15rem/1.2 ui-monospace, \"IBM Plex Mono\", monospace"
  tracking-brand: "0.1em"
rounded:
  sm: "6px"
  md: "10px"
  lg: "16px"
spacing:
  xs: "0.35rem"
  sm: "0.65rem"
  md: "1rem"
  lg: "1.5rem"
  xl: "2.25rem"
  shell-max: "40rem"
  shell-max-wide: "52rem"
components:
  button-primary:
    backgroundColor: "{colors.hub-accent}"
    textColor: "#f4f6f3"
    rounded: "{rounded.md}"
  button-primary-survival:
    backgroundColor: "{colors.survival-accent}"
    textColor: "{colors.survival-canvas}"
  input-claim:
    typography: "{typography.mono}"
    letterSpacing: "0.2em"
    textTransform: "uppercase"
  panel-surface:
    backgroundColor: "{colors.hub-canvas-soft}"
    borderColor: "{colors.hub-border}"
    rounded: "{rounded.lg}"
  shell-brand:
    typography: "{typography.label}"
    letterSpacing: "{typography.tracking-brand}"
    textTransform: "uppercase"
---

# HeyEddi Doomsday Box — Appliance Design System

## Overview

This UI lives on the box. It is not a marketing site and not an enterprise admin console. Two hostnames share one app and flip atmosphere:

| Mode | Hostnames | Job |
|------|-----------|-----|
| **Hub** | `box.*` | Everyday personal cloud. Calm. Light. |
| **Survival** | `doomsday.*` | Offline, protection, resilience first. Dark. Brass. |

First-run setup is a **claim**, not onboarding spam: the owner proves physical presence with a one-time code the browser never invents.

### Key Characteristics

- Dual atmosphere, one IA
- Claim ceremony before any hub chrome
- PrimeVue Aura driven by semantic CSS tokens (no raw hex in Vue)
- Advanced / founder tools collapsed by default
- Verb-first, sovereignty-forward copy (no hype, no panic)
- Lean CPU/RAM: no heavy client frameworks beyond Vue + PrimeVue

## Foundations (always on)

| Foundation | Appliance stance |
|------------|------------------|
| Responsive | Mobile-first; claim form usable at 375px |
| Theme | Hub = light; Survival = dark (`darkModeSelector: .skin-doomsday`) |
| i18n | `en` + `es` string maps in `src/i18n.ts` (locale toggle under Settings → Advanced) |
| a11y | WCAG 2.2 AA contrast; labeled fields; focus rings on controls |
| Reading mode | Optional dyslexia-friendly class later; do not block ship |
| Motion | Prefer `prefers-reduced-motion`; one short enter fade on claim shell |

## Colors

**Token source:** custom semantic `:root` / `.skin-*` variables in `box/dashboard/src/tokens.css` (not OpenProps).

### Hub (everyday)

| Role | Token | Notes |
|------|-------|-------|
| Canvas | `{colors.hub-canvas}` | Soft paper-green grey, not cream `#F4F1EA` |
| Soft surface | `{colors.hub-canvas-soft}` | Panels |
| Ink | `{colors.hub-ink}` | Warm near-black green |
| Muted | `{colors.hub-muted}` | Secondary copy |
| Accent | `{colors.hub-accent}` | Moss; CTAs and brand |
| Danger | `{colors.hub-danger}` | Errors |

### Survival (offline-forward)

| Role | Token | Notes |
|------|-------|-------|
| Canvas | `{colors.survival-canvas}` | Deep charcoal |
| Soft surface | `{colors.survival-canvas-soft}` | Panels |
| Ink | `{colors.survival-ink}` | Warm off-white |
| Accent | `{colors.survival-accent}` | Brass / instrument metal |
| Danger | `{colors.survival-danger}` | Soft rose for errors |

**Aesthetic risk (locked):** Hub is light and Survival is dark. Same routes, opposite weather. Do not “unify” them into one dark admin theme.

## Typography

| Role | Token |
|------|-------|
| Display | `{typography.display-lg}` IBM Plex Serif |
| Body | `{typography.body-md}` IBM Plex Sans |
| Labels / brand eyebrow | `{typography.label}` + `{typography.tracking-brand}` |
| Claim code | `{typography.mono}` wide tracking |

Display serif carries hardware seriousness. Body sans stays readable on small LAN screens. Never Inter/Roboto/system as the brand face.

## Layout

- Claim shell: `{spacing.shell-max}` centered, generous top air, no side nav.
- Claimed shell: `{spacing.shell-max-wide}`, brand eyebrow + mode pill + compact top nav.
- One primary CTA per band (claim: “Claim this box”).
- Whitespace is calm authority, not empty SaaS hero padding.

## Elevation & Depth

| Level | Use |
|-------|-----|
| 0 | Page canvas (gradients only as atmosphere) |
| 1 | Panel / PrimeVue surface with 1px border, no heavy shadow |
| 2 | Focus / modal only if needed later |

Prefer border + soft fill over multi-layer glow.

## Shapes

| Token | Use |
|-------|-----|
| `{rounded.sm}` | Chips, small controls |
| `{rounded.md}` | Inputs, buttons |
| `{rounded.lg}` | Panels |

No pill cluster chrome. Mode pill is the one allowed soft pill.

## Components

| Pattern | PrimeVue / custom | Notes |
|---------|-------------------|-------|
| Primary CTA | `Button` | Accent fill from skin tokens |
| Claim code | `InputText` + `{components.input-claim}` | Uppercase, mono |
| Passwords | `Password` | `feedback=false` for lean UI |
| Errors / success | `Message` | severity mapped to danger/success |
| Advanced | `Accordion` | CLI tips + locale + placeholders |
| Status chips | custom `.pill` | Arch, setup, mode |
| Shell brand | custom `.brand` | `{components.shell-brand}` |

Do not wrap PrimeVue in redundant local components unless we need a third instance of the same pattern.

## Do's and Don'ts

**Do**

- Lead Setup with physical-presence copy and the claim field
- Hide `doombox-*` CLI under Advanced
- Flip Hub/Survival atmosphere from hostname (and optional skin preview later)
- Keep Home’s first line mode-specific (everyday vs offline)

**Don't**

- Show hub nav before claim completes
- Put founder/dev commands on the primary Setup surface
- Use purple gradients, cream+terracotta clusters, or acid neon glow
- Fake step numbers (01/02/03) unless the flow is truly multi-step later
- Card-grid the claim hero

## Responsive Behavior

| Breakpoint | Behavior |
|------------|----------|
| ≤375 | Single column; full-width controls; brand wraps |
| 768 | Claim form max-width comfortable; nav inline |
| 1440 | Shell stays narrow (`shell-max` / `shell-max-wide`); no ultra-wide stretch |

Touch targets ≥44px on primary buttons.

## Decision log

### 2026-08-10: appliance shell + /setup / / /settings (@heyeddi-design polish)

**Context:** First-run and stub dashboard looked like a raw admin form. Owner asked for coherent Hub vs Survival design, Advanced-hidden CLI, and documented style. Critique: `.heyeddi/docs/setup-critique.md`.

**Primary persona:** Morgan on Hub; Alex on Survival. Pattern borrowed: Umbrel clarity + Framework honesty. Memorable detail: light Hub / dark Survival split as the signature.

**We chose:**
- Dual atmosphere (light Hub, dark Survival) with shared IA
- Claim-only chrome until `setup_complete`
- PrimeVue Aura + semantic `tokens.css`
- Advanced accordion for CLI tips, locale, network placeholder
- IBM Plex Sans/Serif via `@fontsource` (offline-safe, no Google CDN)

**Component strategy:**
- Shell → custom `App.vue` (claim vs claimed)
- Setup → `InputText` + `Password` + `Button` + `Message` + `Accordion`
- Home → status panel + mode thesis headline
- Settings → short product sections + Advanced accordion

**We rejected:**
- Single dark theme for both modes
- Leaving CLI tips on the claim form
- Marketing-style hero card collage

**Open questions:** HDMI kiosk browser unit needs a graphical seat on sample hardware; CUPS queue names vary by printer

### 2026-08-13: `/projects/doomsday-box` shape confirmed (@heyeddi-design shape)

**Context:** Refresh pre-launch landing brief after LattePanda single-SKU pricing research and GTM/Hermes docs.

**Primary persona:** Casey. Pattern borrowed: Umbrel product-in-five-seconds + Framework materials honesty. Memorable detail: aluminum full-bleed hero (Probe A) with secondary **See other rewards** into Duo/Trio table.

**We chose:**
- Probe A (aluminum product thesis) over type-first (B) and form-first (C)
- Hero focuses one box; button reveals other planned products/packs
- Show Duo/Trio on Phase 0 perk table
- Intent form below hero (scroll/CTA), not dominating first viewport

**We rejected:**
- Form-dominated hero
- Hiding Duo/Trio until later
- Purple SaaS / prepper panic aesthetics

**Open questions:** none blocking craft

### 2026-08-13: `/projects/doomsday-box` craft (@heyeddi-design craft)

**Context:** Implement confirmed pre-launch brief on `hey-eddi-website` Nuxt route (not appliance dashboard).

**Primary persona:** Casey (early backer). Pattern borrowed: Framework aluminum honesty + Umbrel five-second product clarity. Memorable detail: moss CTA on full-bleed aluminum single-box hero with secondary **See other rewards** into Duo/Trio table.

**We chose:**
- Probe A production craft: concept chassis SVG + workshop light plane (photography deferred)
- Scoped `.doom-landing` moss/stone/aluminum tokens rhyming appliance `design.md` hues
- Five verb pillars (not card collage / not 01-02-03); remote access as quiet trailing note only
- Research perk ladder $299/$329/$349/$399 + Insider + Duo/Trio; intent form below with preserved Stripe/DOI fetch
- en + es i18n for all user strings; `prefers-reduced-motion` on hero/perk highlight

**Component strategy:**
- Hero / pillars / OSS / perks / intent / footer → custom `PreLaunchLanding.vue`
- Pillar marks → compact `FeatureArt.vue` (moss/brass)
- Form → native inputs + existing Cloud Function POST (`doomsdayIntentUrl`)

**We rejected:**
- Purple SaaS mesh / brutalist site chrome for this route
- Basic/Premium dual-SKU table
- Form-first hero and fake demo video

**Open questions:** none (deferred wiring: real LattePanda photography, KS env URL, final cooling/NVMe/cable TBD)
