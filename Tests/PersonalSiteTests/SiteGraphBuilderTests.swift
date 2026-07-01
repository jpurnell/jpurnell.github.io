import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("SiteGraphBuilder")
struct SiteGraphBuilderTests {

    private static let sameAs = [
        "https://www.linkedin.com/in/justinpurnell/",
        "https://mastodon.social/@jpurnell"
    ]

    // MARK: - Structural Tests

    @Test("Output contains single @graph with @context")
    func singleGraph() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com",
            pageTitle: "Justin Purnell",
            pageDescription: "Test",
            pageType: .home,
            sameAs: Self.sameAs
        ))

        let parsed = try #require(parseJSON(json))
        #expect(parsed["@context"] as? String == "https://schema.org")
        let graph = try #require(parsed["@graph"] as? [[String: Any]])
        #expect(!graph.isEmpty)
    }

    @Test("No standalone Organization node in graph")
    func noStandaloneOrganization() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com",
            pageTitle: "Justin Purnell",
            pageDescription: "Test",
            pageType: .home,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let orgNodes = graph.filter { ($0["@type"] as? String) == "Organization" }
        #expect(orgNodes.isEmpty, "Organization should not be a top-level graph node")
    }

    @Test("All @id references resolve to existing nodes")
    func idReferencesResolve() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/projects/test-project",
            pageTitle: "Test Project",
            pageDescription: "A test",
            pageType: .article(datePublished: "2025-03-30T00:00:00Z", dateModified: "2025-04-01T00:00:00Z", image: nil),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let definedIDs = Set(graph.compactMap { $0["@id"] as? String })

        for node in graph {
            for (_, value) in node {
                if let ref = value as? [String: Any], let refID = ref["@id"] as? String {
                    #expect(definedIDs.contains(refID), "Reference \(refID) not found in graph")
                }
            }
        }
    }

    // MARK: - Homepage

    @Test("Homepage contains Person, WebSite, ProfilePage")
    func homepageNodeTypes() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com",
            pageTitle: "Justin Purnell",
            pageDescription: "Founder of Ledge Partners.",
            pageType: .home,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let types = Set(graph.compactMap { $0["@type"] as? String })
        #expect(types.contains("Person"))
        #expect(types.contains("WebSite"))
        #expect(types.contains("ProfilePage"))
    }

    @Test("Homepage has no BreadcrumbList")
    func homepageNoBreadcrumbs() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com",
            pageTitle: "Justin Purnell",
            pageDescription: "Test",
            pageType: .home,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let types = Set(graph.compactMap { $0["@type"] as? String })
        #expect(!types.contains("BreadcrumbList"))
    }

    @Test("Homepage WebSite is full (has description and publisher)")
    func homepageFullWebSite() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com",
            pageTitle: "Justin Purnell",
            pageDescription: "Founder of Ledge Partners.",
            pageType: .home,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let webSite = try #require(graph.first { ($0["@type"] as? String) == "WebSite" })
        let desc = try #require(webSite["description"] as? String)
        #expect(desc.contains("Ledge Partners"))
        #expect(webSite["inLanguage"] as? String == "en")
        let publisher = try #require(webSite["publisher"] as? [String: Any])
        #expect(publisher["@id"] as? String == "https://www.justinpurnell.com/#person")
    }

    @Test("Homepage ProfilePage has mainEntity referencing Person")
    func homepageProfilePageMainEntity() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com",
            pageTitle: "Justin Purnell",
            pageDescription: "Test",
            pageType: .home,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let profilePage = try #require(graph.first { ($0["@type"] as? String) == "ProfilePage" })
        let mainEntity = try #require(profilePage["mainEntity"] as? [String: Any])
        #expect(mainEntity["@id"] as? String == "https://www.justinpurnell.com/#person")
    }

    // MARK: - Project (Article) Page

    @Test("Project page contains Person, WebSite, WebPage, Article, BreadcrumbList")
    func projectPageNodeTypes() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/projects/test",
            pageTitle: "Test Project",
            pageDescription: "A test project",
            pageType: .article(datePublished: "2025-03-30T00:00:00Z", dateModified: nil, image: nil),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let types = Set(graph.compactMap { $0["@type"] as? String })
        #expect(types.contains("Person"))
        #expect(types.contains("WebSite"))
        #expect(types.contains("WebPage"))
        #expect(types.contains("Article"))
        #expect(types.contains("BreadcrumbList"))
    }

    @Test("Article references Person via @id for author and publisher")
    func articleAuthorPublisherReferences() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/projects/test",
            pageTitle: "Test Project",
            pageDescription: "A test project",
            pageType: .article(datePublished: "2025-03-30T00:00:00Z", dateModified: nil, image: nil),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let article = try #require(graph.first { ($0["@type"] as? String) == "Article" })

        let author = try #require(article["author"] as? [String: Any])
        #expect(author["@id"] as? String == "https://www.justinpurnell.com/#person")

        let publisher = try #require(article["publisher"] as? [String: Any])
        #expect(publisher["@id"] as? String == "https://www.justinpurnell.com/#person")
    }

    @Test("Article includes datePublished and dateModified")
    func articleDates() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/projects/test",
            pageTitle: "Test Project",
            pageDescription: "A test project",
            pageType: .article(datePublished: "2025-03-30T00:00:00Z", dateModified: "2025-04-01T00:00:00Z", image: nil),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let article = try #require(graph.first { ($0["@type"] as? String) == "Article" })
        #expect(article["datePublished"] as? String == "2025-03-30T00:00:00Z")
        #expect(article["dateModified"] as? String == "2025-04-01T00:00:00Z")
    }

    @Test("Article mainEntityOfPage references WebPage")
    func articleMainEntityOfPage() throws {
        let pageURL = "https://www.justinpurnell.com/projects/test"
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: pageURL,
            pageTitle: "Test",
            pageDescription: "A test",
            pageType: .article(datePublished: "2025-03-30T00:00:00Z", dateModified: nil, image: nil),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let article = try #require(graph.first { ($0["@type"] as? String) == "Article" })
        let mainEntity = try #require(article["mainEntityOfPage"] as? [String: Any])
        #expect(mainEntity["@id"] as? String == "\(pageURL)#webpage")
    }

    @Test("Article includes image when provided")
    func articleImage() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/projects/test",
            pageTitle: "Test",
            pageDescription: "A test",
            pageType: .article(datePublished: "2025-03-30T00:00:00Z", dateModified: nil, image: "https://www.justinpurnell.com/images/test.jpg"),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let article = try #require(graph.first { ($0["@type"] as? String) == "Article" })
        #expect(article["image"] as? String == "https://www.justinpurnell.com/images/test.jpg")
    }

    // MARK: - Projects Index (Collection)

    @Test("Projects index contains CollectionPage instead of WebPage")
    func collectionPageType() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/projects",
            pageTitle: "Projects",
            pageDescription: "Project list",
            pageType: .collection,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let types = Set(graph.compactMap { $0["@type"] as? String })
        #expect(types.contains("CollectionPage"))
        #expect(!types.contains("WebPage"))
    }

    // MARK: - CV Page

    @Test("CV page contains ProfilePage with mainEntity")
    func cvPageProfilePage() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/c-v",
            pageTitle: "CV",
            pageDescription: "Curriculum Vitae",
            pageType: .cv(graphNodes: []),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let profilePage = try #require(graph.first { ($0["@type"] as? String) == "ProfilePage" })
        let mainEntity = try #require(profilePage["mainEntity"] as? [String: Any])
        #expect(mainEntity["@id"] as? String == "https://www.justinpurnell.com/#person")
    }

    @Test("CV page Person includes hasOccupation and hasCredential")
    func cvPageFullPerson() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/c-v",
            pageTitle: "CV",
            pageDescription: "Curriculum Vitae",
            pageType: .cv(graphNodes: []),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let person = try #require(graph.first { ($0["@type"] as? String) == "Person" })
        let occupations = try #require(person["hasOccupation"] as? [[String: Any]])
        #expect(occupations.count == 5)
        let credentials = try #require(person["hasCredential"] as? [[String: Any]])
        #expect(credentials.count == 2)
        let alumni = try #require(person["alumniOf"] as? [[String: String]])
        #expect(alumni.count == 2)
    }

    @Test("CV page merges external graph nodes")
    func cvPageMergesExternalNodes() throws {
        let externalNodes: [[String: Any]] = [
            ["@type": "Corporation", "name": "Test Corp"],
            ["@type": "Article", "name": "Test Publication"]
        ]

        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/c-v",
            pageTitle: "CV",
            pageDescription: "Curriculum Vitae",
            pageType: .cv(graphNodes: externalNodes),
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let corpNode = try #require(graph.first { ($0["@type"] as? String) == "Corporation" })
        #expect(corpNode["name"] as? String == "Test Corp")
    }

    // MARK: - Standard Page

    @Test("Standard page contains WebPage, not ProfilePage or CollectionPage")
    func standardPageType() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/about",
            pageTitle: "About",
            pageDescription: "About page",
            pageType: .standard,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let types = Set(graph.compactMap { $0["@type"] as? String })
        #expect(types.contains("WebPage"))
        #expect(!types.contains("ProfilePage"))
        #expect(!types.contains("CollectionPage"))
    }

    // MARK: - Slim vs Full Person

    @Test("Standard page Person has no hasOccupation or hasCredential")
    func standardPageSlimPerson() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/about",
            pageTitle: "About",
            pageDescription: "About page",
            pageType: .standard,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let person = try #require(graph.first { ($0["@type"] as? String) == "Person" })
        #expect(person["hasOccupation"] == nil, "Slim Person should not include hasOccupation")
        #expect(person["hasCredential"] == nil, "Slim Person should not include hasCredential")
        let sameAs = try #require(person["sameAs"] as? [String])
        #expect(sameAs.count == 2, "Slim Person should include sameAs links")
        #expect(person["@id"] as? String == "https://www.justinpurnell.com/#person")
    }

    // MARK: - WebPage isPartOf and breadcrumb

    @Test("WebPage links to WebSite via isPartOf")
    func webPageIsPartOf() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/about",
            pageTitle: "About",
            pageDescription: "About page",
            pageType: .standard,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let webPage = try #require(graph.first { ($0["@type"] as? String) == "WebPage" })
        let isPartOf = try #require(webPage["isPartOf"] as? [String: Any])
        #expect(isPartOf["@id"] as? String == "https://www.justinpurnell.com/#website")
    }

    @Test("WebPage links to BreadcrumbList via breadcrumb")
    func webPageBreadcrumbRef() throws {
        let pageURL = "https://www.justinpurnell.com/about"
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: pageURL,
            pageTitle: "About",
            pageDescription: "About page",
            pageType: .standard,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let webPage = try #require(graph.first { ($0["@type"] as? String) == "WebPage" })
        let breadcrumb = try #require(webPage["breadcrumb"] as? [String: Any])
        #expect(breadcrumb["@id"] as? String == "\(pageURL)#breadcrumb")
    }

    // MARK: - Non-homepage WebSite is slim

    @Test("Non-homepage WebSite omits description")
    func slimWebSite() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/about",
            pageTitle: "About",
            pageDescription: "About page",
            pageType: .standard,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let webSite = try #require(graph.first { ($0["@type"] as? String) == "WebSite" })
        #expect(webSite["description"] == nil, "Slim WebSite should omit description")
    }

    // MARK: - BreadcrumbList structure

    @Test("BreadcrumbList contains Home and current page")
    func breadcrumbListItems() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com/about",
            pageTitle: "About",
            pageDescription: "About page",
            pageType: .standard,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let breadcrumb = try #require(graph.first { ($0["@type"] as? String) == "BreadcrumbList" })
        let items = try #require(breadcrumb["itemListElement"] as? [[String: Any]])
        #expect(items.count == 2)
        #expect(items[0]["name"] as? String == "Home")
        #expect(items[0]["position"] as? Int == 1)
        #expect(items[1]["name"] as? String == "About")
        #expect(items[1]["position"] as? Int == 2)
    }

    // MARK: - All nodes have inLanguage where appropriate

    @Test("Page-level and WebSite nodes include inLanguage on homepage")
    func inLanguagePresent() throws {
        let json = try #require(SiteGraphBuilder.buildGraph(
            pageURL: "https://www.justinpurnell.com",
            pageTitle: "Justin Purnell",
            pageDescription: "Test",
            pageType: .home,
            sameAs: Self.sameAs
        ))

        let graph = try #require(graphNodes(from: json))
        let profilePage = try #require(graph.first { ($0["@type"] as? String) == "ProfilePage" })
        #expect(profilePage["inLanguage"] as? String == "en")
    }

    // MARK: - Helpers

    private func parseJSON(_ json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return obj
    }

    private func graphNodes(from json: String) -> [[String: Any]]? {
        guard let parsed = parseJSON(json) else { return nil }
        return parsed["@graph"] as? [[String: Any]]
    }
}
