# HeyEddi Doomsday Box

Sovereign home hub software: offline-capable personal cloud, network protection, and local AI on a lean Debian appliance (Intel N100/N150; ARM64 DIY path).

**Status:** early public repo — appliance stack under `box/` is being scaffolded. Marketing / waitlist lives on [heyeddi.com/doomsday-box](https://heyeddi.com/doomsday-box).

## Layout

| Path | What |
|------|------|
| [`box/`](box/) | On-device stack (planned): Compose, API, dashboard, host scripts |
| [`.heyeddi/`](.heyeddi/) | Product & design docs |

## License

GNU GPLv3 — see [`LICENSE`](LICENSE). Public v1.0 aligns with hardware ship; this repo may receive earlier commits.

## Local setup (appliance)

Coming with the `box/` scaffold (Debian VM first). See [`.heyeddi/docs/product/box-architecture.md`](.heyeddi/docs/product/box-architecture.md).

On-box UI entry (planned): `http://box.local` and `http://doomsday.local` (dual skins, same features).

## Docs

[`.heyeddi/docs/product/README.md`](.heyeddi/docs/product/README.md)
