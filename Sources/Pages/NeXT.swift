import Foundation
import Ignite

struct next: StaticPage {
    var title = "NeXT | Justin Purnell"

    func body(context: PublishingContext) -> [BlockElement] {
		Include("NeXTEmbed.html")
	}
}
