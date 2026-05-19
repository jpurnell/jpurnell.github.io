import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("OffsiteLink")
struct OffsiteLinkTests {

    @Test("footerLinks is non-empty")
    func footerLinksNonEmpty() {
        #expect(!footerLinks.isEmpty)
    }

    @Test("All footer links have titles")
    func allHaveTitles() {
        for link in footerLinks {
            #expect(!link.title.isEmpty)
        }
    }

    @Test("All footer links have URLs")
    func allHaveURLs() {
        for link in footerLinks {
            #expect(!link.url.isEmpty)
        }
    }

    @Test("Email link uses mailto protocol")
    func emailIsMailto() throws {
        let emailLink = try #require(footerLinks.first { $0.title == "email" })
        #expect(emailLink.url.hasPrefix("mailto:"))
    }

    @Test("RSS link points to feed.rss")
    func rssPointsToFeed() throws {
        let rssLink = try #require(footerLinks.first { $0.title == "rss" })
        #expect(rssLink.url.contains("feed.rss"))
    }

    @Test("OffsiteLink round-trips through Codable")
    func codableRoundTrip() throws {
        let original = OffsiteLink(title: "test", url: "https://example.com")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OffsiteLink.self, from: data)
        #expect(decoded.title == original.title)
        #expect(decoded.url == original.url)
    }
}
