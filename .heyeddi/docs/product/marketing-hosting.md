# Doomsday Box marketing surface (canonical)

**Last updated:** 2026-07-24  
**Status:** Locked

## Canonical URLs

| URL | Role |
|-----|------|
| **https://heyeddi.com/projects/doomsday-box** | Primary full project page (landing + join) |
| https://heyeddi.com/doomsday-box | Legacy → 301 to `/projects/doomsday-box` |
| https://heyeddi.com/blog/… | Targeted communications (one post = one slice) |
| https://box.heyeddi.com | Alias → redirect / host middleware to project page |
| https://doomsday.heyeddi.com | Alias → same |

## Content roles

| Surface | Job |
|---------|-----|
| **Projects** (`/projects/doomsday-box`) | Full product experience — not a thin forge blurb |
| **Blog** | Communications aimed at one part of the product (stream, AI, offline, network, campaign timing, etc.) |

## Repo split

| Repo / path | Owns |
|-------------|------|
| `heyeddi-tool/hey-eddi-website` | Landing UI, blog, projects MD (list card), Hosting, **Firebase + Cloud Functions** for waitlist/intent |
| `heyeddi-doomsday-box/box/` | On-device appliance software |

(`website/` was removed from the doomsday monorepo on 2026-07-24; marketing is only on hey-eddi-website.)

## Backend (hey-eddi-website — founder-owned)

No separate Doomsday FastAPI. Implement on the HeyEddi site:

- **Firestore** for leads / paid-intent records  
- **Cloud Functions** for `$0` DOI (Postmark) and `≥ $1` Stripe Checkout  
- Wire the landing with `NUXT_PUBLIC_DOOMSDAY_INTENT_URL` → your public HTTPS function  

### Expected request (landing already sends)

```json
POST <doomsdayIntentUrl>
{ "email": "a@b.c", "amount_usd": 0, "source": "heyeddi-hero" }
```

### Expected response shapes

```json
{ "status": "recorded", "message": "Check your inbox to confirm." }
```

```json
{ "status": "checkout", "checkout_url": "https://checkout.stripe.com/...", "message": "Redirecting" }
```

## DNS / Hosting (founder ops)

1. Firebase Hosting target `box` (`hosting-box/` 301 → `https://heyeddi.com/projects/doomsday-box`), **or** custom domains on prod + client middleware.  
2. CNAME `box.heyeddi.com` / `doomsday.heyeddi.com` as needed.  
3. Stripe return URLs → `https://heyeddi.com/projects/doomsday-box`.
