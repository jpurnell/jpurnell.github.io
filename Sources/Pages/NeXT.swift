import Foundation
import Ignite

struct NeXT: StaticPage {
    var title = "NeXT"

    func body(context: PublishingContext) -> [BlockElement] {
		Include("NeXTEmbed.html")
	}
}
