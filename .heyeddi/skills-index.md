# Skills index

**Generated:** 2026-08-11T01:45:37Z · **Maintained by:** `@heyeddi-orchestrator`

Cached catalog: read this instead of every `SKILL.md` at session start. Refresh after installing skills: `write_skills_index --project-root .`

**Installed:** 27 / 27 skills

| Skill | Invoke | Installed | Description |
|-------|--------|-----------|-------------|
| backend-type-bridger | @backend-type-bridger | yes | Syncs a local FastAPI OpenAPI file to TypeScript types and reads Firestore schema hints. Use when writing Vue composa... |
| composable-patterns | @composable-patterns | yes | "Provides FastAPI JWT and Firebase client composable patterns for consistent auth and data layers. Context-first skil... |
| dart-type-bridger | @dart-type-bridger | yes | Syncs a local FastAPI OpenAPI file to Dart model stubs and reads Firestore schema hints for Flutter projects. Use whe... |
| design-handoff-flutter | @design-handoff-flutter | yes | "Implements Flutter screens from designer screenshots and handoff notes using Material 3. Two-pass workflow: mockup-b... |
| design-system-generalizer | @design-system-generalizer | yes | Scans token and component usage patterns from a golden reference page and diffs violations on other routes. Use when ... |
| engineering-excellence | @engineering-excellence | yes | "Audits code for KISS, YAGNI, DRY, SOLID, and testability; maintains living engineering notes under .heyeddi/docs/eng... |
| flutter-engineering | @flutter-engineering | yes | "Ensures HeyEddi Flutter projects have the right engineering stack: Flutter (Riverpod, go_router, Material 3), FastAP... |
| flutter-patterns | @flutter-patterns | yes | "Provides FastAPI Dio and Firebase client patterns for Flutter: repositories, Riverpod providers, auth. Context-first... |
| heyeddi-ci-config | @heyeddi-ci-config | yes | Author or update eddi-ci.yaml for HeyEddi CI and Spot runners. Use when enabling HeyEddi CI, runners, or the user ask... |
| heyeddi-ci-fails | @heyeddi-ci-fails | yes | "Diagnose failing GitHub Checks for a PR head: fetch evidence, write ephemeral ci-fails report, optional local fix lo... |
| heyeddi-ci-guide | @heyeddi-ci-guide | yes | Reference for HeyEddi CI commands, authorize-merge auth, feedback via debate + support@, and Spot runners placeholder... |
| heyeddi-ci-respond | @heyeddi-ci-respond | yes | "Respond to HeyEddi CI findings only: filter markers/bot, fix-vs-decline, stack-agnostic verify, threaded replies, ne... |
| heyeddi-ci-runners | @heyeddi-ci-runners | yes | "PLACEHOLDER: author eddi-ci.yaml pipeline jobs from live contract + inspect_repo. Spot runners are fail-closed — nev... |
| heyeddi-design | @heyeddi-design | yes | "End-to-end UI design for HeyEddi stack (PrimeVue, DESIGN.md, semantic tokens: OpenProps on scaffold default). Use wh... |
| heyeddi-handoff | @heyeddi-handoff | yes | "Implements screens from designer screenshots and handoff notes. Two-pass workflow: designer writes mockup-brief with... |
| heyeddi-intake | @heyeddi-intake | yes | "Translates vague user prompts into HeyEddi product docs (personas, route intent, voice), route-specific handoff arti... |
| heyeddi-orchestrator | @heyeddi-orchestrator | yes | Discover HeyEddi skills, auto-sync .heyeddi/ (skills index), detect hub updates (ask before install), cross-pillar op... |
| heyeddi-pr-respond | @heyeddi-pr-respond | yes | "Addresses PR review feedback: fetch comments, fix-vs-decline, apply fixes, re-gate, reply IN EACH review thread via ... |
| heyeddi-pr-review | @heyeddi-pr-review | yes | "Reviews submitted PRs using only committed changes: product fit, docs drift, engineering quality, test coverage, and... |
| heyeddi-product | @heyeddi-product | yes | "Product leadership: user stories, acceptance criteria, backlog, holistic reviews. Verifies the product works and is ... |
| no-duplicate-ui | @no-duplicate-ui | yes | Scans Vue files for duplicate component names and similar template overlap. Use during PR review or when refactoring ... |
| pre-merge-gate | @pre-merge-gate | yes | Runs pre-merge checks (tests, build, types, optional UI audit) and returns a markdown pass/fail report. Use when QA a... |
| primevue-openprops-architect | @primevue-openprops-architect | yes | Enforces PrimeVue + project design tokens when editing Vue or CSS. OpenProps rules apply only when the project alread... |
| project-engineering | @project-engineering | yes | "Ensures HeyEddi projects have the right engineering stack: Vue (Vite/Vitest), FastAPI backend, or Firebase tooling. ... |
| ux-flow-auditor | @ux-flow-auditor | yes | "Traces user task flows with Playwright: click depth, step success, friction: and writes reports to .heyeddi/docs/ux-... |
| verify-build | @verify-build | yes | Runs npm run build to catch Vite/Rollup failures before merge. Use when validating frontend changes or in CI pre-merg... |
| visual-auditor | @visual-auditor | yes | "Captures screenshots, reviews UI against product.md and design.md, runs WCAG contrast checks, fixes visual issues in... |

## Quick use

1. `suggest_skills --user-prompt "..."`: rank skills for the task
2. Read **one** chosen skill's `SKILL.md` (path in JSON index)
3. Follow `docs/intake/skill-routing.json` when present
