# Privacy & consent (pre-launch website)

**Last updated:** 2026-07-23  
**Applies to:** `heyeddi.com/doomsday-box` (hey-eddi-website) · aliases `box.heyeddi.com` / `doomsday.heyeddi.com`  
**Status:** Locked for MVP implementation

## What we collect

| Data | When | Why |
|------|------|-----|
| Email address | Waitlist / reserve | Launch invite; confirmations |
| Source tag | On submit | Attribution (`heyeddi-hero`, `direct`, `doomsday-alias`) |
| Timestamp | On submit | Ops / audit |
| Marketing opt-in flag | After double opt-in confirm | Broadcast eligibility |
| Reservation payment metadata | Stripe checkout | Receipts, perk-reference eligibility |
| IP / user-agent (minimal) | Server logs | Abuse prevention |

We do **not** collect: phone, home address, or government ID for waitlist-only.

## Decisions locked

| Topic | Decision |
|-------|----------|
| Privacy contact | `privacy@heyeddi.com` (alias to founder inbox until scale) |
| Double opt-in | **Yes** — waitlist must click confirm link before Broadcast campaigns |
| Cookies | **No non-essential cookies**; no cookie banner. Prefer localStorage only if needed for UI state |
| Legal notice | Ship with this doc’s footer points; counsel review within **30 days of first ≥ $1 charge** (does not block $0 email-only launch) |
| Operator | Founder, Zapopan / Jalisco, Mexico |

## Lawful basis / consent

- Email signup: affirmative CTA (“Join the waitlist”) + privacy link in footer.
- Marketing (Postmark Broadcast): only `marketing_opt_in=true` after double opt-in; every campaign includes unsubscribe.
- Transactional (confirmations, receipts): tied to the user action; never used as a substitute for marketing consent.

## Retention

| Data | Keep until |
|------|------------|
| Waitlist emails (opted-in) | Campaign end + **24 months**, or deletion request |
| Soft-bounced / unconfirmed DOI | **14 days**, then delete |
| Reservation records | **5 years** (accounting), then anonymize email |
| Server access logs | **30 days** unless active abuse investigation |

## User rights (MVP)

Contact `privacy@heyeddi.com` for access, correction, or deletion. Manual process is fine until >1k subscribers. Deletion must set DB flags **and** suppress Postmark Broadcast.

## Landing footer (required)

1. Collect: email, optional payment metadata, source.  
2. Postmark sends mail on our behalf.  
3. Stripe processes payments; we do not store full card numbers.  
4. Reservation ≠ Kickstarter pledge.  
5. Contact `privacy@heyeddi.com` to unsubscribe or delete.  

## On-box software (`box/`)

**Zero telemetry by default.** No phone-home from the appliance without explicit user action. This website privacy policy does not authorize device telemetry.
