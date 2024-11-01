import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Justin Purnell"

    func body(context: PublishingContext) -> [BlockElement] {
        Text("Justin Purnell")
            .font(.title1)
			.class("siteTitle")
			.padding(.horizontal, 10)
    }
}
