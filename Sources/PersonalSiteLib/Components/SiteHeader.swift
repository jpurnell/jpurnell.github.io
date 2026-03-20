import Foundation
import Ignite

/// Top navigation bar linking to the site's main pages.
public struct SiteHeader: HTML {
    public init() {}

    public var body: some HTML {
        NavigationBar(logo: nil, items: {
            Link("Home", target: "/")
            Link("About", target: About())
            Link("CV", target: CV())
            Link("BusinessMath", target: BusinessMath())
            Link("NeXT", target: NeXT())
        })
        .navigationItemAlignment(.trailing)
        .navigationBarStyle(.automatic)
        .style(.borderBottom, "0.01em solid #d5d5d5")
        .class("noPrint")
    }
}
