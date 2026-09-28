import Foundation

/// The section a portfolio entry belongs to. Declaration order is display order.
public enum PortfolioCategory: String, Codable, Sendable, CaseIterable {
    /// Published open-source packages.
    case openSource = "open-source" // LIVE: decoded from portfolio.json
    /// Products and services shipped to customers.
    case product
    /// Media, publishing, and community sites.
    case media // LIVE: decoded from portfolio.json

    /// Section heading and filter label shown on the Portfolio page.
    public var displayName: String {
        switch self {
        case .product: "Products"
        case .openSource: "Open Source"
        case .media: "Media & Publishing"
        }
    }
}

/// A link a reader can follow to check a portfolio entry's outcome claim.
public struct PortfolioEvidence: Codable, Sendable {
    /// Short link text, e.g. "Conformance" or "Changelog".
    public let label: String
    /// Destination URL.
    public let url: String

    /// Creates a new evidence link.
    /// - Parameters:
    ///   - label: Short link text.
    ///   - url: Destination URL.
    public init(label: String, url: String) {
        self.label = label
        self.url = url
    }
}

/// A portfolio project or website to showcase, decoded from `Resources/portfolio.json`.
public struct PortfolioSite: Codable, Sendable {
    /// Display name of the site.
    public let name: String
    /// URL to the live site or archive.
    public let url: String
    /// Path to the thumbnail/logo image; empty when there is no logo.
    public let thumbnail: String
    /// Brief description of the project.
    public let summary: String?
    /// Section the entry belongs to; `nil` in the data means ``PortfolioCategory/product``.
    public let category: PortfolioCategory?
    /// The role held, e.g. "Author" or "Head of Product, Hotels at Home".
    public let role: String?
    /// Years active, e.g. "2020–2023".
    public let period: String?
    /// One measurable result a reader could check.
    public let outcome: String?
    /// Links that let a reader check the outcome.
    public let evidence: [PortfolioEvidence]?

    /// The category to display, defaulting to product when the data omits one.
    public var resolvedCategory: PortfolioCategory { category ?? .product }

    /// Creates a new portfolio site entry.
    /// - Parameters:
    ///   - name: Display name of the site.
    ///   - url: URL to the live site or archive.
    ///   - thumbnail: Path to the thumbnail/logo image, or empty.
    ///   - summary: Brief description of the project.
    ///   - category: Section the entry belongs to.
    ///   - role: The role held.
    ///   - period: Years active.
    ///   - outcome: One measurable result.
    ///   - evidence: Links that let a reader check the outcome.
    public init(
        name: String,
        url: String,
        thumbnail: String,
        summary: String?,
        category: PortfolioCategory? = nil,
        role: String? = nil,
        period: String? = nil,
        outcome: String? = nil,
        evidence: [PortfolioEvidence]? = nil
    ) {
        self.name = name
        self.url = url
        self.thumbnail = thumbnail
        self.summary = summary
        self.category = category
        self.role = role
        self.period = period
        self.outcome = outcome
        self.evidence = evidence
    }
}

/// One section of the Portfolio page: a category and its entries in file order.
public struct PortfolioGroup: Sendable {
    /// The section's category.
    public let category: PortfolioCategory
    /// Entries in this section, in the order they appear in the data file.
    public let sites: [PortfolioSite]
}

/// Loads and arranges the portfolio data.
public enum PortfolioData {
    /// Decodes a portfolio JSON array from disk. The site itself decodes through
    /// Ignite's `decode` environment value; this entry point serves tests and tools.
    /// - Parameter url: Location of `portfolio.json`.
    /// - Returns: The entries in file order.
    /// - Throws: Any file-reading or decoding error.
    public static func load(from url: URL) throws -> [PortfolioSite] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([PortfolioSite].self, from: data)
    }

    /// Groups entries by category in declaration order, dropping empty categories
    /// and preserving file order within each group.
    /// - Parameter sites: The decoded entries.
    /// - Returns: Non-empty groups, one per represented category.
    public static func grouped(_ sites: [PortfolioSite]) -> [PortfolioGroup] {
        PortfolioCategory.allCases.compactMap { category in
            let members = sites.filter { $0.resolvedCategory == category }
            return members.isEmpty ? nil : PortfolioGroup(category: category, sites: members)
        }
    }
}
