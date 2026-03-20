import Testing
@testable import PersonalSiteLib

@Suite("Page Metadata")
struct PageMetadataTests {

    @Test("Home page has correct title")
    @MainActor func homeTitle() {
        let page = Home()
        #expect(page.title.contains("Justin Purnell"))
    }

    @Test("About page has correct title")
    @MainActor func aboutTitle() {
        let page = About()
        #expect(page.title == "About")
    }

    @Test("CV page has correct title")
    @MainActor func cvTitle() {
        let page = CV()
        #expect(page.title == "CV")
    }

    @Test("Portfolio page has correct title")
    @MainActor func portfolioTitle() {
        let page = Portfolio()
        #expect(page.title == "Portfolio")
    }

    @Test("Projects page has correct title")
    @MainActor func projectsTitle() {
        let page = Projects()
        #expect(page.title == "Projects")
    }

    @Test("BusinessMath page has correct title")
    @MainActor func businessMathTitle() {
        let page = BusinessMath()
        #expect(page.title == "BusinessMath")
    }

    @Test("NeXT page has correct title")
    @MainActor func nextTitle() {
        let page = NeXT()
        #expect(page.title == "NeXT")
    }
}
