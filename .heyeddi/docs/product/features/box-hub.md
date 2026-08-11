# On-box hub software (epic)

**Route:** local appliance UI · **Updated:** 2026-08-10  
**Code root:** `box/`  
**Status:** Locked epic for scaffold

## Problem / user job

Alex and Morgan need to configure and operate the Doomsday Box locally — personal cloud, network protection, and local AI — without cloud accounts or telemetry. Casey’s household may prefer a calmer “box” entry; Alex may prefer the doomsday-framed UI — same product.

## User stories

- As Morgan, I want to plug the box in, wait for boot, and open a browser to finish setup so that I never log into Linux.
- As Morgan, I want a setup wizard for AP vs inline bridge so that the box protects the household without a consultant.
- As Casey, I want `http://box.heyeddi.local` (or `box.local`) to feel like a friendly home hub so that media and everyday apps come first.
- As Alex, I want `http://doomsday.heyeddi.local` (or `doomsday.local`) to emphasize offline and protection so that resilience tasks are easy to find.
- As Alex, I want enable/disable Compose apps with resource limits so that the box stays stable on 12–16GB RAM.
- As Alex, I want local AI available offline so that basic assistance works without internet.
- As Alex, I want optional browser remote compute (authenticated, prefer :443) so that I can reach home when a VPN client is impractical — without marketing EDR evasion.
- As a tech user, I want Settings → Advanced on the hub to enable operator features so that I do not depend on SSH by default.
- As a Founding Insider, I want early builds before public OSS so that I can give feedback before v1.0.

## Acceptance criteria

1. Code lives under monorepo `box/` with tree in `box-architecture.md`
2. Routes exist: `/`, `/setup`, `/network`, `/apps`, `/ai`, `/settings`, `/founders`
3. mDNS serves **`box.heyeddi.local`**, **`doomsday.heyeddi.local`**, plus short aliases **`box.local`** / **`doomsday.local`**
4. Dual skins: hostname (or settings toggle) switches hub vs doomsday IA/theme; **same features**, no capability fork
5. First-run: plug in → boot → browser setup URL; no mandatory desktop login; dashboard admin password in `/setup`
6. Settings → Advanced can enable/disable browser remote and other operator options (web-first); CLI break-glass remains
7. No mandatory telemetry or cloud login for core operation
8. No product copy claiming CrowdStrike / EDR evasion
9. ARM64 compatibility kept for DIY path
10. Public v1.0 aligns with `oss-release-promise.md` at hardware ship

## Success metric

Insider beta completes setup without founder screenshare; public release ships with hardware fulfillment.

## Out of scope

- Marketing site (`hey-eddi-website` `/doomsday-box`)
- Kickstarter hosting
- Cloud multi-tenant control plane
- Separate backend products for “box” vs “doomsday”

## PM review checklist

- [ ] `@ux-flow-auditor`: setup task within click budget; both skins
- [ ] `@heyeddi-design critique`: hub vs doomsday skins; same features
- [ ] `@visual-auditor audit_contrast --check`
- [ ] `@engineering-excellence`: one dashboard, skin switch not fork
- [ ] `check_features` when routes exist in product.md
