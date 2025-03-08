import Foundation
import Ignite

struct PortfolioSite: Codable {
	let name: String
	let url: String
	let thumbnail: String
	let summary: String?
}

let shopMarriott: PortfolioSite = .init(
	name: "Shop Marriott",
	url: "https://europe.shopmarriott.com/en?referrer=internal",
	thumbnail: "/images/logos/shop-marriott-logo.svg",
	summary: "ShopMarriott.com is a global online retailer of luxury home goods, curated by Marriott for its guests."
)

let nassauWeekly: PortfolioSite = .init(
	name: "Nassau Weekly",
	url: "https://web.archive.org/web/19991014032312/http://www.princeton.edu/%7Enweekly/",
	thumbnail: "/images/logos/nassauWeekly.svg",
	summary: "Princeton's One and Only Weekly Newsmagazine, published since 1979"
)

let ucbComedy: PortfolioSite = .init(
	name: "UCBComedy.com",
	url: "https://ucbcomedy.com",
	thumbnail: "/images/logos/UCB_COM_BUG_fin_.svg",
	summary: "UCB's Third Stage, created in 2008."
)

let shopWithGolf: PortfolioSite = .init(
	name: "Shop With Golf",
	url: "https://web.archive.org/web/20190402200305/https://www.shopwithgolf.com/",
	thumbnail: "/images/logos/ShopWithGolf_Stacked_blk.svg",
	summary: "Shop With Golf was a revolutionary content + commerce experience for golfers, marrying innovative young brands with NBC's unmatched golf content."
)

let reunions: PortfolioSite = PortfolioSite(name: "Princeton 2000 Reunions",
											url: "https://reunions.princeton2000.org/",
											thumbnail: "/images/logos/P2000_25th_Lounging_Tiger.png",
											summary: "The Princeton Class of 2000 celebrates its 25th Reunion")

let portfolioSites: [PortfolioSite] = [shopMarriott, shopWithGolf, ucbComedy, reunions, nassauWeekly]

struct Portfolio: StaticPage {
    var title = "Portfolio"

    func body(context: PublishingContext) -> [BlockElement] {
		Text("Portfolio").font(.title1).class("mainTitle")
		Section {
			for site in portfolioSites {
					Card(imageName: site.thumbnail) {
						Text {
							Link(site.name, target: site.url)
								.target(.newWindow)
								.relationship(.noOpener, .noReferrer)
						}
						.font(.title1)
							.fontWeight(.semibold)
							.foregroundStyle(.black)
						Divider()
						Image(site.thumbnail, description: site.name).resizable().frame(width: 200)
					} header: {
						
					} footer: {
						"\(site.summary ?? "")"
					}
					.contentPosition(.top)
					.frame(width: "100%")
					.margin(.bottom)
					.padding(.horizontal, 5)
					.id(site.name)
			}
		}
	}
}
