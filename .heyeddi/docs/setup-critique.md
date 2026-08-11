# Critique: /setup + appliance shell (2026-08-10)

## First impression
Functional stub, not a claim ceremony. Raw inputs in a grey panel, founder CLI tips in the owner path, and hub nav during an unclaimed first run. Dual-skin (Hub vs Survival) is only a CSS accent tweak, not two modes with different jobs.

## What's working
- Claim PIN requirement is the right security model.
- Dual hostname skins already exist in code (`hub` / `doomsday`).
- Stack already includes PrimeVue + Aura (unused on these routes).

## Issues (priority)

### P0: ship blockers
| Issue | Evidence | Fix direction |
|-------|----------|---------------|
| Open first-run looks hijackable / amateur | Plain form, no physical-presence thesis | Claim code as hero control; calm copy; no CLI on primary surface |
| Nav during unclaimed state | App.vue always shows Home/Setup/Settings | Claim-only chrome until `setup_complete` |
| No design system doc | `design.md` missing | Author dual-skin `design.md` |

### P1: hierarchy / polish
| Issue | Evidence | Fix direction |
|-------|----------|---------------|
| PrimeVue unused | native inputs/buttons | InputText, Password, Button, Message, Accordion |
| Skin = accent only | same layout/copy density | Hub light everyday; Survival dark offline-first copy |
| Network placeholder noise | select on primary form | Move to Advanced with CLI tips |
| Home/Settings stubs | status dump / "coming next" | Coherent status board + Settings with Advanced disclosure |

### P2: nice-to-have
- Full en/es locale pack (seed strings now)
- Motion: one claim success / mode enter moment

## Token & component drift
- No `design.md`. Custom hex in `styles.css` only.
- Aura registered but screens ignore it.

## Audience fit
| Persona | Fit today | Verdict |
|---------|-----------|---------|
| Morgan (household) | Too jargon + CLI | REVISE: Hub light, plain outcomes |
| Alex (self-hoster) | No offline emphasis | REVISE: Survival dark, offline status first |
| Casey (backer) | N/A on appliance setup | n/a |

## Aesthetic direction
- Subject: physical box claim + dual operating modes
- Risk: Hub light vs Survival dark (same IA, opposite atmosphere)
- Avoid: purple SaaS, cream+terracotta, acid glow cyberpunk

## Recommended next step
- [x] `polish` full shell + Setup/Home/Settings
- [x] `document` `.heyeddi/design.md`
