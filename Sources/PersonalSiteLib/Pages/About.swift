import Foundation
import Ignite

/// The About page, rendering the `about-Justin` article with a profile photo: the portrait on the label
/// column (columns 1 to 3) and the text on the reading column (columns 4 to 10).
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
            Section {
                Image(article.image ?? "default", description: (article.metadata["imageDescription"] as? String) ?? "Justin Purnell")
                    .resizable()
                    .accessibilityLabel((article.metadata["imageDescription"] as? String) ?? "Justin Purnell photo")
                    .class("about-portrait")
                Section { article.text }
                    .class("about-text")
            }
            .class("about-grid")
        }
    }
}
