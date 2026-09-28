# Session summary — 2026-09-28 — CV positioning and the portfolio page

## What was asked

Reposition the CV around one idea: when generating code is cheap, the durable work is
specifying what to build and verifying what came out. Then make the portfolio the page
that proves it.

## What shipped

- **`Resources/cv.json`**: a `basics.label`; a new priority-6 `cv` summary (the page
  renders the highest-priority `cv` summary, so this is the live one); rewritten
  Ledge Partners highlights; updated publication entries; a new swift-oauth
  publication; three new skills; five data fixes (typos, a duplicate bullet, an
  end-before-start date).
- **`Resources/portfolio.json`** is now valid and is the data source. 14 entries
  across three categories, each with role, period, outcome, and evidence links.
- **`PortfolioData.swift`**: `PortfolioCategory`, `PortfolioEvidence`, extended
  `PortfolioSite`, `PortfolioGroup`, and `PortfolioData.load`/`grouped`. The
  hardcoded array is gone.
- **`Portfolio.swift`**: decodes the JSON, filter chips per category, card grid,
  open source first. Added to the nav; `/portfolio` emits `CollectionPage`.
- Site description (under the 160-character SEO test), About page, and the home
  page's crawler bio now carry the same positioning. The About page had said Justin
  *is* Head of Product at Hotels at Home since 2025-03.
- Proposal: `project/plans/proposals/PortfolioPage.md`.

## Verification

- 101 tests in 10 suites pass. Red was confirmed before the model existed (six
  "cannot find" errors in `PortfolioDataTests.swift`).
- Quality gate: **0 errors, 0 warnings** on the final run (40 of 45 checkers; 5 not
  selected by config). Two intermediate warnings were mine (nil-coalesced test
  assertions, rewritten with `#require`); three were pre-existing `Calendar.current`
  uses in `FormatDates.swift`, fixed by pinning one calendar. A first gate run failed on `BuildOutputTests` because it overlapped
  a concurrent `swift run` that was rewriting `docs/`; the rerun passed.
- Rendered output checked in `docs/`: 14 cards, 13 evidence links, 4 filter chips,
  `CollectionPage` present; the CV page renders the new summary, the swift-oauth
  entry, and the new skills. Rendered CV lives at `docs/c-v/`, not `docs/cv/`.
- Every number on the CV and portfolio was read from the package's README or
  CHANGELOG this session; see the CHANGELOG entry for the list.

## Deliberately not done

- **Not pushed.** The CV, About page, and site description are the author's own
  voice on a live site. Review `git show` on the source commit, then push.
- BusinessMathMCP's tool count is quoted as "200+" (the conservative figure already
  in the CV); the README was not grepped for an exact count. Older summaries in
  `cv.json` still say "230+"; they are not rendered.
- No logo assets for the open-source entries; cards render without an image.

## Next

1. Read the new summary aloud; it is the one visitors see.
2. `git push` when satisfied. GitHub Pages deploys `docs/` on push.
3. If the portfolio outcomes drift when packages are tagged, the evidence link next
   to each figure is where a reader will notice. Update `portfolio.json` at tag time.
