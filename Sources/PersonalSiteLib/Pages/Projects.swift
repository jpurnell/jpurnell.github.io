import Foundation
import Ignite

public struct Projects: StaticPage {
    public var title = "Projects"
    @Environment(\.articles) var articles

    public init() {}

    public var body: some HTML {
        Text("Projects").font(.title1).class("mainTitle")

        let projectArticles = articles.all
            .filter { $0.tags?.contains("project") ?? false }
            .sorted { $0.date > $1.date }

        let allTags = Set(projectArticles
            .flatMap { ($0.tags ?? []).filter { $0 != "project" } })
            .sorted()

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
            Grid(spacing: 20) {
                for article in projectArticles {
                    let displayTags = (article.tags ?? []).filter { $0 != "project" }

                    Card {
                        Text {
                            Link(
                                article.metadata["title"] as? String ?? article.title,
                                target: article.path
                            )
                        }
                        .font(.title4)
                        .fontWeight(.semibold)
                        .class("grid-card-title")

                        Text(formatPostDate(article.date))
                            .class("blogDateTime")
                    } footer: {
                        for tag in displayTags {
                            Badge(tag)
                                .role(.secondary)
                                .badgeStyle(.subtle)
                                .class("grid-card-badge")
                        }
                    }
                    .cardStyle(.bordered)
                    .class("grid-card", "filterable-card")
                    .data("tags", displayTags.joined(separator: ","))
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

    private func tagDisplayLabel(_ tag: String) -> String {
        let special: [String: String] = ["ai": "AI", "cli": "CLI"]
        if let label = special[tag] { return label }
        return tag.split(whereSeparator: { $0 == "-" || $0 == " " })
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}
