# Market-intent payment policy (Stripe)

**Last updated:** 2026-07-23  
**Applies to:** `heyeddi.com/doomsday-box` waitlist / paid intent  
**Status:** Locked  
**KS mapping detail:** `ks-stripe-mapping.md`

## Phase goal

Collect **market intent** on the landing (graphics + table B-roll OK).  
Kickstarter submit still needs a working prototype later — see `video-creative.md`.

## Intent ladder (locked)

| Amount | Meaning | Metric |
|--------|---------|--------|
| **$0** | Curiosity — email only | Lead |
| **≥ $1 USD** | Definitive market intent | **Paid intent** (primary KPI) |
| **$1 → ∞** | Custom amount | Paid intent + prep capital |

## UI (locked)

- Email required  
- Amount USD: default **$1**, allow **$0**, allow **≥ $1 → ∞**  
- CTA: **Continue** / **Support the campaign**

## What payers get (locked)

| They get | They do not get |
|----------|-----------------|
| Invite list (+ DOI) | A Kickstarter pledge |
| Funds used as **campaign prep capital** (toward making KS succeed) | Dollars injected into the KS progress bar |
| If ≥ $1: priority launch email + early-bird email-match hold (see `ks-stripe-mapping.md`) | Automatic $ off a KS pledge |
| If ≥ $25 + later KS back: Founding Supporters credit | Guaranteed hardware without pledging on KS |

## Copy (locked)

≥ $1:

> This is not a Kickstarter pledge — Kickstarter’s total won’t include this payment. You’re funding campaign prep and showing demand. At launch we’ll email you first; pledge on Kickstarter for rewards. Same email helps us honor early-bird priority.

$0:

> Join the list — we’ll invite you when Kickstarter launches. Paying $1 or more is how we measure serious demand.

## Refunds

≥ $1: non-refundable (prep support), except duplicate/Stripe error.

## Kickstarter honesty

Disclose cumulative Stripe support on the KS page at launch and at close.

## Implementation

- Amount `0` → no Stripe; store lead + DOI  
- Amount ≥ `1` → PaymentIntent/Checkout custom USD; store `amount_cents`, email, source  
- Env: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`  
- Never store PAN  

## Metrics

| Event | Rule |
|-------|------|
| `lead_email` | amount = 0 |
| `paid_intent` | amount_cents ≥ 100 |
| KPI | paid_intent / all submits |

## Counsel

Review within 30 days of first ≥ $1 charge.
