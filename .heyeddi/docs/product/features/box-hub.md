# On-box hub software (epic)

**Route:** local appliance UI · **Updated:** 2026-08-13  
**Code root:** `box/`  
**Status:** Stage-1 + remote-desktop software shipped; USB golden image next

## Problem / user job

Alex and Morgan need to configure and operate the Doomsday Box locally — personal cloud, network protection, and local AI — without cloud accounts or telemetry. Casey’s household may prefer a calmer “box” entry; Alex may prefer the doomsday-framed UI — same product.

**Founder job now:** clone boxes from a USB/golden image. Power on → hub in the browser. No SSH, no per-machine bootstrap. Code via authenticated remote desktop + Cursor.

## User stories

### Shipped

- As Morgan, I want to plug the box in, wait for boot, and open a browser to finish setup so that I never log into Linux. *(claim + `/setup` + session auth — software; needs compose-on-boot for clones)*
- As Casey / Alex, I want hub vs doomsday skins on `.local` names — same features.
- As Alex, I want an authenticated **browser full desktop** so I can run **Cursor** without SSH.
- As Alex, I want remote desktop **default off** and enableable from Settings.
- As Alex, I want installed apt software (Cursor/VS Code) to restore after desktop container recreate (N150-friendly cache: start, apt hook, daily sleep, stop).

### Active

- As a founder, I want a USB/golden image with the stack **already in it** so I do not start each PC to install Debian or run compose.
- As Morgan, I want the hub to come up on power with no operator at a keyboard.

### Later (household v1)

- As Morgan, I want a setup wizard for AP vs inline bridge.
- As Alex, I want enable/disable Compose apps with resource limits (`/apps`).
- As Alex, I want local AI available offline.
- As Alex, I want optional browser VS Code (code-server) — not Cursor.
- As a tech user, I want optional pubkey SSH under Advanced (deferred).
- As a Founding Insider, I want early builds before public OSS.

## Acceptance criteria

### Stage-1 (met)

1. Code lives under `box/`  
2. Routes: `/`, `/setup`, `/settings`, Login; dual skins  
3. mDNS branded + short `.local`  
4. Claim PIN never over HTTP  
5. CI: dashboard + API + host/compose smokes  

### Remote-desktop MVP (met, software)

6. Authenticated `/desktop/` (unsigned → login, then continue)  
7. Settings enable/disable + Open in new tab + starting spinner  
8. Documented Cursor/VS Code install (`~/bin/install-linux-editor.sh`)  
9. Apt cache restore without polling every few minutes  

### USB / golden (in progress)

10. systemd starts compose on boot (no SSH, no manual `up`)  
11. Docker images pre-pulled in the bake (offline first boot for hub; webtop present)  
12. First-boot mints unique claim PIN + machine-id  
13. Bake script documented; artifacts **not** in git (`GOLDEN.md`)  

### Full hub v1 (open)

14. Routes: `/network`, `/apps`, `/ai`, `/founders`  
15. Public v1.0 at hardware ship (`oss-release-promise.md`)  

## Success metric

**Now:** flash a clone → power on → claim in browser → enable desktop → Cursor, with no founder SSH.  
**v1:** Insider household setup without founder screenshare.

## Out of scope

- Marketing site  
- Kickstarter hosting  
- Cloud control plane  
- Cursor-as-VS-Code-extension (does not exist)  
- SSH-first coding  
- Committing `.img` files to git  

## PM review checklist

- [ ] `@ux-flow-auditor`: setup + enable remote desktop  
- [ ] `@heyeddi-design critique`: hub vs doomsday skins  
- [ ] `@visual-auditor audit_contrast --check`  
- [ ] `@engineering-excellence`: compose-on-boot + first-boot PIN  
