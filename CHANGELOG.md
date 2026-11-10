# Changelog

All notable changes to justinpurnell.com are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **`basics.pronouns` in `cv.json` (2026-11-10).** An optional `Pronouns` value on `Basics`
  (`subject`, `object`, `possessive`, and an optional `display` such as "he/him, any is fine"),
  set to he/him/his. It is stored, not published: nothing on the page or in the JSON-LD states it,
  because schema.org's `Person` has no such property, and a test pins that the structured data
  carries neither the key nor the value. A CV without the field still decodes. project-showcase
  reads it so generated pages use the right pronouns instead of a guess.
- **Showcase graphics are inlined (`InlineSVG`).** The charts were `<img>` tags, which cannot see
  the page's theme and so ignored the site's light/dark toggle. They are now inlined, resolving the
  page's own token variables; their CSS is scoped to the chart so it cannot restyle the page, and a
  missing or non-SVG file falls back to an `<img>`.

### Changed
- **Showcase pages regenerated in first person (2026-11-10).** All 39 project pages and the portfolio
  overview were rewritten in my voice, with no praise of the work, and the KEXPPower page was added
  (`settled: true`, so syncing never rewrites it). Graphics use one title size, a heavy rule under it,
  no card border, and a shared month axis for the commit and release charts. Syncing now rewrites a
  page's prose only after a minor release bump; otherwise it refreshes the graphics alone.
- **DesignTokens 0.6.0 to 0.11.0 (2026-11-10).** `Package.swift` now requires `from: "0.11.0"`
  (resolved at tag 0.11.0). `scripts/sync-tokens.sh` produces a byte-identical `tokens.css`, so no
  token value the site uses changed. The showcase SVGs were regenerated against it; eight differ,
  all from commit counts that moved today, none from styling.

### Changed
- **Showcase graphics regenerated from the design system (2026-11-10).** All 114 SVGs for the 38
  manifest pages were rewritten by `showcase sync --infographics-only` from project-showcase's
  DesignTokens-based generators (previously a hard-coded navy and cyan palette). Each file embeds
  light, dark, increased-contrast and increased-contrast-dark values from DesignTokens 0.6.0.
  The commit-activity chart now sizes each month's bar by its real commit count; before, every
  bar was full height. `docs/` rebuilt.

### Fixed
- **`quality-gate-performance` lost its three graphics when the orphans were removed.** The
  layout builds a page's SVG URLs from its filename, so the article still requested
  `quality-gate-performance-{stats,commits,releases}.svg`; the files were a stale snapshot of the
  `quality-gate-swift` repository with no manifest entry of their own. The article now sets
  `infographics: qualitygatecore`, so it shows the live card for the same repository and stays
  current with each sync. `portfolio-overview` requested `portfolio-overview-*.svg`, which never
  existed on `main`; it now sets `infographics: none`, the layout's opt-out for overview pages.
  A sweep of every `docs/showcase` page finds no graphic link without a file.

### Removed
- Nine orphaned SVGs (`docclint`, `mlxtest`, `quality-gate-performance`, three each). None was in
  `showcase-manifest.json`, so sync never refreshed them and they kept the old palette.
  `mlxtest` was iConquer's internal name (its page is `iconquer`) and `docclint` was a one-commit
  snapshot of `docc-lint`, neither with a page. `quality-gate-performance` did have a page; see
  Fixed.

### Changed
- **DesignTokens 0.2.0 to 0.5.0 (2026-11-09).** `Package.swift` now requires `from: "0.5.0"`
  (resolved to tag 0.5.0, revision `275a75c`). `Assets/css/tokens.css` was regenerated with
  `scripts/sync-tokens.sh`; the diff is 55 added lines and no removals: three
  `@media (prefers-contrast: more)` blocks (light, OS dark, explicit `[data-theme="dark"]`)
  that override only accent, success, destructive and the eight series colours. Swiss values
  are otherwise unchanged. `docs/` rebuilt; `docs/css/tokens.css` is the only changed file.
  New tests pin the blocks, their cascade order (after the base and each dark block they
  override), the tokens-before-main link order in `MainLayout`, and that `main.css` neither
  redefines tokens nor adds its own contrast or theme blocks.

### Changed
- **Showcase pages regenerated from current source (2026-10-30).** 23 of the 28 pages under
  `Content/showcase/` were last generated on 12-13 May; they were rewritten by `showcase sync`
  from each repository's present state and `project/master_plan.md`, and the portfolio
  overview now covers those 23 projects. Original `date:` values, tags and `project:` groups
  are kept. `org-judgement-corpus`, `qualitygatecore`, `qualitygatetypes`, `swift-security-rules`
  and `webscraper` were left as published: their repositories have no master plan, and a page
  written without one is a guess.

