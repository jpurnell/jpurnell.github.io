import Testing
@testable import PersonalSiteLib

@Suite("SocialLink")
struct SocialLinkTests {

    @Test("socialLinkList is non-empty")
    func listNonEmpty() {
        #expect(!socialLinkList.isEmpty)
    }

    @Test("All social links have valid URLs")
    func allLinksHaveURLs() {
        for link in socialLinkList {
            #expect(link.link.hasPrefix("https://"), "Link for \(link.site) doesn't use HTTPS: \(link.link)")
        }
    }

    @Test("All social links have non-empty site names")
    func allLinksHaveSiteNames() {
        for link in socialLinkList {
            #expect(!link.site.isEmpty)
        }
    }

    @Test("fullLink generates correct SVG path")
    func fullLinkPath() {
        let link = SocialLink(site: "Test", logoImage: "testlogo", link: "https://example.com")
        #expect(link.fullLink == "/images/social/testlogo.svg")
    }

    @Test("Expected platforms are present")
    func expectedPlatforms() {
        let platforms = Set(socialLinkList.map(\.site))
        #expect(platforms.contains("LinkedIn"))
        #expect(platforms.contains("Bluesky"))
        #expect(platforms.contains("Mastodon"))
    }
}
