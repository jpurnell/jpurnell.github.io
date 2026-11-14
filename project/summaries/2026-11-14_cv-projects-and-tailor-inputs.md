# Session Summary: cv.json as the tailor's source of facts

| Date | Phase | Status |
| :--- | :--- | :--- |
| 2026-11-14 | Maintenance of `Resources/cv.json` | COMPLETED |

Most of this session's work was in CoverLetterWriter. Read `CoverLetterWriter/project/summaries/2026-11-14_TailoredResumePipeline.md` and `HANDOFF_2026-11-14.md` there. This page covers only what changed in this repository.

## Changes (all pushed; `main` was `0ff6d78` after the last)

1. **Seeso bullet:** "Built the data feed pipeline for Amazon Channels distribution; my first production programming work." Commit `854485e`; the rebuilt `docs/c-v/index.html` carries it.
2. **`projects` in `cv.json`:** seven entries drafted verbatim from `portfolio.json`, tags written by the assistant and approved by the owner. Pure insertion, 137 lines. Commit `0dbb421`. The site does not render them; `docs/` was unchanged by the rebuild.
3. **Employer name:** "Thompson Financial Securities Data" corrected to "Thomson" in `cv.json` and the rendered CV page. Commit `0ff6d78`.

## Verification

- `swift run IgniteStarter` rebuilt cleanly each time; the diffs were exactly the expected lines.
- The site's 123 tests pass with the new `projects` key (the model ignores unknown keys).
- Each push: `git ls-remote origin main` matched the local commit; pre-push gate passed.

## Next step and decisions

- When a project's figures change on the Portfolio page, update the matching `projects` highlights, or the tailor will repeat the old numbers.
- Open: whether to render `projects` on the CV page (not planned).

## Housekeeping done

- Removed an empty `.claude/worktrees/` folder left by a failed agent launch.
- Both `development-guidelines/` folders (here and in CoverLetterWriter) are gitignored plain copies, not separate repositories; the project-state-branch rule does not apply to them.
- Existing branches `chore/design-tokens-0.5.0`, `showcase/plans-2026-10-30`, `showcase/sync-2026-11-02` were not touched.
