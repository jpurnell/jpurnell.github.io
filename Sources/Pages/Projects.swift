import Foundation
import Ignite

struct Projects: StaticPage {
    var title = "Projects"

    func body(context: PublishingContext) -> [BlockElement] {
		Text("Projects").font(.title1).class("mainTitle")
		List {
			for content in context.allContent.filter({$0.tags.contains("project")}) {
				Text {
					Link(content.metadata["title"] as! String, target: content.path)
				}.font(.title2).fontWeight(.semibold).class("subTitle")
			}
		}.listStyle(.unordered(.square))
	}
}
