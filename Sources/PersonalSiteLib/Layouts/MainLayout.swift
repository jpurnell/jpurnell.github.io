import Foundation
import Ignite

/// The shared site layout applied to all pages.
///
/// Includes JSON-LD structured data (Person, WebSite, breadcrumbs), Open Graph / Twitter meta tags,
/// Google Tag Manager, and the site header/footer chrome.
public struct MainLayout: Layout {
    @Environment(\.page) var page

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

            // JSON-LD Structured Data
            StructuredData("Person", properties: [
                "name": "Justin Purnell",
                "url": "https://www.justinpurnell.com",
                "jobTitle": "Founder",
                "worksFor": [
                    "@type": "Organization",
                    "name": "Ledge Partners"
                ] as [String: String],
                "alumniOf": [
                    [
                        "@type": "CollegeOrUniversity",
                        "name": "Princeton University"
                    ] as [String: String],
                    [
                        "@type": "CollegeOrUniversity",
                        "name": "Tuck School of Business at Dartmouth"
                    ] as [String: String]
                ] as [[String: String]],
                "knowsAbout": ["Product Strategy", "AI/ML", "Digital Transformation", "Corporate Finance", "Swift Development"] as [String],
                "sameAs": socialLinkList.map(\.link)
            ])

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
