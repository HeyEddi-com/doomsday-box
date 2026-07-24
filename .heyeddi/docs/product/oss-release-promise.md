# Open-source release promise

**Last updated:** 2026-07-23  
**Applies to:** software authored in `box/`  
**Status:** Locked public promise

## Promise (locked)

1. Kickstarter **Founding Insiders** get **early access** (builds, channel, voting) — pay for **speed and voice**, not a permanent proprietary lock.  
2. When campaign hardware **ships**, publish **v1.0** publicly on GitHub.  
3. License: **GNU GPLv3** (not AGPL — UI/API are local appliance services, not a hosted SaaS).  
4. Default posture: **offline-first, zero telemetry by default**.

## Timeline

```
Campaign live → Insider early builds
Production    → Insider feedback
Fulfillment   → Hardware ships + public v1.0 tag
```

## Public repository (locked)

| Item | Value |
|------|-------|
| Public GitHub | `HeyEddi-com/doomsday-box` |
| Until release | Repo may be public early for transparency; Insider early builds still apply before polished v1.0 at ship |
| License file | `LICENSE` GPLv3 at repo root |

## What is open vs not

| In | Out |
|----|-----|
| Our dashboard, API, Compose, host scripts | Upstream image licenses (comply; don’t re-license) |
| Operator docs we write | OEM BIOS / closed firmware |
| | Private supplier contracts, test jigs |

## Insider recognition (locked)

- `CONTRIBUTORS.md` — Kickstarter display name or chosen handle, alphabetical  
- In-dashboard **Founding Supporters** screen — same list  
- Private channel during beta (Discord or Matrix — pick one at Insider fulfill; default **Discord**)

## Communication

Landing + KS must state this timeline (`landing-copy-brief.md`). If ship slips, update backers **before** changing the public OSS date.
