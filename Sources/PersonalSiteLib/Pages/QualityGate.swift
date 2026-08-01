import Foundation
import Ignite

/// The Quality Gate landing page — *The Gate and the Mirror*.
///
/// A hero echoing the tool's ✓/✗ commit-gate readout, the intro article, and a
/// tag-filterable, sortable card grid of every post in the series (one chip per
/// checker family / arc). Modeled on ``BusinessMath``.
public struct QualityGate: StaticPage {
    /// Page title used in the `<title>` tag and to derive the `/quality-gate` path.
    public var title = "Quality Gate"
    /// All published articles, injected by the Ignite build pipeline.
    @Environment(\.articles) var articles

    /// Creates a new Quality Gate page.
    public init() {}

    /// The intro article's exact title, used to lift it out of the grid.
    private let introTitle = "The Gate and the Mirror"

    /// The hero, intro article, filter controls, and the filterable card grid.
    public var body: some HTML {
        hero

        ForEach(articles.all.filter { $0.title == introTitle }) { article in
            Divider()
            Section { article.text }.frame(width: .percent(70%), maxWidth: .px(800))
        }

        let blogPosts = articles.all
            .filter { $0.path.contains("QualityGate") && $0.title != introTitle }
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
                            Link(post.metadata["title"] as? String ?? post.title, target: post.path)
                        }
                        .font(.title5)
                        .fontWeight(.semibold)
                        .class("grid-card-title")

                        Text(formatPostDate(post.date)).class("blogDateTime")
                        Text("\(post.estimatedReadingMinutes) min read").class("blogDateTime")
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

    /// The hero: title, tagline, and a monospace commit-gate readout.
    private var hero: some HTML {
        Section {
            Text {
                Link("quality-gate-swift", target: "https://github.com/jpurnell/quality-gate-swift")
            }
            .font(.title1)
            .class("mainTitle")

            Text("The Gate and the Mirror — mechanical enforcement and institutional judgment for software you can trust.")
                .font(.lead)
                .style(.color, "#666")

            Section {
                Text("$ git commit -m \"session loop\"").style(.margin, "0")
                Text("✗ concurrency  cancellation-checkpoint-after-loop").style(.color, "#c0392b").style(.margin, "0")
                Text("  commit blocked · 1 error").style(.color, "#c0392b").style(.margin, "0")
                Text("$ git commit -m \"session loop\"").style(.margin, "0")
                Text("✓ 33 checkers · 0 errors · 0 warnings — committed").style(.color, "#2e7d32").style(.margin, "0")
            }
            .style(.fontFamily, "ui-monospace, SFMono-Regular, Menlo, monospace")
            .style(.fontSize, "0.85rem")
            .style(.background, "#0e1116")
            .style(.color, "#e8edf4")
            .style(.padding, "1rem 1.25rem")
            .style(.borderRadius, "10px")
            .style(.marginTop, "1rem")
            .style(.maxWidth, "640px")
            .style(.overflowX, "auto")
        }
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
