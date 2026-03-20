import Foundation
import Ignite

/// Article page layout for blog posts, displaying title, date, series, reading time, content, and tags.
public struct BlogPostLayout: ArticlePage {
    public init() {}

    public var body: some HTML {
        Text(article.metadata["title"] as? String ?? article.title)
            .font(.title1)
            .class("mainTitle")

        Group {
            if let date = article.metadata["date"] as? String {
                Text(date)
                    .class("blogDateTime")
            }

            if let series = article.metadata["series"] as? String {
                Text(series)
                    .class("blogDateTime")
                    .style(.marginLeft, "1em")
            }

            Text("\(article.estimatedReadingMinutes) min read")
                .class("blogDateTime")
                .style(.marginLeft, "1em")
        }
        .style(.marginBottom, "2em")

        Text(markdown: article.text)
            .frame(width: .percent(70%), maxWidth: .px(800))
            .class("blurb")

        if !(article.tags?.isEmpty ?? true) {
            Divider()
            Group {
                Text("Tagged with: \((article.tags ?? []).joined(separator: ", "))")
                    .class("blurb")
                    .style(.fontStyle, "italic")
            }
            .style(.marginTop, "2em")
        }
    }
}
