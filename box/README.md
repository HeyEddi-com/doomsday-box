# `box/` — on-device Doomsday Box software

**Status:** planned (scaffold pending)  
**Scope:** Appliance stack — Docker Compose, FastAPI + Vue/PrimeVue dashboard, firewall/routing, local AI. See `.heyeddi/docs/product/box-architecture.md`.

**Host:** Debian stable (v1 = bookworm). Not Arch/CachyOS on customer boxes.  
**Updates:** Compose images we publish (auto within channel); host security within the same Debian major; **Debian LTS→LTS only after we test** that major bump.  
**Setup:** plug in → boot → `http://box.local` or `http://doomsday.local` (dual UI skins, same features).

Dev: Debian VM preferred; coding on CachyOS is fine if Compose targets Debian.

This package is **not** the public marketing site. Marketing is `heyeddi.com/doomsday-box` in `hey-eddi-website`.
