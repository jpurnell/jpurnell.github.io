import Foundation
import Ignite

/// Article page layout for project pages, appending the site title suffix and listing non-"project" tags.
public struct ProjectLayout: ArticlePage {
    public init() {}

    public var body: some HTML {
        Text((article.metadata["title"] as? String ?? article.title).appending(PersonalSite().titleSuffix))
            .font(.title1)
            .fontWeight(.semibold)
            .class("mainTitle")
        Text(markdown: article.text).frame(width: .percent(70%), maxWidth: .px(800))
        if !(article.tags?.isEmpty ?? true) {
            Group {
                Text("Tagged with: \((article.tags ?? []).filter({ $0 != "project" }).joined(separator: ", "))")
            }
        }
    }
}
