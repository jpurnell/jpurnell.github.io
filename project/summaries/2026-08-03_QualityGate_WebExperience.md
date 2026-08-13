# Session Summary — 2026-08-03 — The Gate and the Mirror (web experience)

## What shipped

A first-class `/quality-gate` section on justinpurnell.com — *The Gate and the
Mirror* — modeled on BusinessMath, built and **published** to
`jpurnell.github.io`. Live: <https://www.justinpurnell.com/quality-gate>.

- **49 posts** across two arcs + a compliance mini-series, on a tag-filterable
  card-grid landing page with a gate-readout hero.
- **Nav:** top-level `Quality Gate` link, immediately right of BusinessMath.
- **Epub:** *The-Gate-and-the-Mirror.epub* (Preface from the book draft + all
  posts in three parts, via pandoc), linked for download from the intro.

## Built in six phases (each its own site commit `5fe54f0`→`6408385`)

- **Phase 0** — scaffold: `Sources/PersonalSiteLib/Pages/QualityGate.swift`
  (cloned from `BusinessMath.swift` + richer hero), nav wiring in `SiteHeader`,
  route in `PersonalSite.staticPages`, `Content/QualityGate/` family folders +
  `metadata.yaml`, intro, first Correctness posts.
- **Phase 1** — flagships: *A Gate, Not a Linter* (gate) and *The Mirror* (IJS).
- **Phase 2** — all 36 checker posts, sequential by family (Correctness 9,
  Safety 5, Hygiene 7, Docs 2, Project Health 8, Specialty 5).
- **Phase 3** — Mirror mini-series (6): Corpus, Pulse, Policy Discovery,
  Calibration & Workbench, Trust Service, and the *Principles as Software*
  Bridgewater essay.
- **Phase 4** — Compliance mini-series (4): coverage-not-a-badge,
  privacy-manifest, standards-watch, three-frameworks synthesis.
- **Phase 5** — epub, fold-in of the old `projects/quality-gate-swift.md` post
  (banner → the section), cross-link sweep (all internal links resolve), ship.

## Source material used

quality-gate-swift README/CHANGELOG/DocC + this-session's compliance work; the
`org-judgement-system` / `org-judgement-corpus` repos; and the existing drafts in
quality-gate-swift's guidelines (`BOOK_QUALITY_GATE_AND_INSTITUTIONAL_JUDGMENT.md`
— the "Gate and the Mirror" book — and `BLOG_POST_INSTITUTIONAL_JUDGMENT.md`).

## Conventions / gotchas (for next time)

- **URLs:** landing at `/quality-gate` (from the StaticPage type name); posts at
  `/QualityGate/<family>/<slug>` (from the content dir). Both work.
- **Epub serving:** ~~Ignite does NOT copy `.epub` from `Content/` to `docs/`. The
  epub is served by a manual `cp Content/QualityGate/*.epub docs/QualityGate/`
  **after** `swift run`. If you regenerate the epub or the site, re-copy it.~~
  **Superseded 2026-08-13.** The epub now lives in `Assets/epub/`, which Ignite
  copies to `docs/epub/` on every `swift run`. No manual `cp`. The old
  arrangement put a generated file directly into the publish directory, where
  the next build was free to overwrite the folder around it and where nothing
  recorded that a step had been skipped — which is how it ended up seven
  chapters behind the site.
- **Site gate:** the site runs its own `.quality-gate.yml` (doc-coverage on
  `PersonalSiteLib`, consistency/ijs into `org-judgement-corpus`). The new
  `QualityGate.swift` is fully documented; the section is 0/0.
- **Build/deploy:** `swift run` → `docs/`; `git push origin main` → GitHub Pages
  (rebuild takes a minute or two).

## Rebuild the epub

**Superseded 2026-08-13** — this procedure is now `scripts/build-quality-gate-epub.sh`.
The recipe below was correct and still went wrong, in the way prose recipes do:
it lived here, nobody re-read it, and the epub silently fell seven chapters
behind the site with nothing to say so. The script holds the chapter order in
one list and fails if the count it emits differs from the count of `.md` files
on disk.

```
./scripts/build-quality-gate-epub.sh   # -> Assets/epub/
swift run                              # Ignite copies Assets/ -> docs/
```

<details><summary>Original procedure, for the record</summary>

```
# from Content/QualityGate/: concat posts (frontmatter-stripped) into a
# Complete.md with the pandoc metadata block, then:
pandoc QualityGate-Complete.md --css epub.css --toc --toc-depth=1 \
  -o The-Gate-and-the-Mirror.epub
# then remove Complete.md (Ignite misparses its --- block) and
# cp the .epub into docs/QualityGate/ after `swift run`.
```

</details>
