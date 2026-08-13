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

1. ~~Review `project/` and commit it to this repository.~~ Done — `project/`
   is tracked and pushed.
2. ~~Upstream anything listed above that belongs in the framework.~~ Nothing to
   upstream: the divergence audit above found no local-only and no locally
   modified rules. Every listed file is a superseded upstream release.
3. ~~Only then remove `development-guidelines.pre-v2/`.~~ Removed 2026-08-13.
4. The `project-state/justinpurnell-com` branch on the development-guidelines
   remote (at `563d729`) **still exists** and is a decision left open. It holds
   the two commits that predate repatriation. The three commits that came after
   it were only ever local, and their content is byte-identical to files now
   tracked here — verified before removal:

   | pre-v2 path | now lives at | state |
   |---|---|---|
   | `02_IMPLEMENTATION_PLANS/PROPOSALS/QualityGateWebExperience.md` | `project/plans/proposals/QualityGateWebExperience.md` | identical |
   | `05_SUMMARIES/2026-08-03_QualityGate_WebExperience.md` | `project/summaries/` | identical |
   | `05_SUMMARIES/HANDOFF_2026-08-03.md` | `project/summaries/` | this repo's copy is **newer** — its internal path reference was corrected to the v2 layout |

## What the nested clone actually was

Worth writing down, because the shape recurs: `development-guidelines.pre-v2/`
was not a submodule and not a gitlink. It was a full clone of the shared
framework repo, sitting inside this working tree, gitignored, checked out on a
local-only branch that carried this site's own session summaries and proposals.

Nothing leaked upstream — the three site-specific commits were never pushed
anywhere. But the arrangement is worth avoiding on its own terms: a gitignored
directory containing a live repository is invisible to `git status` here and
looks like an ordinary folder, so a stray `git commit` run from inside it lands
in the *framework's* history rather than this one. That is precisely the
"never pollute shared template repos" boundary, and an ignored nested clone is
the configuration most likely to cross it by accident.

The same pattern exists at scale: the framework remote carries **50**
`project-state/*` branches, one per project. Consider this repo's entry
resolved either way — the content is here now.
