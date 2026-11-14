# justinpurnell.com Master Plan

**Purpose:** Source of truth for project vision, architecture, and goals.

> **Provenance:** Written 2026-08-05 from README, `Package.swift`, and the source tree.

---

## Project Overview

### Mission

The codebase for a personal website, built with the [Ignite](../../Ignite/project/master_plan.md)
static site generator.

### Target Users
- Readers of the site — its writing, project showcase, and quality-gate series
- The author, who needs publishing to be a `swift run` rather than an operation

### Key Differentiators
- **The site is a Swift package.** Pages are types; layouts are composed in code, so a
  broken page is usually a compile error rather than a deploy-time surprise
- **Its own generator.** This is the primary consumer of the Ignite fork, which makes it the
  place divergence gets exercised before anyone else sees it
- **Published from `docs/`** — GitHub Pages, no external build service

---

## Architecture

- **Language:** Swift 6 · **Build:** SwiftPM · **Generator:** the `Ignite` fork
- **Output:** `site.publish(buildDirectoryPath: "docs")`, committed and served by Pages

```
Sources/IgniteStarter/
├── Pages/  Layouts/  Components/   # the site
├── Models/  Data/                  # content types
├── Configuration/  Helpers/
Content/                            # markdown posts, front-matter driven
```

29 source files, 10 test files, 142 content documents.

### The relationship worth stating

This site depends on the fork, and the fork's changes land here first. Structured-data work
in `Ignite` is only observable once a real site emits it — so this repository is the fork's
integration test, whether or not it is labelled that way.

---

## Current Status

- [x] Site building and publishing to `docs/`
- [x] Content series including quality-gate, projects, showcase
- [x] Structured career data in `Resources/*.json`, decoded at build time: `cv.json`
      (CV page, JSON-LD) and, since 2026-09-28, `portfolio.json` (Portfolio page).
      The Portfolio page is the evidence page for the CV's positioning: every entry
      states a role, an outcome, and where to check it. Proposal:
      `project/plans/proposals/PortfolioPage.md`.

- [x] `cv.json` is also the input to CoverLetterWriter's `--tailor`, which treats it as the only source of facts.
      It gained a `projects` list (seven Swift projects, text taken from `portfolio.json`) and the Amazon Channels
      data-feed bullet on 2026-11-14. The site ignores `projects`; the tailor reads it. Any change to a bullet there
      changes what a tailored resume may claim, so wording in `cv.json` is now checked by a tool as well as read by people.

### Known Issues

**`docs/` is generated but committed**, so a rebuild produces diffs unrelated to any edit.
Regenerating also removes artifacts Ignite does not itself produce — an EPUB in the
quality-gate series had to be restored after one rebuild. Worth knowing before running
`swift run` casually.

### Priorities
**[NEEDS INPUT]**

## Quality Standards

`coding_rules.md`, Swift 6 strict concurrency, zero warnings.
**Every published post's front matter must parse and every internal link resolve** — a dead
link on a personal site is cheap to create and invisible until someone else finds it.

## Roadmap

**[NEEDS INPUT]**

---

**Last Updated:** 2026-11-14 — recorded that `cv.json` now also feeds CoverLetterWriter and gained `projects`; the 2026-09-28 reconciliation of status with the portfolio page still holds.