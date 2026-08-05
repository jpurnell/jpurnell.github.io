# Migration Report — justinpurnell.com

Migrated to the v2 layout on 2026-08-04.

- Files in the pre-migration tree: 52
- Project documents repatriated to `project/`: 5
- Pre-migration tree preserved at: `development-guidelines.pre-v2/` (gitignored)
- Framework files untracked from the index: 0
- Master plan: **UNFILLED TEMPLATE (10 placeholders)** — `project/master_plan.md` is still the shipped template. The `status` checker reads this file; fill it in.

## Framework divergence

Content found locally that upstream does not ship. **Nothing was discarded** — it
remains in `development-guidelines.pre-v2/`. Each item is an upstream candidate.

### Local-only rules
_none_

### Locally modified rules
Content upstream has never held — genuine local edits.

_none_

### Stale rules (no action needed)
Older upstream releases, superseded by the framework just installed. Listed for
completeness only — nothing to upstream.

- `settings.local.json`
- `swift-development.md`
- `SKILL.md`
- `SKILL.md`
- `SKILL.md`
- `SKILL.md`
- `SKILL.md`
- `03_DOCC_GUIDELINES.md`
- `08_FLOATING_POINT_FORMATTING.md`
- `RELEASE_CHECKLIST.md`
- `13_LOGGING_INSTRUMENTATION.md`
- `05_DESIGN_PROPOSAL.md`
- `PERFORMANCE.md`
- `14_CAPABILITY_MAP.md`
- `06_ARCHITECTURE_DECISIONS.md`
- `01_CODING_RULES.md`
- `11_NO_HARDCODED_CONSTANTS.md`
- `10_APPLICATION_TESTING_PATTERNS.md`
- `07_SESSION_WORKFLOW.md`
- `12_UI_TESTING.md`

## Next steps

1. Review `project/` and commit it to this repository.
2. Upstream anything listed above that belongs in the framework.
3. Only then remove `development-guidelines.pre-v2/`.
4. The `project-state/*` branch on the development-guidelines remote may be
   deleted only after this repository's commit is pushed.
