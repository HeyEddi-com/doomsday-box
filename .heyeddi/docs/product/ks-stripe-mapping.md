# Stripe → Kickstarter mapping (locked)

**Last updated:** 2026-07-23  
**Status:** Locked  
**Source of truth for payments:** also `stripe-reservation-policy.md`

## What “toward the Kickstarter” means

Stripe money **never** appears on the Kickstarter progress bar.  
It **does** fund campaign prep (ads, prototypes, packaging, fees, runway for the raise).  
On the KS page we **disclose** the total collected off-platform.

That is the economic mapping: **prep capital → campaign success**, not pledge injection.

## Backer-facing mapping (locked)

| Pre-launch action | What they get at Kickstarter |
|-------------------|------------------------------|
| **$0** lead (DOI confirmed) | Launch invite with everyone else |
| **≥ $1** paid intent | (1) **Priority launch email** (send ≥1 hour before general list) (2) **Intent Supporter** flag in our DB (3) **Same-email early-bird hold**: if they pledge **Super Early Bird** within **48 hours of KS launch**, we honor eligibility against the 100-cap by matching Stripe email ↔ KS backer email (ops checklist) (4) **Thank-you tee only if** we green-light merch after campaign success (not promised on the landing) |
| **≥ $25** paid intent | Everything above + permanent credit in Founding Supporters / CONTRIBUTORS **if they also back any KS reward** |
| Any amount | Still must **pledge on Kickstarter** for hardware/digital rewards |

### Explicitly not offered

- No automatic “$N off your Kickstarter pledge”  
- No transferring Stripe balance into a KS pledge  
- No guaranteed Super Early Bird without a KS pledge  
- No claiming site payment *is* a Kickstarter donation  
- **No public “Invest” CTA** on the landing (no equity, profit-share, or securities offer via the website). Prototype float capital stays private if pursued.  

## Ops runbook at launch

1. Export `paid_intent` emails (`amount_cents >= 100`), DOI confirmed.  
2. Segment A (≥ $1): send launch mail first.  
3. Segment B ($0): send ~1 hour later (or same day after Segment A).  
4. During first 48h: maintain sheet of Super Early Bird KS backers; if oversubscribed, prioritize emails present in Segment A (make-good: next hardware tier / clear ops; tee only if merch green-lit).  
5. **After funding:** decide whether margins support tee add-on / intent thank-you tees; if yes, size survey then ship with or after hardware.  
6. On KS project story: one sentence + running total of off-platform support (update at launch and at close).  

## Why not coupons / BackerKit (for now)

- Coupons (old Option C): easy to mishandle and confuses “credit.”  
- **Merch (tee)** is a **success-dependent** thank-you / add-on option, not a locked landing promise.  
- BackerKit (old Option D): add later only if volume justifies.  

We can revisit after first campaign; do not promise coupon credit or a guaranteed shirt on the landing.
