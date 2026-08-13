# HeyEddi Doomsday Box

Sovereign home hub software: offline-capable personal cloud, network protection, and local AI on a lean Debian appliance (Intel N100/N150; ARM64 DIY path).

**Status:** stage-1 hub + authenticated remote desktop (Cursor in webtop) shipped as software. **Next:** USB/golden image so clones boot the stack with no SSH. Marketing / waitlist: [heyeddi.com/projects/doomsday-box](https://heyeddi.com/projects/doomsday-box).

## Layout

| Path | What |
|------|------|
| [`box/`](box/) | On-device stack: Compose, API, dashboard, host scripts |
| [`.heyeddi/`](.heyeddi/) | Product, design, and engineering docs |

## License

GNU GPLv3 — see [`LICENSE`](LICENSE). Public v1.0 aligns with hardware ship; this repo may receive earlier commits.

## Local setup (dev)

See [`box/README.md`](box/README.md) for Compose quick start and software tests.

On-box UI entry: `http://box.local` and `http://doomsday.local` (dual skins, same features). Architecture: [`.heyeddi/docs/product/box-architecture.md`](.heyeddi/docs/product/box-architecture.md). Roadmap / backlog: [`.heyeddi/docs/product/backlog.md`](.heyeddi/docs/product/backlog.md).

## Docs

[`.heyeddi/docs/product/README.md`](.heyeddi/docs/product/README.md)
