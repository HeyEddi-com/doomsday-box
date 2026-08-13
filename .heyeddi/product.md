# HeyEddi Doomsday Box

Privacy-first households and self-hosters who want an offline-capable personal cloud, inline network protection, and local AI in one low-power appliance—plus early supporters ready to back a Kickstarter.

## Personas

| Name | Role | Primary job | Anxiety | Design implication |
| ------ | ------ | ------------- | --------- | -------------------- |
| Alex | Self-hoster / DIY node runner | Run personal cloud and local AI on hardware they control without cloud lock-in | Vendor telemetry, brittle DIY stacks, and software that never ships open | Concrete capability list; honest OSS timeline; clear DIY vs hardware paths |
| Morgan | Household privacy / resilience lead | Protect home network and keep family data usable offline | Outages, ads/trackers, and gadgets that need constant cloud | Plain-language outcomes first; low jargon; trust via transparency |
| Casey | Early backer / Kickstarter supporter | Show demand with email at $0 or paid intent at $1+ before Kickstarter | Paying without clarity, or being asked for a demo that does not exist yet | Amount field allows 0 and custom ≥1; honest no-video / not-a-pledge copy; measure paid intent |

## Per-route intent

| Route | Register | Primary persona | User mindset | Success feeling |
| ------- | --------- | ----------------- | -------------- | ----------------- |
| `/doomsday-box` (hey-eddi-website) | brand | Casey | Curious; may pay $1+ to signal demand without a prototype video | I joined at $0 or showed paid intent in under a minute without being sold a fake demo |
| `box.local` (appliance) | brand | Casey / Morgan | Everyday home hub | I set up media and apps without Linux |
| `doomsday.local` (appliance) | brand | Alex / Morgan | Resilience / offline / protect | I see protection and offline status first; same power as box.local |

## Stack

Appliance monorepo `heyeddi-doomsday-box` (`box/` = on-device Debian, Docker Compose, FastAPI + Vue/PrimeVue, nftables, Ollama; N100/N150 + ARM64). Phase 0 marketing lives in `heyeddi-tool/hey-eddi-website` at `/doomsday-box` (Firebase + Cloud Functions for waitlist; Kickstarter later when prototype+video exist).

## Pages

| Route | View | Purpose |
|-------|------|---------|
| `/doomsday-box` (hey-eddi-website) | Doomsday landing | Hero, pillars, planned perks, email + amount ($0 or ≥$1→∞), disclosure |
| `box.local` / `doomsday.local` | Appliance dashboard (dual skin) | Same features; hub vs doomsday IA/theme |

## Brand personality

HeyEddi product line: practical digital sovereignty appliance with campaign energy on Doomsday Box naming

## Competitors

- Users compare us to: Umbrel, CasaOS, Firewalla, Protectli / mini PC firewall builds, Beelink / Minisforum mini PCs, Synology / NAS appliances, Raspberry Pi DIY stacks
- We win on: One aluminum appliance combining sovereign personal cloud, inline firewall/ad-tarpit, and offline local **Hermes** AI/agents—open-source after campaign fulfillment, with a high-trust Kickstarter path under ~$300 early-bird research pricing

## Anti-audience

Enterprise SSO buyers, people seeking cloud-only SaaS, and anyone wanting equity crowdfunding or charity fundraising on Kickstarter

## Voice & tone

Direct, sovereignty-forward, no hype. Verb-first CTAs. Honest about crowdfunding rules and planned perks. Calm confidence over prepper panic.

## Design references

- Framework Laptop: honest hardware storytelling
- Umbrel: clear personal-server value without enterprise chrome
- Kickstarter hardware campaigns: perk clarity and early-bird urgency without scammy scarcity

## Anti-references

- Generic purple SaaS landing with floating badge clusters
- Fear-mongering prepper marketing with cluttered stat strips
- Multi-page marketing site when a single scroll page suffices

## Downstream skills

See `.heyeddi/docs/intake/skill-routing.json` for which `@skill` runs per route.

_Authored by `@heyeddi-intake` via `write_product.py`: do not edit structure by hand._
