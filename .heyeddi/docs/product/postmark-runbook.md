# Postmark runbook

**Last updated:** 2026-07-23  
**Applies to:** hey-eddi-website Cloud Functions email delivery for Doomsday waitlist  
**Status:** Locked for MVP implementation  
**Decision:** Postmark only (transactional + campaigns). No second ESP.

## Streams

| Stream | Postmark type | Message stream name | Use |
|--------|---------------|---------------------|-----|
| Transactional | Transactional | `outbound` (or `transactional`) | DOI confirm, $0 welcome, ≥ $1 support receipt |
| Campaigns | Broadcast | `broadcast` | Launch invite, pre-launch updates |

Unsubscribes on Broadcast must **not** block Transactional.

## Sender identity (locked)

| Field | Value |
|-------|-------|
| From name | HeyEddi Doomsday Box |
| From address | `box@heyeddi.com` |
| Reply-To | `hello@heyeddi.com` |
| Domain | `heyeddi.com` |
| Account owner | Founder (sole admin until hire) |

## Templates (MVP — locked IDs)

| Template alias | Stream | Trigger | Subject (locked) |
|----------------|--------|---------|------------------|
| `waitlist-doi` | Transactional | Email submitted ($0 or before pay) | Confirm your Doomsday Box waitlist spot |
| `waitlist-confirmed` | Transactional | DOI link clicked | You’re on the list — Doomsday Box |
| `support-receipt` | Transactional | Stripe ≥ $1 succeeded | Thanks for your support — not a Kickstarter pledge |
| `campaign-launch-invite` | Broadcast | KS live | Kickstarter is live — Doomsday Box |
| `campaign-prelaunch-update` | Broadcast | Manual | Doomsday Box update |

Every Broadcast footer: unsubscribe link + `privacy@heyeddi.com`.

## App responsibilities

1. Own the list in our DB (`email`, `source`, `created_at`, `doi_confirmed_at`, `marketing_opt_in`, `amount_cents`).
2. Send via Postmark API; Postmark is not the subscriber SoR.  
3. Honor unsubscribe webhook → `marketing_opt_in=false`.  
4. Env only: `POSTMARK_SERVER_TOKEN`, `POSTMARK_FROM=box@heyeddi.com`, stream IDs if required.

## Founder setup checklist (ops, not product TBD)

1. Verify `heyeddi.com` SPF/DKIM/DMARC for Postmark  
2. Create Transactional + Broadcast streams  
3. Create the five templates above  
4. Wire Broadcast unsubscribe  
5. Send test to Gmail, Outlook, Proton  
6. Confirm only founder has server token access  

## Launch-day flow

1. Query `marketing_opt_in=true`.  
2. Send `campaign-launch-invite` (include KS URL + “reservists must still pledge on Kickstarter”).  
3. Never blast unconfirmed or opted-out addresses.
