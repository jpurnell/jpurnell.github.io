import Foundation
import Ignite

/// The shared site layout applied to all pages.
///
/// Includes JSON-LD structured data (Person, WebSite, breadcrumbs), Open Graph / Twitter meta tags,
/// Google Tag Manager, and the site header/footer chrome.
public struct MainLayout: Layout {
    @Environment(\.page) var page
    @Environment(\.decode) var decode

    public init() {}

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

            // JSON-LD Structured Data — Person
            StructuredData("Person", properties: [
                "name": "Justin Purnell",
                "url": "https://www.justinpurnell.com",
                "image": "https://www.justinpurnell.com/images/headshot.jpg",
                "description": "Founder of Ledge Partners. Former Goldman Sachs credit analyst, Head of Product at Hotels at Home, VP at NBCUniversal. Princeton '00, Tuck MBA.",
                "jobTitle": "Founder",
                "worksFor": [
                    "@type": "Organization",
                    "name": "Ledge Partners",
                    "url": "https://www.ledgepartners.com"
                ] as [String: Any],
                "address": [
                    "@type": "PostalAddress",
                    "addressLocality": "New York",
                    "addressRegion": "NY",
                    "addressCountry": "US"
                ] as [String: String],
                "alumniOf": [
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
                ] as [[String: String]],
                "hasCredential": [
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
                ] as [[String: Any]],
                "hasOccupation": [
                    [
                        "@type": "Occupation",
                        "name": "Founder",
                        "description": "Search fund formed to acquire and operate a profitable business",
                        "occupationLocation": [
                            "@type": "City",
                            "name": "New York, NY"
                        ] as [String: String]
                    ] as [String: Any],
                    [
                        "@type": "Occupation",
                        "name": "Head of Product",
                        "description": "Led re-platforming of 70+ global e-commerce sites across 40+ hospitality brands",
                        "occupationLocation": [
                            "@type": "City",
                            "name": "Fairfield, NJ"
                        ] as [String: String]
                    ] as [String: Any],
                    [
                        "@type": "Occupation",
                        "name": "Interim Vice President, Strategy & Business Development",
                        "description": "Directed business development initiatives for NBCUniversal Digital",
                        "occupationLocation": [
                            "@type": "City",
                            "name": "New York, NY"
                        ] as [String: String]
                    ] as [String: Any],
                    [
                        "@type": "Occupation",
                        "name": "Director, Content Strategy & Operations",
                        "description": "Led retention initiatives increasing customer Lifetime Value by 40% at Seeso",
                        "occupationLocation": [
                            "@type": "City",
                            "name": "New York, NY"
                        ] as [String: String]
                    ] as [String: Any],
                    [
                        "@type": "Occupation",
                        "name": "Credit Analyst & Risk Manager",
                        "description": "Published 400+ research reports covering Energy, Gaming, Lodging & Leisure high yield credit",
                        "occupationLocation": [
                            "@type": "City",
                            "name": "New York, NY"
                        ] as [String: String]
                    ] as [String: Any]
                ] as [[String: Any]],
                "knowsAbout": [
                    "Product Strategy",
                    "AI/ML",
                    "Digital Transformation",
                    "Corporate Finance",
                    "Swift Development",
                    "E-Commerce",
                    "Credit Analysis",
                    "Search Funds",
                    "Streaming Media",
                    "Team Leadership"
                ] as [String],
                "sameAs": socialLinkList.map(\.link)
            ])

            // JSON-LD — Organization (Ledge Partners)
            StructuredData.organization(
                name: "Ledge Partners",
                url: "https://www.ledgepartners.com",
                description: "Search fund formed to acquire and operate profitable businesses with a focus on operational efficiency and technology enablement.",
                foundingDate: "2023-11-07"
            )

            // JSON-LD — CV-specific schemas
            if page.title == "CV" {
                // ProfilePage signals this is an authoritative profile
                StructuredData("ProfilePage", properties: [
                    "name": "Justin Purnell — Curriculum Vitae",
                    "url": "https://www.justinpurnell.com/c-v",
                    "description": "Complete professional history for Justin Purnell: Founder of Ledge Partners, former Goldman Sachs credit analyst, Head of Product at Hotels at Home, VP at NBCUniversal. Princeton '00, Tuck MBA.",
                    "mainEntity": [
                        "@type": "Person",
                        "name": "Justin Purnell",
                        "url": "https://www.justinpurnell.com"
                    ] as [String: String],
                    "dateModified": "2025-03-30",
                    "inLanguage": "en"
                ] as [String: Any])

                // Dynamic @graph: employers, volunteer orgs, publications
                if let cv = decode("cv.json", as: CurriculumVitae.self),
                   let graphData = CVStructuredData.graph(from: cv) {
                    graphData
                }
            }

            // JSON-LD — Article schema for blog posts and project pages
            if page.url.path.contains("/projects/") || page.url.path.contains("/BusinessMath/"),
               !page.title.isEmpty,
               page.title != "Projects" {
                StructuredData("Article", properties: [
                    "headline": page.title,
                    "description": page.description,
                    "url": page.url.absoluteString,
                    "author": [
                        "@type": "Person",
                        "name": "Justin Purnell",
                        "url": "https://www.justinpurnell.com",
                        "jobTitle": "Founder, Ledge Partners",
                        "sameAs": socialLinkList.map(\.link)
                    ] as [String: Any],
                    "publisher": [
                        "@type": "Person",
                        "name": "Justin Purnell",
                        "url": "https://www.justinpurnell.com"
                    ] as [String: String],
                    "mainEntityOfPage": [
                        "@type": "WebPage",
                        "@id": page.url.absoluteString
                    ] as [String: String]
                ] as [String: Any])
            }

            StructuredData.webSite(
                name: "Justin Purnell",
                url: "https://www.justinpurnell.com",
                description: "Justin Purnell — Founder of Ledge Partners. Former Goldman Sachs credit analyst, Head of Product at Hotels at Home, VP at NBCUniversal."
            )

            StructuredData.breadcrumbs()
        }

        Body {
            Include("GTM.html")
            SiteHeader()
            content
            SiteFooter()
            Script(file: "/js/theme-toggle.js")
        }
    }
}
