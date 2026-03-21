import Foundation
import Ignite

/// The About page, rendering the `about-Justin` article with a profile photo.
public struct About: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "About"
    @Environment(\.articles) var articles

    public init() {}

    public var body: some HTML {
        Text("About").font(.title1).class("mainTitle")
        ForEach(articles.all.filter({ $0.path.contains("about-Justin") })) { article in
            Image(article.image ?? "default", description: (article.metadata["imageDescription"] as? String) ?? "Justin Purnell")
                .resizable()
                .frame(width: 150, height: 150)
                .style(.float, "left")
                .style(.marginRight, "1%")
                .style(.marginBottom, "1%")
            Text(markdown: article.text).frame(width: .percent(70%), maxWidth: .px(800))
        }
    }
}
