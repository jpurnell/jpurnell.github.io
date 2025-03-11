import Foundation
import Ignite

struct Sharing: StaticPage {
    var title = "Sharing"

    func body(context: PublishingContext) -> [BlockElement] {
		Text("Sharing").font(.title1).class("mainTitle")
		List {
			for content in context.allContent.filter({$0.tags.contains("sharing")}) {
				Text {
					Link(content.metadata["title"] as! String, target: content.path)
				}.font(.title2).fontWeight(.semibold).class("subTitle")
			}
		}.listStyle(.unordered(.square))
	}
}
