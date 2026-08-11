# Engineering docs

Living notes for **KISS, YAGNI, DRY, SOLID**: maintained by `@engineering-excellence`.

| File | Purpose |
|------|---------|
| `architecture.md` | How the system works: modules and data flow |
| `reuse-catalog.md` | What already exists: do not rebuild |
| `decisions.md` | Engineering ADRs |

**Doomsday Box testing:** use local skill `@doomsday-box-testing` (`.agents/skills/`, not in git) and `box/test/README.md`. CI: `.github/workflows/ci.yml`.

Run `audit_engineering.py --check` before merge on non-trivial changes.
