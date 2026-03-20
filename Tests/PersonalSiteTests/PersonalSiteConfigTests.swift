import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("PersonalSite Config")
struct PersonalSiteConfigTests {

    @Test("Site name is set")
    @MainActor func siteName() {
        let site = PersonalSite()
        #expect(site.name == "Justin Purnell")
    }

    @Test("Site URL uses HTTPS")
    @MainActor func siteURLIsHTTPS() {
        let site = PersonalSite()
        #expect(site.url.scheme == "https")
    }

    @Test("Site URL is justinpurnell.com")
    @MainActor func siteURLDomain() {
        let site = PersonalSite()
        #expect(site.url.host == "www.justinpurnell.com")
    }

    @Test("Description is present and within SEO length")
    @MainActor func descriptionPresent() {
        let site = PersonalSite()
        #expect(site.description != nil)
        if let desc = site.description {
            #expect(!desc.isEmpty)
            #expect(desc.count <= 160, "Description exceeds 160 characters: \(desc.count)")
        }
    }

    @Test("Author is set")
    @MainActor func authorSet() {
        let site = PersonalSite()
        #expect(site.author == "Justin Purnell")
    }

    @Test("Feed configuration is present")
    @MainActor func feedConfigPresent() {
        let site = PersonalSite()
        #expect(site.feedConfiguration != nil)
    }

    @Test("Language is English")
    @MainActor func languageIsEnglish() {
        let site = PersonalSite()
        #expect(site.language == .english)
    }

    @Test("Title suffix is set")
    @MainActor func titleSuffix() {
        let site = PersonalSite()
        #expect(site.titleSuffix.contains("Justin Purnell"))
    }
}
