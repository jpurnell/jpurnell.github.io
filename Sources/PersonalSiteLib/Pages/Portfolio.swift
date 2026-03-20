import Foundation
import Ignite

/// The Portfolio page showcasing featured projects and websites.
public struct Portfolio: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "Portfolio"

    public init() {}

    public var body: some HTML {
        Text("Portfolio").font(.title1).class("mainTitle")
        Section {
            for site in portfolioSites {
                Card(imageName: site.thumbnail) {
                    Text {
                        Link(site.name, target: site.url)
                            .target(.newWindow)
                            .relationship(.noOpener, .noReferrer)
                    }
                    .font(.title1)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    Divider()
                    Image(site.thumbnail, description: site.name).resizable().frame(width: 200)
                } header: {

                } footer: {
                    "\(site.summary ?? "")"
                }
                .contentPosition(.top)
                .frame(width: .percent(100%))
                .margin(.bottom)
                .padding(.horizontal, 5)
                .id(site.name)
            }
        }
    }
}
