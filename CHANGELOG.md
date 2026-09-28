# Changelog

All notable changes to justinpurnell.com are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
