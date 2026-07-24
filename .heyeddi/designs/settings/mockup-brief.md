# Mockup brief: Settings — N/A (Phase 1)

Authored for intake verify compatibility. Marketing product has **no** `/settings` page.

## Audience (from product.md)

- **Primary persona:** Casey
- **Mindset:** Curious about the box; deciding whether to leave email or put money down
- **Success feeling:** I understand the product and can join the launch or reserve in under a minute
- **Register:** brand · Direction: appliance settings are out of scope for `website/`

## Designer read (first impression)

Do not design a SaaS settings screen for the marketing site. Appliance `/settings` is specified under `box-architecture.md` for later `box/dashboard` work.

## Implementation spec

| Item | Decision |
|------|----------|
| Marketing `/settings` | **Do not build** |
| Appliance settings | `box/dashboard` route `/settings` in Phase 2+ |
| Phase 1 surface | Single-page `/` in `website/` only — see `designs/pre-launch-landing/` |
