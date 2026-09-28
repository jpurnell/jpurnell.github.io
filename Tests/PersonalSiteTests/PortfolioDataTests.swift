import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("Portfolio Data")
struct PortfolioDataTests {

    /// Project root directory, derived from the test file location.
    private static let projectRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // → Tests/PersonalSiteTests
        .deletingLastPathComponent() // → Tests
        .deletingLastPathComponent() // → project root

    private static let portfolioURL = projectRoot
        .appendingPathComponent("Resources")
        .appendingPathComponent("portfolio.json")

    private func loadSites() throws -> [PortfolioSite] {
        try PortfolioData.load(from: Self.portfolioURL)
    }

    // MARK: - Golden path against the real file

    @Test("portfolio.json decodes and is non-empty")
    func sitesNonEmpty() throws {
        let sites = try loadSites()
        #expect(!sites.isEmpty)
    }

    @Test("All portfolio sites have names")
    func allHaveNames() throws {
        for site in try loadSites() {
            #expect(!site.name.isEmpty)
        }
    }

    @Test("All portfolio sites have valid URLs")
    func allHaveValidURLs() throws {
        for site in try loadSites() {
            #expect(site.url.hasPrefix("http"), "URL for \(site.name) doesn't start with http: \(site.url)")
        }
    }

    @Test("Non-empty thumbnails are site-relative image paths")
    func thumbnailsAreImagePaths() throws {
        for site in try loadSites() where !site.thumbnail.isEmpty {
            #expect(site.thumbnail.hasPrefix("/images/"), "Thumbnail for \(site.name) is not under /images/: \(site.thumbnail)")
        }
    }

    @Test("Every evidence link is an http URL")
    func evidenceLinksAreURLs() throws {
        for site in try loadSites() {
            for link in site.evidence ?? [] {
                #expect(!link.label.isEmpty, "Evidence on \(site.name) has an empty label")
                #expect(link.url.hasPrefix("http"), "Evidence '\(link.label)' on \(site.name) is not http: \(link.url)")
            }
        }
    }

    @Test("Every open-source entry states an outcome and at least one evidence link")
    func openSourceEntriesAreVerifiable() throws {
        for site in try loadSites() where site.resolvedCategory == .openSource {
            let outcome = try #require(site.outcome, "\(site.name) has no outcome")
            #expect(!outcome.isEmpty, "\(site.name) has an empty outcome")
            let evidence = try #require(site.evidence, "\(site.name) has no evidence array")
            #expect(!evidence.isEmpty, "\(site.name) has no evidence link")
        }
    }

    @Test("Every category is represented")
    func everyCategoryRepresented() throws {
        let present = Set(try loadSites().map(\.resolvedCategory))
        #expect(present == Set(PortfolioCategory.allCases))
    }

    @Test("Grouping preserves declared category order and file order within a group")
    func groupingOrder() throws {
        let sites = try loadSites()
        let groups = PortfolioData.grouped(sites)
        #expect(groups.map(\.category) == PortfolioCategory.allCases.filter { c in sites.contains { $0.resolvedCategory == c } })
        for group in groups {
            let expected = sites.filter { $0.resolvedCategory == group.category }.map(\.name)
            #expect(group.sites.map(\.name) == expected)
        }
    }

    // MARK: - Model behavior

    @Test("Missing category resolves to product")
    func missingCategoryDefaultsToProduct() throws {
        let json = Data(#"[{"name":"X","url":"https://example.com","thumbnail":"","summary":null}]"#.utf8)
        let sites = try JSONDecoder().decode([PortfolioSite].self, from: json)
        let site = try #require(sites.first)
        #expect(site.category == nil)
        #expect(site.resolvedCategory == .product)
        #expect(site.evidence == nil)
    }

    @Test("Category decodes from its raw value and has a display name")
    func categoryDecoding() throws {
        let decoded = try JSONDecoder().decode(PortfolioCategory.self, from: Data(#""open-source""#.utf8))
        #expect(decoded == .openSource)
        #expect(decoded.displayName == "Open Source")
        #expect(PortfolioCategory.product.displayName == "Products")
        #expect(PortfolioCategory.media.displayName == "Media & Publishing")
    }

    @Test("PortfolioSite round-trips through Codable")
    func codableRoundTrip() throws {
        let original = PortfolioSite(
            name: "Test", url: "https://example.com", thumbnail: "/img/test.png", summary: "A test site",
            category: .openSource, role: "Author", period: "2026", outcome: "It works",
            evidence: [PortfolioEvidence(label: "Proof", url: "https://example.com/proof")]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PortfolioSite.self, from: data)
        #expect(decoded.name == original.name)
        #expect(decoded.url == original.url)
        #expect(decoded.thumbnail == original.thumbnail)
        #expect(decoded.summary == original.summary)
        #expect(decoded.category == .openSource)
        #expect(decoded.role == "Author")
        #expect(decoded.period == "2026")
        #expect(decoded.outcome == "It works")
        #expect(decoded.evidence?.first?.label == "Proof")
    }

    @Test("Invalid JSON throws")
    func invalidJSON() {
        let bad = Data("[{ invalid }]".utf8)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([PortfolioSite].self, from: bad)
        }
    }
}
