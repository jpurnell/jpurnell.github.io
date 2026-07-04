import Foundation
#if canImport(os)
import os
#endif

/// Page classification for JSON-LD graph generation.
public enum SitePageType {
    /// The site homepage — gets ProfilePage + full WebSite.
    case home
    /// The CV page — gets ProfilePage + full Person + merged CV graph nodes.
    case cv(graphNodes: [[String: Any]])
    /// A collection/index page (e.g. Projects list) — gets CollectionPage.
    case collection
    /// An article/project page — gets Article + WebPage.
    case article(datePublished: String, dateModified: String?, image: String?)
    /// Any other page — gets WebPage.
    case standard
}

/// Builds a single JSON-LD `@graph` for any page on justinpurnell.com.
///
/// Produces one `<script type="application/ld+json">` block with cross-referenced
/// nodes using `@id`, replacing the previous approach of multiple disconnected blocks.
public enum SiteGraphBuilder {

    private static let siteURL = "https://www.justinpurnell.com"
    private static let siteName = "Justin Purnell"
    private static let personName = "Justin Purnell"
    private static let personImage = "https://www.justinpurnell.com/images/headshot.jpg"
    private static let personDescription = "Founder of Ledge Partners. Former Goldman Sachs credit analyst, Head of Product at Hotels at Home, VP at NBCUniversal. Princeton '00, Tuck MBA."
    private static let personJobTitle = "Founder"

    /// Builds a complete JSON-LD `@graph` string for a page.
    ///
    /// - Parameters:
    ///   - pageURL: The full URL of the current page.
    ///   - pageTitle: The page's `<title>` content.
    ///   - pageDescription: The page's meta description.
    ///   - pageType: The classification of this page.
    ///   - sameAs: Social profile URLs for the Person node.
    /// - Returns: A JSON string containing `@context` and `@graph`, or `nil` on serialization failure.
    public static func buildGraph(
        pageURL: String,
        pageTitle: String,
        pageDescription: String,
        pageType: SitePageType,
        sameAs: [String]
    ) -> String? {
        var graph: [[String: Any]] = []

        let isHome = isHomePage(pageURL)
        let isCV: Bool
        var cvNodes: [[String: Any]] = []
        if case .cv(let nodes) = pageType {
            isCV = true
            cvNodes = nodes
        } else {
            isCV = false
        }

        graph.append(personNode(full: isCV, sameAs: sameAs))
        graph.append(webSiteNode(full: isHome))

        if !isHome {
            graph.append(breadcrumbNode(pageURL: pageURL, pageTitle: pageTitle))
        }

        switch pageType {
        case .home:
            graph.append(profilePageNode(pageURL: pageURL, pageTitle: pageTitle, pageDescription: pageDescription))

        case .cv:
            graph.append(profilePageNode(pageURL: pageURL, pageTitle: pageTitle, pageDescription: pageDescription))
            graph.append(contentsOf: cvNodes)

        case .collection:
            graph.append(collectionPageNode(pageURL: pageURL, pageTitle: pageTitle, pageDescription: pageDescription))

        case .article(let datePublished, let dateModified, let image):
            graph.append(webPageNode(pageURL: pageURL, pageTitle: pageTitle, pageDescription: pageDescription))
            graph.append(articleNode(
                pageURL: pageURL,
                headline: pageTitle,
                description: pageDescription,
                datePublished: datePublished,
                dateModified: dateModified,
                image: image
            ))

        case .standard:
            graph.append(webPageNode(pageURL: pageURL, pageTitle: pageTitle, pageDescription: pageDescription))
        }

        let wrapper: [String: Any] = [
            "@context": "https://schema.org",
            "@graph": graph
        ]

        return toJSON(wrapper)
    }

    // MARK: - Node Builders

    private static func personNode(full: Bool, sameAs: [String]) -> [String: Any] {
        var person: [String: Any] = [
            "@type": "Person",
            "@id": "\(siteURL)/#person",
            "name": personName,
            "url": siteURL,
            "image": personImage,
            "description": personDescription,
            "jobTitle": personJobTitle,
            "worksFor": [
                "@type": "Organization",
                "name": "Ledge Partners",
                "url": "https://www.ledgepartners.com"
            ] as [String: Any],
            "sameAs": sameAs,
            "knowsAbout": [
                "Product Strategy", "AI/ML", "Digital Transformation",
                "Corporate Finance", "Swift Development", "E-Commerce",
                "Credit Analysis", "Search Funds", "Streaming Media",
                "Team Leadership"
            ] as [String]
        ]

        if full {
            person["address"] = [
                "@type": "PostalAddress",
                "addressLocality": "New York",
                "addressRegion": "NY",
                "addressCountry": "US"
            ] as [String: String]

            person["alumniOf"] = [
                [
                    "@type": "CollegeOrUniversity",
                    "name": "Princeton University",
                    "url": "https://www.princeton.edu"
                ] as [String: String],
                [
                    "@type": "CollegeOrUniversity",
                    "name": "Tuck School of Business at Dartmouth",
                    "url": "https://www.tuck.dartmouth.edu"
                ] as [String: String]
            ] as [[String: String]]

            person["hasCredential"] = [
                [
                    "@type": "EducationalOccupationalCredential",
                    "credentialCategory": "degree",
                    "name": "A.B. in Economics",
                    "recognizedBy": [
                        "@type": "CollegeOrUniversity",
                        "name": "Princeton University"
                    ] as [String: String]
                ] as [String: Any],
                [
                    "@type": "EducationalOccupationalCredential",
                    "credentialCategory": "degree",
                    "name": "Masters in Business Administration",
                    "recognizedBy": [
                        "@type": "CollegeOrUniversity",
                        "name": "Tuck School of Business at Dartmouth"
                    ] as [String: String]
                ] as [String: Any]
            ] as [[String: Any]]

            person["hasOccupation"] = [
                occupation(name: "Founder", description: "Search fund formed to acquire and operate a profitable business", city: "New York, NY"),
                occupation(name: "Head of Product", description: "Led re-platforming of 70+ global e-commerce sites across 40+ hospitality brands", city: "Fairfield, NJ"),
                occupation(name: "Interim Vice President, Strategy & Business Development", description: "Directed business development initiatives for NBCUniversal Digital", city: "New York, NY"),
                occupation(name: "Director, Content Strategy & Operations", description: "Led retention initiatives increasing customer Lifetime Value by 40% at Seeso", city: "New York, NY"),
                occupation(name: "Credit Analyst & Risk Manager", description: "Published 400+ research reports covering Energy, Gaming, Lodging & Leisure high yield credit", city: "New York, NY")
            ] as [[String: Any]]
        }

        return person
    }

