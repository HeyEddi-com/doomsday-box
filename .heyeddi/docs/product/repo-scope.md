# Repository scope (monorepo)

**Last updated:** 2026-07-24  
**Repo:** `heyeddi-doomsday-box`

This repository holds **on-box appliance software** and product docs. The public marketing site is **not** here.

## Top-level layout

```
heyeddi-doomsday-box/
├── box/              # On-device OS stack, Compose, FastAPI, dashboard UI
├── .heyeddi/         # Product, design, workflow artifacts (HeyEddi skills)
├── .docs/            # Working economic / seed notes (guidance, not law)
├── .agents/          # Installed agent skills
└── README.md
```

| Folder | Product | Primary personas | Deploy target |
|--------|---------|------------------|---------------|
| `box/` | Sovereign hub software on the appliance | Alex, Morgan | Runs on N100/N150 (and ARM64 DIY); OSS at campaign ship |

**Canonical marketing UI + waitlist backend** live in `heyeddi-tool/hey-eddi-website` (`/doomsday-box`, Firestore, Cloud Functions). See `marketing-hosting.md`.

## What lives where

### Marketing (hey-eddi-website)

- Nuxt page `/doomsday-box`
- Blog + projects Content entries
- `box.heyeddi.com` Firebase redirect / host middleware
- **Firestore + Cloud Functions** for email list / Stripe intent (founder implements)

### `box/` (this monorepo)

- Host OS notes / install scripts (Debian 12 / Ubuntu Server 22.04+)
- Docker Compose stacks (personal cloud, firewall helpers, AI, etc.)
- FastAPI API + Vue/PrimeVue dashboard
- nftables / topologies / WireGuard-related config as applicable

## Phase map

| Phase | Focus | Where |
|-------|--------|-------|
| 1 | Market intent ($0 / ≥ $1) | `hey-eddi-website` `/doomsday-box` |
| 2 | Kickstarter + prototype | ops + `box/` |
| 3 | Hardware ship + OSS | `box/` + public GitHub |
| 4 | Post-campaign retail / Late Pledge | ops; retail may stay on heyeddi.com |

## Related

- `marketing-hosting.md`
- `features/box-hub.md`
- `oss-release-promise.md`
