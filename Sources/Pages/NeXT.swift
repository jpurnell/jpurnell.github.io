import Foundation
import Ignite

struct next: StaticPage {
    var title = "NeXT"

    func body(context: PublishingContext) -> [BlockElement] {
		Include("NeXTEmbed.html")
	}
}