    private static func occupation(name: String, description: String, city: String) -> [String: Any] {
        [
            "@type": "Occupation",
            "name": name,
            "description": description,
            "occupationLocation": [
                "@type": "City",
                "name": city
            ] as [String: String]
        ] as [String: Any]
    }

    private static func webSiteNode(full: Bool) -> [String: Any] {
        var node: [String: Any] = [
            "@type": "WebSite",
            "@id": "\(siteURL)/#website",
            "name": siteName,
            "url": siteURL
        ]

        if full {
            node["description"] = "\(personName) — \(personDescription)"
            node["inLanguage"] = "en"
            node["publisher"] = ["@id": "\(siteURL)/#person"] as [String: String]
        }

        return node
    }

    private static func breadcrumbNode(pageURL: String, pageTitle: String) -> [String: Any] {
        [
            "@type": "BreadcrumbList",
            "@id": "\(pageURL)#breadcrumb",
            "itemListElement": [
                [
                    "@type": "ListItem",
                    "position": 1,
                    "name": "Home",
                    "item": siteURL
                ] as [String: Any],
                [
                    "@type": "ListItem",
                    "position": 2,
                    "name": pageTitle,
                    "item": pageURL
                ] as [String: Any]
            ]
        ] as [String: Any]
    }

    private static func profilePageNode(pageURL: String, pageTitle: String, pageDescription: String) -> [String: Any] {
        var node: [String: Any] = [
            "@type": "ProfilePage",
            "@id": "\(pageURL)#webpage",
            "url": pageURL,
            "name": pageTitle,
            "inLanguage": "en",
            "isPartOf": ["@id": "\(siteURL)/#website"] as [String: String],
            "mainEntity": ["@id": "\(siteURL)/#person"] as [String: String]
        ]

        if !isHomePage(pageURL) {
            node["breadcrumb"] = ["@id": "\(pageURL)#breadcrumb"] as [String: String]
        }

        return node
    }

    private static func collectionPageNode(pageURL: String, pageTitle: String, pageDescription: String) -> [String: Any] {
        [
            "@type": "CollectionPage",
            "@id": "\(pageURL)#webpage",
            "url": pageURL,
            "name": pageTitle,
            "description": pageDescription,
            "inLanguage": "en",
            "isPartOf": ["@id": "\(siteURL)/#website"] as [String: String],
            "breadcrumb": ["@id": "\(pageURL)#breadcrumb"] as [String: String]
        ] as [String: Any]
    }

    private static func webPageNode(pageURL: String, pageTitle: String, pageDescription: String) -> [String: Any] {
        [
            "@type": "WebPage",
            "@id": "\(pageURL)#webpage",
            "url": pageURL,
            "name": pageTitle,
            "description": pageDescription,
            "inLanguage": "en",
            "isPartOf": ["@id": "\(siteURL)/#website"] as [String: String],
            "breadcrumb": ["@id": "\(pageURL)#breadcrumb"] as [String: String]
        ] as [String: Any]
    }

    private static func articleNode(
        pageURL: String,
        headline: String,
        description: String,
        datePublished: String,
        dateModified: String?,
        image: String?
    ) -> [String: Any] {
        var node: [String: Any] = [
            "@type": "Article",
            "@id": "\(pageURL)#article",
            "url": pageURL,
            "headline": headline,
            "description": description,
            "inLanguage": "en",
            "datePublished": datePublished,
            "author": ["@id": "\(siteURL)/#person"] as [String: String],
            "publisher": ["@id": "\(siteURL)/#person"] as [String: String],
            "mainEntityOfPage": ["@id": "\(pageURL)#webpage"] as [String: String],
            "isPartOf": ["@id": "\(siteURL)/#website"] as [String: String]
        ]

        if let dateModified {
            node["dateModified"] = dateModified
        }

        if let image {
            node["image"] = image
        }

        return node
    }

    // MARK: - Helpers

    private static func isHomePage(_ pageURL: String) -> Bool {
        let trimmed = pageURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed == siteURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private static func toJSON(_ dict: [String: Any]) -> String? {
        guard JSONSerialization.isValidJSONObject(dict) else { return nil }

        let data: Data
        do {
            data = try JSONSerialization.data(
                withJSONObject: dict,
                options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            )
        } catch {
            Logger(subsystem: "com.justinpurnell", category: "SiteGraphBuilder")
                .error("JSON-LD serialization failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
