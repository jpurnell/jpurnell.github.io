import Foundation
import Ignite

/// Article page layout for the About section: the portrait on the label column (columns 1 to 3) and the
/// markdown text on the reading column (columns 4 to 10).
public struct AboutLayout: ArticlePage {
    /// Creates a new about article layout.
    public init() {}

    /// The rendered about page content with profile image and text.
    public var body: some HTML {
        Text("About").font(.title1).class("mainTitle")
        Section {
            Image(article.image ?? "default", description: (article.metadata["imageDescription"] as? String) ?? "About")
                .resizable()
                .accessibilityLabel((article.metadata["imageDescription"] as? String) ?? "About photo")
                .class("about-portrait")
            Section { article.text }
                .class("about-text")
        }
        .class("about-grid")
    }
}
