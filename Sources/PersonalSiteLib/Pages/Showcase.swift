import Foundation
import Ignite

/// The Showcase page listing all articles tagged with "showcase", sorted by date.
public struct Showcase: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "Developer Showcase"
    @Environment(\.articles) var articles

    public init() {}

    public var body: some HTML {
        Text("Developer Showcase").font(.title1).class("mainTitle")

        Text("AI-generated narratives and infographics exploring the development history of selected projects.")
            .class("blurb")
            .style(.marginBottom, "2em")

        List {
            for article in articles.all
                .filter({ $0.tags?.contains("showcase") ?? false })
                .sorted(by: { $0.date > $1.date })
            {
                Group {
                    Text {
                        Link(article.metadata["title"] as? String ?? article.title, target: article.path)
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .class("subTitle")

                    Text(article.metadata["description"] as? String ?? "")
                        .class("blurb")
                        .style(.marginBottom, "1em")
                }
            }
        }
    }
}
