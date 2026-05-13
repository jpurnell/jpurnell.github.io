import Foundation
import Ignite

public struct Showcase: StaticPage {
    public var title = "Developer Showcase"
    @Environment(\.articles) var articles

    public init() {}

    public var body: some HTML {
        Text("Developer Showcase").font(.title1).class("mainTitle")

        Text("AI-generated narratives and infographics exploring the development history of selected projects.")
            .class("blurb")
            .style(.marginBottom, "2em")

        let showcaseArticles = articles.all
            .filter { $0.tags?.contains("showcase") ?? false }
            .sorted { $0.date > $1.date }

        let portfolio = showcaseArticles.first { $0.tags?.contains("portfolio") ?? false }
        let projects = showcaseArticles.filter { !($0.tags?.contains("portfolio") ?? false) }

        if let portfolio {
            Card {
                Text {
                    Link(
                        portfolio.metadata["title"] as? String ?? portfolio.title,
                        target: portfolio.path
                    )
                }
                .font(.title3)
                .fontWeight(.semibold)

                Text(portfolio.metadata["description"] as? String ?? "")
                    .class("blurb")
                    .margin(.top, .small)
            }
            .cardStyle(.bordered)
            .class("showcase-featured")
            .margin(.bottom, .large)
        }

        let styles = Set(projects.compactMap { $0.metadata["style"] as? String }).sorted()

        Section {
            Link("All", target: "#")
                .class("card-filter-btn", "active")
                .data("group", "style")

            for style in styles {
                Link(styleDisplayName(style), target: "#")
                    .class("card-filter-btn")
                    .data("group", "style")
                    .data("value", style)
            }
        }
        .class("card-filter-controls")

        Section {
            Grid(spacing: 20) {
                for article in projects {
                    Card {
                        Text {
                            Link(
                                articleTitle(for: article),
                                target: article.path
                            )
                        }
                        .font(.title4)
                        .fontWeight(.semibold)
                        .class("grid-card-title")

                        Text(article.metadata["description"] as? String ?? "")
                            .class("grid-card-desc")

                    } footer: {
                        Text {
                            if let style = article.metadata["style"] as? String {
                                Badge(style)
                                    .role(.dark)
                                    .badgeStyle(.subtleBordered)
                                    .class("grid-card-badge")
                            }

                            if let project = article.metadata["project"] as? String {
                                Badge(project)
                                    .role(.secondary)
                                    .badgeStyle(.subtle)
                                    .class("grid-card-badge")
                            }
                        }
                    }
                    .cardStyle(.bordered)
                    .class("grid-card", "filterable-card")
                    .data("style", article.metadata["style"] as? String ?? "")
                }
            }
            .columns(2)
        }
        .class("card-grid", "card-grid-2")

        Script(file: "/js/card-filter.js")
    }

    private func articleTitle(for article: Article) -> String {
        let raw = article.metadata["title"] as? String ?? article.title
        if let project = article.metadata["project"] as? String,
           raw.count > 60 {
            return project
        }
        return raw
    }

    private func styleDisplayName(_ style: String) -> String {
        switch style {
        case "caseStudy": return "Case Study"
        case "deepDive": return "Deep Dive"
        case "projectCard": return "Project Card"
        default: return style
        }
    }
}
