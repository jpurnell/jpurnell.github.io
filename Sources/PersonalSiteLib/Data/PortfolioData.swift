import Foundation

/// A portfolio project or website to showcase.
public struct PortfolioSite: Codable {
    /// Display name of the site.
    public let name: String
    /// URL to the live site or archive.
    public let url: String
    /// Path to the thumbnail/logo image.
    public let thumbnail: String
    /// Brief description of the project.
    public let summary: String?

    /// Creates a new portfolio site entry.
    /// - Parameters:
    ///   - name: Display name of the site.
    ///   - url: URL to the live site or archive.
    ///   - thumbnail: Path to the thumbnail/logo image.
    ///   - summary: Brief description of the project.
    public init(name: String, url: String, thumbnail: String, summary: String?) {
        self.name = name
        self.url = url
        self.thumbnail = thumbnail
        self.summary = summary
    }
}

/// Shop Marriott e-commerce storefront.
public let shopMarriott = PortfolioSite(
    name: "Shop Marriott",
    url: "https://europe.shopmarriott.com/en?referrer=internal",
    thumbnail: "/images/logos/shop-marriott-logo.svg",
    summary: "ShopMarriott.com is a global online retailer of luxury home goods, curated by Marriott for its guests."
)

/// Nassau Weekly — Princeton's student newsmagazine.
public let nassauWeekly = PortfolioSite(
    name: "Nassau Weekly",
    url: "https://web.archive.org/web/19991014032312/http://www.princeton.edu/%7Enweekly/",
    thumbnail: "/images/logos/nassauWeekly.svg",
    summary: "Princeton's One and Only Weekly Newsmagazine, published since 1979"
)

/// UCBComedy.com — Upright Citizens Brigade digital platform.
public let ucbComedy = PortfolioSite(
    name: "UCBComedy.com",
    url: "https://ucbcomedy.com",
    thumbnail: "/images/logos/UCB_COM_BUG_fin_.svg",
    summary: "UCB's Third Stage, created in 2008."
)

/// Shop With Golf — NBC Golf Channel e-commerce site.
public let shopWithGolf = PortfolioSite(
    name: "Shop With Golf",
    url: "https://web.archive.org/web/20190402200305/https://www.shopwithgolf.com/",
    thumbnail: "/images/logos/ShopWithGolf_Stacked_blk.svg",
    summary: "Shop With Golf was a revolutionary content + commerce experience for golfers, marrying innovative young brands with NBC's unmatched golf content."
)

/// Princeton Class of 2000 25th Reunion site.
public let reunions = PortfolioSite(
    name: "Princeton 2000 Reunions",
    url: "https://reunions.princeton2000.org/",
    thumbnail: "/images/logos/P2000_25th_Lounging_Tiger.png",
    summary: "The Princeton Class of 2000 celebrates its 25th Reunion"
)

/// All portfolio sites in display order.
public let portfolioSites: [PortfolioSite] = [shopMarriott, shopWithGolf, ucbComedy, reunions, nassauWeekly]
