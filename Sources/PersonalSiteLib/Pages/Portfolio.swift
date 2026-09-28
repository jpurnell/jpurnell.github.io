import Foundation
import Ignite

/// The Portfolio page: shipped work from `portfolio.json`, each entry with the role held,
/// a measurable outcome, and links a reader can follow to check it.
public struct Portfolio: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "Portfolio"
    @Environment(\.decode) var decode

    /// Creates a new Portfolio page.
    public init() {}

    /// The filterable portfolio grid, grouped by category in declaration order.
    public var body: some HTML {
        Text("Portfolio").font(.title1).class("mainTitle")

        Text("Things I have shipped, with the role I held, what it produced, and where to check the claim. Generating work has become cheap. Specifying it and verifying it have not.")
            .class("blurb")
            .style(.marginBottom, "2em")

        let sites = decode("portfolio.json", as: [PortfolioSite].self) ?? []
        let groups = PortfolioData.grouped(sites)

        Section {
            Link("All", target: "#")
                .class("card-filter-btn", "active")
                .data("group", "category")

            for group in groups {
                Link(group.category.displayName, target: "#")
                    .class("card-filter-btn")
                    .data("group", "category")
                    .data("value", group.category.rawValue)
            }
        }
        .class("card-filter-controls")

        Section {
            Grid(spacing: 20) {
                for group in groups {
                    for site in group.sites {
                        card(for: site, in: group.category)
                    }
                }
            }
            .columns(2)
        }
        .class("card-grid", "card-grid-2")

        Script(file: "/js/card-filter.js")
    }

    /// One portfolio card: name, logo if any, role and period, summary, outcome, and evidence links.
    @HTMLBuilder
    private func card(for site: PortfolioSite, in category: PortfolioCategory) -> some HTML {
        Card {
            Text {
                Link(site.name, target: site.url)
                    .target(.newWindow)
                    .relationship(.noOpener, .noReferrer)
            }
            .font(.title4)
            .fontWeight(.semibold)
            .class("grid-card-title")

            if !site.thumbnail.isEmpty {
                Image(site.thumbnail, description: "\(site.name) logo")
                    .resizable()
                    .accessibilityLabel("\(site.name) logo")
                    .frame(width: 160)
                    .class("portfolio-logo")
            }

            Text(rolePeriod(for: site))
                .class("portfolio-role")

            Text(site.summary ?? "")
                .class("grid-card-desc")

            if let outcome = site.outcome {
                Text(outcome)
                    .class("portfolio-outcome")
            }
        } footer: {
            evidenceFooter(for: site, in: category)
        }
        .cardStyle(.bordered)
        .class("grid-card", "filterable-card")
        .data("category", category.rawValue)
        .id(site.name)
    }

    /// The card footer: a category badge followed by the entry's evidence links.
    @HTMLBuilder
    private func evidenceFooter(for site: PortfolioSite, in category: PortfolioCategory) -> some HTML {
        Badge(category.displayName)
            .role(.secondary)
            .badgeStyle(.subtle)
            .class("grid-card-badge")

        for link in site.evidence ?? [] {
            Link(link.label, target: link.url)
                .target(.newWindow)
                .relationship(.noOpener, .noReferrer)
                .class("portfolio-evidence")
        }
    }

    /// "Role · Period", omitting whichever half is missing.
    private func rolePeriod(for site: PortfolioSite) -> String {
        [site.role, site.period]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}
