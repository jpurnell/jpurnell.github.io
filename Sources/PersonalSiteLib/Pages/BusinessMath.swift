import Foundation
import Ignite

public struct BusinessMath: StaticPage {
    public var title = "BusinessMath"
    @Environment(\.articles) var articles

    public init() {}

    public var body: some HTML {
        ForEach(articles.all.filter({ $0.title == "Welcome to BusinessMath: A 12-Week Journey" })) { article in
            Text {
                Link("BusinessMath", target: "https://www.github.com/jpurnell/BusinessMath")
            }.font(.title1).class("mainTitle")
            Divider()
            Text(markdown: article.text).frame(width: .percent(70%), maxWidth: .px(800))
        }

        let blogPosts = articles.all
            .filter { $0.path.contains("BusinessMath")
                      && $0.title != "Welcome to BusinessMath: A 12-Week Journey" }
            .sorted { $0.date > $1.date }

        let allTags = Set(blogPosts.flatMap { $0.tags ?? [] }).sorted()

        Section {
            Link("All", target: "#")
                .class("card-filter-btn", "active")
                .data("group", "tags")

            for tag in allTags {
                Link(tagDisplayLabel(tag), target: "#")
                    .class("card-filter-btn")
                    .data("group", "tags")
                    .data("value", tag)
            }
        }
        .class("card-filter-controls")

        Section {
            Button("\u{2193} Newest First")
                .id("card-sort-toggle")
                .class("btn", "btn-sm", "btn-outline-secondary")
        }
        .style(.marginBottom, "1em")

        Section {
            Grid(spacing: 20) {
                for post in blogPosts {
                    Card {
                        Text {
                            Link(
                                post.metadata["title"] as? String ?? post.title,
                                target: post.path
                            )
                        }
                        .font(.title5)
                        .fontWeight(.semibold)
                        .class("grid-card-title")

                        Text(formatPostDate(post.date))
                            .class("blogDateTime")

                        Text("\(post.estimatedReadingMinutes) min read")
                            .class("blogDateTime")
                    } footer: {
                        for tag in (post.tags ?? []) {
                            Badge(tag)
                                .role(.secondary)
                                .badgeStyle(.subtle)
                                .class("grid-card-badge")
                        }
                    }
                    .cardStyle(.bordered)
                    .class("grid-card", "filterable-card")
                    .data("tags", (post.tags ?? []).joined(separator: ","))
                    .data("date", formatDateForAttribute(post.date))
                }
            }
            .columns(3)
        }
        .class("card-grid", "card-grid-3")

        Script(file: "/js/card-filter.js")
    }

    private func formatPostDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formatDateForAttribute(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }

    private func tagDisplayLabel(_ tag: String) -> String {
        tag.split(whereSeparator: { $0 == "-" || $0 == " " })
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}
