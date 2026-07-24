# Wireframe: Pre-launch landing (HeyEddi Doomsday Box)

Fidelity: wireframe (layout only).  
Route: `/` · Package: `website/`  
Purpose: Single-page market intent — email + amount ($0 lead / ≥$1 paid intent) + planned perks + disclosure. No prototype video.

## Desktop (ASCII)

```
+------------------------------------------------------------------+
| HeyEddi Doomsday Box                                              |
+------------------------------------------------------------------+
|  [full-bleed visual / product silhouette]                         |
|                                                                   |
|  HeyEddi Doomsday Box                                             |
|  Your network. Your data. Offline when it matters.                |
|  One low-power box for personal cloud, inline protection,         |
|  and local AI — open source when units ship.                      |
|                                                                   |
|  [ Continue with email + amount ]                                  |
|  (amount default $1, allow $0, allow ≥$1 → ∞)                       |
+------------------------------------------------------------------+
|  What it does                                                     |
|  • Personal cloud   • Inline protection   • Local AI              |
+------------------------------------------------------------------+
|  Pay for speed and voice — not a permanent software lock          |
|  (OSS at ship / GPLv3)                                            |
+------------------------------------------------------------------+
|  Planned Kickstarter rewards (subject to change)                  |
|  | Insider $49 | Early Bird $399 | Standard $449 | Retail $499 |  |
+------------------------------------------------------------------+
|  Waitlist / support: [ email ] [ amount USD (default 1, allow 0) ] [ Continue ]|
|  (hidden until set) [ Notify me on Kickstarter ]                  |
+------------------------------------------------------------------+
|  Footer: demand-first (no video yet) · disclosure · privacy@      |
|  Postmark · Stripe · box.heyeddi.com                              |
+------------------------------------------------------------------+
```

## Mobile

```
HeyEddi Doomsday Box
[visual]
Headline (2 lines)
Support (2 lines)
[ Continue ]
amount default 1, allow 0
What it does (stacked bullets)
OSS honesty (short)
Perk table (scroll)
Email + join
Reserve + toggle
Footer disclosure
```

## Regions

| Region | Desktop | Mobile | Notes |
|--------|---------|--------|-------|
| Brand hero | Brand + headline + support + dual CTA on visual | Stacked | No nav links to other pages |
| Capabilities | One section, 3 bullets | Stack | Not card chrome if avoidable |
| OSS honesty | One short block | Same | |
| Perks | Table | Compact rows | Label subject to change |
| Capture | Email + reserve mid/lower page | Same | DOI microcopy |
| Footer | Disclosure | Same | Required legal points |

## Anti-patterns

- No Features/Pricing/Sign-in nav (not a SaaS marketing multi-page)
- No floating badge clusters or stat strips in hero
- No multi-route IA
