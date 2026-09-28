# Proposal: Portfolio page driven by `portfolio.json`

**Status:** PROPOSED — implemented in the same session under the standing
"design → red → green → gate 0/0 → commit" workflow; hold the push for review.
**Date:** 2026-09-28
**Repo:** justinpurnell.com (Ignite static site)

## 1. Objective

Turn the Portfolio page into the evidence page for the positioning the CV now
leads with: a person who writes the specification and ships the verified build.
Every entry states a role, a measurable outcome, and where a reader can check it.

**Master Plan reference:** Current Status — the site's content series. This adds
a section that is data-driven, like the CV, rather than markdown-driven.

## 2. Motivation

**Current situation.** `Resources/portfolio.json` exists but nothing reads it,
and it does not parse (trailing comma, empty fields). The live `Portfolio` page
renders a hardcoded array in `PortfolioData.swift` of five sites, is not in the
navigation, and carries no outcomes or links to proof. The CV page already
decodes `cv.json`, so the site has two data conventions for the same kind of
content.

**Drawback.** A hiring manager or client cannot verify "I ship with AI" from a
resume line. The thing that is verifiable is a package with a reproducible
conformance run, a test count, a changelog, and a consumer. None of that is on
the site in one place.

## 3. Proposed Architecture

**Modified files**
- `Resources/portfolio.json` — becomes the single source; fixed and enriched.
- `Sources/PersonalSiteLib/Data/PortfolioData.swift` — `PortfolioSite` gains
  optional fields; the hardcoded array is removed.
- `Sources/PersonalSiteLib/Pages/Portfolio.swift` — decodes the JSON through
  `@Environment(\.decode)`, groups by category, renders filterable cards.
- `Sources/PersonalSiteLib/Components/SiteHeader.swift` — adds the nav link.
- `Sources/PersonalSiteLib/Layouts/MainLayout.swift` — `/portfolio` emits a
  `CollectionPage` node like `/projects`.
- `Tests/PersonalSiteTests/PortfolioDataTests.swift` — loads the real JSON.

## 4. API Surface

```swift
public enum PortfolioCategory: String, Codable, Sendable, CaseIterable {
    case product, openSource = "open-source", media
    public var displayName: String
}

public struct PortfolioEvidence: Codable, Sendable {
    public let label: String
    public let url: String
}

public struct PortfolioSite: Codable, Sendable {
    public let name: String
    public let url: String
    public let thumbnail: String        // "" when there is no logo
    public let summary: String?
    public let category: PortfolioCategory?   // nil decodes as .product
    public let role: String?
    public let period: String?
    public let outcome: String?
    public let evidence: [PortfolioEvidence]?
}

/// Loads `Resources/portfolio.json` from disk (tests) — the page uses `decode`.
public enum PortfolioData {
    public static func load(from url: URL) throws -> [PortfolioSite]
}
```

## 5. MCP Schema

Not applicable. The page is static output; the JSON is the schema. Each entry:

```json
{
  "name": "SwiftMCPServer", "url": "https://github.com/jpurnell/SwiftMCPServer",
  "thumbnail": "", "category": "open-source",
  "role": "Author", "period": "2026–present",
  "summary": "…", "outcome": "195/195 on the 2026-07-28 MCP conformance requirements.",
  "evidence": [{ "label": "Conformance", "url": "…#conformance" }]
}
```

## 6. Constraints & Compliance

- **Concurrency:** all model types are `Sendable` value types.
- **Safety:** no force unwraps; an empty thumbnail renders no image; a missing
  category defaults to `.product`.
- **Site rule:** every internal link resolves; evidence URLs are external.
- **Gate:** 0/0 before commit.

## 7. Source & API Compatibility

`PortfolioSite.init` gains defaulted parameters, so the one existing caller in
tests still compiles. The five global `let` sites and `portfolioSites` are
removed; nothing outside `PortfolioData.swift` and its test referenced them.

## 9. Dependencies

Ignite `decode`, `Card`, `Grid`, `Badge`, and the existing `card-filter.js`.

## 10. Test Strategy

- `portfolio.json` decodes and is non-empty.
- Every entry has a name and an `http` URL.
- Every non-empty thumbnail starts with `/images/`.
- Every entry with evidence has `http` evidence URLs.
- Every open-source entry states an outcome.
- Category decodes from its raw value; a missing category is `nil`.
- Round-trip through `Codable` preserves the new fields.

**Reference truth:** the JSON file itself, plus the figures in it, which were
read from each package's README or CHANGELOG on 2026-09-28 (see the CV commit).

## 11. Architecture Decision Review

No ADR log exists for this repo. Decision recorded here: **structured career
data lives in `Resources/*.json` and is decoded at build time**, matching
`cv.json`. Markdown stays for prose.

## 12. Adversarial Review

**Strongest case for a different approach.** Make each entry a markdown
article under `Content/portfolio/` and reuse `Projects.swift`. That gives each
project a page of its own and the existing tag filter for free.

**Where this design is most likely wrong.** If the entries grow long prose,
JSON is the wrong home for it. The outcome line is meant to stay one sentence.
If it doesn't, move to markdown then.

**What an experienced critic would say.** "You are putting numbers on a page
that will drift the day you tag a release." True. The mitigation is that every
number sits next to the link that proves it, so a stale figure is visibly stale
rather than silently wrong, and the CV commit records the date they were read.
