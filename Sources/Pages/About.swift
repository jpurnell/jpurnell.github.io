import Foundation
import Ignite

struct About: StaticPage {
    var title = "Justin Purnell"

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
