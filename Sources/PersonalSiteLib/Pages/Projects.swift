import Foundation
import Ignite

/// The Projects page listing all articles tagged with "project".
public struct Projects: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "Projects"
    @Environment(\.articles) var articles

    public init() {}

    public var body: some HTML {
        Text("Projects").font(.title1).class("mainTitle")
        List {
            for article in articles.all.filter({ $0.tags?.contains("project") ?? false }) {
                Text {
                    Link(article.metadata["title"] as? String ?? article.title, target: article.path)
                }.font(.title2).fontWeight(.semibold).class("subTitle")
            }
        }
    }
}
