import Foundation
import Ignite

struct About: StaticPage {
    var title = "Justin Purnell"

    func body(context: PublishingContext) -> [BlockElement] {
		Text("About").font(.title1).class("mainTitle")
		for content in context.allContent.filter({$0.title == "about-Justin"}) {
			Image(content.image ?? "default", description: (content.metadata["imageDescription"] as! String))
				.resizable()
				.frame(width: "150px", height:  "150px")
				.style("float: left", "margin-right: 1%", "margin-bottom: 1%")
			Text(content.body).frame(width: "70%", maxWidth: "800px")
			Embed(youTubeID: "FzUEUGZC-GY", title: "The Hybrid Professional").aspectRatio(.r16x9)
			Divider()
			Embed(youTubeID: "5cIvq3CDAOA", title: "A Blueprint for Impact").aspectRatio(.r16x9)
		}
	}
}
