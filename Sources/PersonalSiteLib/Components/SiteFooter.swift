import Foundation
import Ignite

/// Bottom navigation bar with external links (email, social, RSS, theme toggle).
public struct SiteFooter: HTML {
    public init() {}

    public var body: some HTML {
        NavigationBar(logo: nil, items: {
            for link in footerLinks {
                Link(link.title, target: link.url)
            }
        })
        .navigationItemAlignment(.leading)
        .navigationBarStyle(.automatic)
        .class("noPrint")
        .id("site-footer")
        .style(.borderTop, "0.01em solid #d5d5d5")
    }
}
