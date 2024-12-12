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
	thumbnail: "/images/thumbnails/marriott.png",
	summary: nil
)

let nassauWeekly: PortfolioSite = .init(
	name: "Nassau Weekly",
	url: "https://web.archive.org/web/19991014032312/http://www.princeton.edu/%7Enweekly/",
	thumbnail: "/images/thumbnails/marriott.png",
	summary: nil
)

let ucbComedy: PortfolioSite = .init(
	name: "UCBComedy.com",
	url: "https://web.archive.org/web/19991014032312/http://www.princeton.edu/%7Enweekly/",
	thumbnail: "/images/thumbnails/marriott.png",
	summary: nil
)

let reunions: PortfolioSite = PortfolioSite(name: "Princeton 2000 Reunions",
											url: "https://reunions.princeton2000.org/",
											thumbnail: "/images/logos/P2000_25th_Lounging_Tiger.png",
											summary: "The Princeton Class of 2000 celebrates it's 25th Reunion")


struct Portfolio: StaticPage {
    var title = "Portfolio"

    func body(context: PublishingContext) -> [BlockElement] {
		Text("About").font(.title1).class("mainTitle")
		for content in context.allContent.filter({$0.title == "about-Justin"}) {
			Image(content.image ?? "default", description: (content.metadata["imageDescription"] as! String))
				.resizable()
				.frame(width: "130px", height:  "130px")
				.style("float: left", "margin-right: 1%", "margin-bottom: 1%")
			Text(content.body).frame(width: "70%", maxWidth: "800px")
		}
	}
}
