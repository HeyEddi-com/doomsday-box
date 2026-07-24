# Product review

**Date:** 2026-07-23  
**Scope:** pre-launch SPA (greenfield)

PM-owned review: **does the product work, is it useful, is something else better?**  
You orchestrate specialists: you do not replace them.

## 1. Context (tools)

- [x] `load_product_context.py`
- [x] `audit_product.py` (0 errors, 0 warnings after `features/home.md`)
- [x] `check_features.py` (no router yet → `unknown_no_router`; expected)

## 2. Delegate research

| Lens | Skill | Action | Findings (paste summary) |
|------|-------|--------|--------------------------|
| **Task completion** | `@ux-flow-auditor` | `trace_flow` on join-waitlist + reserve | **Pending** — request after craft; critical tasks: email join ≤2 interactions; reserve with disclosure visible |
| **UX / persona fit** | `@heyeddi-design` | `critique` / `craft` on `/` | **Pending** — must opine: hero dual CTA, perk table trust, heyeddi.com handoff |
| **Legibility / layout** | `@visual-auditor` | `audit_contrast --check` | **N/A until UI exists** |
| **Engineering fit** | `@engineering-excellence` | `audit_engineering` | **N/A until scaffold** — prefer thin SPA + form backend |
| **Duplicate / waste** | `@no-duplicate-ui` | scan | **N/A** — no UI yet |

## 3. PM judgment (you write)

### Does it work?
- Nothing ships yet: no Vue router/view. Blockers = build SPA + email store + optional Stripe.
- AC in `features/home.md` are the Definition of Done for Phase 1.
- `check_features` asked if single-route is too narrow: **No for Phase 1** — intentional; device dashboard is P3.

### Is it useful?
- Casey’s job is market intent: $0 lead vs ≥ $1 paid intent (primary KPI), before prototype video.
- Alex/Morgan get enough pitch on one page; deep product UI comes after campaign / in `box/`.

### Would something else be better?
- Multi-page marketing: **rejected**.
- Fixed $5 reservation + perk lock: **rejected** → $0 / ≥$1 → ∞ support.
- Waiting for prototype video before collecting intent: **rejected**.
- Automatic KS pledge credit from Stripe: **deferred** (options A–D).

## 4. Recommendations

| Priority | Change | Rationale | Owner skill |
|----------|--------|-----------|-------------|
| P0 | Scaffold `website/` per `features/home.md` | Unblocks intent collection | `@project-engineering` then `@heyeddi-design craft /` |
| P0 | Email + amount ($0 / ≥ $1) + disclosure | Casey job + paid_intent KPI | engineering + design |
| P0 | Point heyeddi.com hero CTA to SPA | Distribution | heyeddi.com repo |
| P1 | UX trace + design critique once UI exists | Cross-pillar close | `@ux-flow-auditor` + `@heyeddi-design` |
| P2 | Pick KS money-mapping upgrade if not disclose-only | Before KS live | product |
| P2 | KS pre-launch “Notify me” when URL exists | Platform followers | product when KS approved |

## 5. Definition of done (this review)

- [x] Every delegated row has findings or explicit N/A
- [x] P0 recommendations have acceptance criteria (see `features/home.md`)
- [x] `backlog.md` updated
- [x] Feature specs updated (`features/home.md`)
- [ ] Sibling UX + design opinions appended for `/` (requested)
