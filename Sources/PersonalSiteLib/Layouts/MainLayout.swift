import Foundation
import Ignite

/// The shared site layout applied to all pages.
///
/// Includes a single JSON-LD `@graph` with cross-referenced nodes (Person, WebSite,
/// WebPage/ProfilePage/CollectionPage, Article, BreadcrumbList), Open Graph / Twitter
/// meta tags, Google Tag Manager, and the site header/footer chrome.
public struct MainLayout: Layout {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    @Environment(\.articles) var articles

    /// Creates a new main layout.
    public init() {}

    /// The full document including head metadata, structured data, and body chrome.
    public var body: some Document {
        Head {
            MetaLink(href: "/css/main.css", rel: .stylesheet)

            MetaTag(name: "fediverse:creator", content: "@jpurnell@mastodon.social")

            // OG / Twitter meta tags
            MetaTag(property: "og:description", content: PersonalSite().description ?? "")
            MetaTag(property: "og:image", content: "https://www.justinpurnell.com/images/headshot.jpg")
            MetaTag(name: "twitter:description", content: PersonalSite().description ?? "")
            MetaTag(name: "twitter:image", content: "https://www.justinpurnell.com/images/headshot.jpg")

            // Google Tag Manager
            Script(code: """
                (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
                new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
                j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
                'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
                })(window,document,'script','dataLayer','GTM-K3TZS8J');
            """)

            // JSON-LD — single @graph with cross-referenced nodes
            if let graphJSON = SiteGraphBuilder.buildGraph(
                pageURL: page.url.absoluteString,
                pageTitle: page.title,
                pageDescription: page.description,
                pageType: resolvePageType(),
                sameAs: socialLinkList.map(\.link)
            ) {
                StructuredData(json: graphJSON)
            }
        }

        Body {
            Include("GTM.html")
            SiteHeader()
            content
            SiteFooter()
            Script(file: "/js/theme-toggle.js")
        }
    }

    private func resolvePageType() -> SitePageType {
        let path = page.url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        if path.isEmpty {
            return .home
        }

        if page.title == "CV" {
            let cvNodes: [[String: Any]]
            if let cv = decode("cv.json", as: CurriculumVitae.self) {
                cvNodes = CVStructuredData.graphNodes(from: cv)
            } else {
                cvNodes = []
            }
            return .cv(graphNodes: cvNodes)
        }

        if page.title == "Projects" && path == "projects" {
            return .collection
        }

        let isArticlePage = (path.contains("projects/") || path.contains("BusinessMath/"))
            && !page.title.isEmpty
        if isArticlePage {
            let formatter = ISO8601DateFormatter()
            let matchingArticle = articles.all.first { $0.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) == path }
            let datePublished = formatter.string(from: matchingArticle?.date ?? Date.now)
            let dateModified: String? = {
                guard let article = matchingArticle,
                      article.lastModified != article.date else { return nil }
                return formatter.string(from: article.lastModified)
            }()
            let image: String? = {
                guard let img = matchingArticle?.image else { return nil }
                let base = "https://www.justinpurnell.com"
                return img.hasPrefix("/") ? base + img : img
            }()
            return .article(datePublished: datePublished, dateModified: dateModified, image: image)
        }

        return .standard
    }
}
