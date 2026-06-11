# Changelog

All notable changes to justinpurnell.com are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
