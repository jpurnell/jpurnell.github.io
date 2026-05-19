import Foundation
import Ignite

/// The About page, rendering the `about-Justin` article with a profile photo.
public struct About: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "About"
    @Environment(\.articles) var articles

    /// Creates a new About page.
    public init() {}

    /// The about page content with profile photo and biography.
    public var body: some HTML {
        Text("About").font(.title1).class("mainTitle")
        ForEach(articles.all.filter({ $0.path.contains("about-Justin") })) { article in
            Image(article.image ?? "default", description: (article.metadata["imageDescription"] as? String) ?? "Justin Purnell")
                .resizable()
                .accessibilityLabel((article.metadata["imageDescription"] as? String) ?? "Justin Purnell photo")
                .frame(width: 150, height: 150)
                .style(.float, "left")
                .style(.marginRight, "1%")
                .style(.marginBottom, "1%")
            Section { article.text }.frame(width: .percent(70%), maxWidth: .px(800))
        }
    }
}
