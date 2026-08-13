# On-box hub software (epic)

**Route:** local appliance UI · **Updated:** 2026-08-11  
**Code root:** `box/`  
**Status:** Stage-1 shipped; remote-desktop MVP active

## Problem / user job

Alex and Morgan need to configure and operate the Doomsday Box locally — personal cloud, network protection, and local AI — without cloud accounts or telemetry. Casey’s household may prefer a calmer “box” entry; Alex may prefer the doomsday-framed UI — same product.

**Near-term founder job:** use sample boxes as remote coding machines through the browser (Cursor on an authenticated desktop), before golden imaging.

## User stories

### Shipped (stage-1)

- As Morgan, I want to plug the box in, wait for boot, and open a browser to finish setup so that I never log into Linux. *(claim + `/setup` + session auth)*
- As Casey, I want `http://box.local` / branded aliases to feel like a friendly home hub skin.
- As Alex, I want `http://doomsday.local` / branded aliases to emphasize offline and protection (same features).
- As a tech user, I want Settings → Advanced to show remote-admin status (read-only) without factory-reset or PIN over HTTP.

### Active MVP

- As Alex, I want an authenticated **browser full desktop** (Kasm-class) so I can install and run **Cursor** on the box without SSH.
- As Alex, I want remote desktop **default off** and enableable from the hub (Settings / Apps) so the surface stays lean.
- As Alex, I want resource limits on the desktop profile so the box stays stable on 12–16GB RAM.

### Later (household v1)

- As Morgan, I want a setup wizard for AP vs inline bridge so that the box protects the household without a consultant.
- As Alex, I want enable/disable Compose apps with resource limits.
- As Alex, I want local AI available offline.
- As Alex, I want optional browser VS Code (code-server) for light editing — knowing it is **not** Cursor.
- As a tech user, I want optional pubkey SSH under Advanced (deferred; not MVP).
- As a Founding Insider, I want early builds before public OSS.

## Acceptance criteria

### Stage-1 (met)

1. Code lives under monorepo `box/` with tree in `box-architecture.md`
2. Routes exist for shell: `/`, `/setup`, `/settings` (+ Login); dual skins work
3. mDNS serves branded + short `.local` names (host scripts)
4. Dual skins: hostname switches hub vs doomsday; **same features**, no capability fork
5. First-run: browser claim with admin password; PIN never over HTTP
6. No mandatory telemetry or cloud login for core operation
7. No product copy claiming CrowdStrike / EDR evasion
8. ARM64 compatibility kept for DIY path (images/compose)
9. Software CI gate: dashboard + API + host/compose smokes

### Remote-desktop MVP (in progress)

10. Authenticated browser desktop Compose profile; prefer access via gateway (:443 when TLS ready)
11. Owner can enable/disable the profile from the hub UI
12. Documented path to run Cursor on that desktop (no SSH required)
13. Golden image flash remains **blocked** until this path works on a real PC

### Full hub v1 (open)

14. Routes: `/network`, `/apps`, `/ai`, `/founders`
15. Settings → Advanced can enable/disable browser remote and (later) other operator options; CLI break-glass remains
16. Public v1.0 aligns with `oss-release-promise.md` at hardware ship

## Success metric

**MVP:** founder completes claim → enable desktop → open Cursor in the remote desktop and develops without SSH.  
**v1:** Insider beta completes household setup without founder screenshare; public release ships with hardware fulfillment.

## Out of scope

- Marketing site (`hey-eddi-website` projects page)
- Kickstarter hosting
- Cloud multi-tenant control plane
- Separate backend products for “box” vs “doomsday”
- Shipping Cursor as a VS Code extension (does not exist; not our product)
- SSH-first remote coding for this MVP

## PM review checklist

- [ ] `@ux-flow-auditor`: setup + enable remote desktop within click budget; both skins
- [ ] `@heyeddi-design critique`: hub vs doomsday skins; same features
- [ ] `@visual-auditor audit_contrast --check`
- [ ] `@engineering-excellence`: one dashboard, skin switch not fork; desktop as Compose profile
- [ ] `check_features` when routes exist in product.md
