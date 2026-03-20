import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("Portfolio Data")
struct PortfolioDataTests {

    @Test("portfolioSites is non-empty")
    func sitesNonEmpty() {
        #expect(!portfolioSites.isEmpty)
    }

    @Test("All portfolio sites have names")
    func allHaveNames() {
        for site in portfolioSites {
            #expect(!site.name.isEmpty)
        }
    }

    @Test("All portfolio sites have valid URLs")
    func allHaveValidURLs() {
        for site in portfolioSites {
            #expect(site.url.hasPrefix("http"), "URL for \(site.name) doesn't start with http: \(site.url)")
        }
    }

    @Test("All portfolio sites have thumbnails")
    func allHaveThumbnails() {
        for site in portfolioSites {
            #expect(!site.thumbnail.isEmpty)
        }
    }

    @Test("PortfolioSite round-trips through Codable")
    func codableRoundTrip() throws {
        let original = PortfolioSite(name: "Test", url: "https://example.com", thumbnail: "/img/test.png", summary: "A test site")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PortfolioSite.self, from: data)
        #expect(decoded.name == original.name)
        #expect(decoded.url == original.url)
        #expect(decoded.thumbnail == original.thumbnail)
        #expect(decoded.summary == original.summary)
    }
}
