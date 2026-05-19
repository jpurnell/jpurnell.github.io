import Foundation
import Ignite

/// Article page layout for the About section, rendering a profile image alongside markdown content.
public struct AboutLayout: ArticlePage {
    /// Creates a new about article layout.
    public init() {}

    /// The rendered about page content with profile image and text.
    public var body: some HTML {
        Text("About").font(.title1).class("mainTitle")
        Image(article.image ?? "default", description: (article.metadata["imageDescription"] as? String) ?? "About")
            .resizable()
            .accessibilityLabel((article.metadata["imageDescription"] as? String) ?? "About photo")
            .frame(width: 130, height: 130)
            .style(.float, "left")
            .style(.marginRight, "1%")
            .style(.marginBottom, "1%")
        Section { article.text }.frame(width: .percent(70%), maxWidth: .px(800))
    }
}