### Added
- `showcase-manifest.json` (which repository produces which page, with audience, style, group
  and tags) and `.showcase-state.json` (the commit each page was last generated from), the
  inputs to `showcase sync` in project-showcase.

### Added
- **Portfolio page driven by `Resources/portfolio.json`.** The file is now the single
  source (it previously did not parse and nothing read it). Each entry carries a
  category, the role held, a period, a one-sentence outcome, and evidence links a
  reader can follow to check the claim. Open-source entries must have both an
  outcome and evidence, enforced by test. The page is in the top navigation and
  emits a `CollectionPage` node like `/projects`.
- **swift-oauth** added to the CV's projects and publications.
- Three skills on the CV: Test-Driven Development, AI Agent Orchestration,
  Static Analysis (SwiftSyntax).

### Changed
- **CV positioning.** A new lead summary (priority 6, the one the page renders)
  frames the career around specification and verification: what to build, written
  precisely enough that a model cannot misread it, and proof that the result works.
  Ledge Partners highlights, the site description, the About page and the home
  page's crawler bio say the same thing. Every figure quoted (SwiftMCPServer
  195/195 and 227/227, quality-gate-swift 45 checkers and 3,213 tests, swift-oauth
  469 tests, GeoSEOMCP 29 tools and 183 tests) was read from that package's README
  or CHANGELOG on 2026-09-28.
- Publication entries for quality-gate-swift, SwiftMCPServer, SwiftMCPClient,
  BusinessMathMCP and GeoSEOMCP updated to current versions and counts; the
  quality-gate entry had described a five-checker, 148-test tool.
- The hardcoded `portfolioSites` array and its five globals are gone.

### Fixed
- **Date helpers no longer depend on the build machine.** `FormatDates.swift` used
  `Calendar.current` three times and a locale-default formatter, so a build in another
  time zone could render a different day. Parsing and component extraction now share
  one pinned calendar (Gregorian, GMT, POSIX locale). Flagged by the gate's
  temporal-determinism checker.
- CV data: a duplicated Hotels at Home bullet, an unclosed parenthesis, "bewteen",
  "multiiple", and a Converged Media Group role whose end date preceded its start
  (now 2014-01-06, the day before the next role began).
- **Build-output tests check a standardized URL.** The four existence tests built a
  path by string concatenation and passed it to `FileManager.fileExists(atPath:)`,
  which takes the string exactly as given — a `..` segment would read outside
  `docs/` with nothing to stop it (CWE-22). They now resolve through
  `URL.standardized`, which collapses those segments before the filesystem is
  touched. `readFile` goes through the same helper.
- **Force unwrap removed from the getting-started playground.** `ts[period]!` sat
  inside a loop that already binds the value it was reaching back for; it now uses
  the bound `value`. Fixed in both `Assets/` and the `docs/` copy.

### Changed
- Upgraded swift-tools-version from 5.9 to 6.2 with strict concurrency
- Replaced force-unwrapped site URL with `URLComponents`-based construction
- Changed blog link from HTTP to HTTPS in footer data
- Moved post-build RSS script invocation from Swift to GitHub Actions workflow
- Replaced `print()` with `os.Logger` in site builder and CVStructuredData
- Replaced `try?` with explicit `do/catch` and error logging in CVStructuredData
- Strengthened test assertions from `!= nil` to `try #require()` in 3 test files

### Added
- swift-docc-plugin dependency for documentation generation
- DocC `///` comments on all 225 public APIs (100% coverage)
- `// LIVE:` annotations on JSON-decoded enum cases in SkillTypes and SummaryType
- `.accessibilityLabel()` on all 7 images flagged by accessibility audit
- `Sendable` conformance to `OffsiteLink`, `SocialLink`, and `PortfolioSite`
- `privacy:` annotations on all `os.Logger` string interpolations
- RSS autodiscovery post-build step in GitHub Actions workflow

### Removed
- `Foundation` and `Process` imports from IgniteStarter/main.swift
- Shell process spawning from Swift executable target

### Fixed
- Force unwrap crash risk on site URL (CWE-704)
- Insecure HTTP link in footer data (CWE-319)
- FileManager path traversal risk in post-build script (CWE-22)
- Process injection risk from dynamic argument construction (CWE-78)

### Known Issues
- **Ignite pinned to branch**: `ignite` dependency is pinned to the
  `feature/structured-data` branch (jpurnell fork) rather than a version tag.
  This branch adds `StructuredData` support for JSON-LD schema generation
  (Person, Organization, WebSite, Article, breadcrumbs) that the site relies on
  heavily. It cannot move to a tagged release until the structured-data feature
  is merged upstream or the fork publishes a semver tag.
