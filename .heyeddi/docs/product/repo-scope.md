# Repository scope (monorepo)

**Last updated:** 2026-08-11  
**Repo:** `heyeddi-doomsday-box`

This repository holds **on-box appliance software** and product docs. The public marketing site is **not** here.

## Top-level layout

```
heyeddi-doomsday-box/
├── box/              # On-device OS stack, Compose, FastAPI, dashboard UI
├── .heyeddi/         # Product, design, workflow, engineering artifacts
├── .docs/            # Working economic / seed notes (guidance, not law)
├── .agents/          # Installed agent skills
└── README.md
```

| Folder | Product | Primary personas | Deploy target |
|--------|---------|------------------|---------------|
| `box/` | Sovereign hub software on the appliance | Alex, Morgan | Runs on N100/N150 (and ARM64 DIY); OSS at campaign ship |

**Canonical marketing UI + waitlist backend** live in `heyeddi-tool/hey-eddi-website` (projects URL, Firestore, Cloud Functions). See `marketing-hosting.md`.

## What lives where

### Marketing (hey-eddi-website)

- Nuxt page `/projects/doomsday-box` (legacy `/doomsday-box` redirects)
- Blog + projects Content entries
- `box.heyeddi.com` Firebase redirect / host middleware
- **Firestore + Cloud Functions** for email list / Stripe intent (founder implements)

### `box/` (this monorepo)

- Host OS install scripts (Debian bookworm appliance)
- Docker Compose stacks (gateway, API, dashboard; next: remote desktop + app profiles)
- FastAPI API + Vue/PrimeVue dashboard
- nftables / topologies / WireGuard-related config as applicable
- Software tests + GitHub Actions CI

## Phase map

| Phase | Focus | Where | Status |
|-------|--------|-------|--------|
| 0 | Market intent ($0 / ≥ $1) | `hey-eddi-website` | Landing UI done; Stripe/email CF planned |
| 1a | Stage-1 hub shell (claim + dual-skin UI) | `box/` | **done** |
| 1b | Browser remote desktop + Cursor (no SSH) | `box/` | **active MVP** |
| 1c | Golden flash on sample PCs | `box/host/` | Blocked until 1b works on hardware |
| 2 | Household hub features + KS prototype | `box/` + ops | later |
| 3 | Hardware ship + public OSS v1.0 | `box/` + GitHub | later |
| 4 | Post-campaign retail / Late Pledge | ops; retail may stay on heyeddi.com | later |

## Related

- `backlog.md`
- `marketing-hosting.md`
- `features/box-hub.md`
- `box-architecture.md`
- `oss-release-promise.md`
