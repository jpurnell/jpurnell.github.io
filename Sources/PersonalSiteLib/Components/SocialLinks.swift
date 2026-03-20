import Foundation
import Ignite

/// A row of social media icon links rendered as clickable SVG images.
public struct SocialLinks: HTML {
    /// The social platforms to display. Defaults to ``socialLinkList``.
    public var links: [SocialLink] = socialLinkList

    public init() {}

    public var body: some HTML {
        for link in links {
            Text {
                Link(
                    Image(link.fullLink, description: link.site)
                        .resizable()
                        .opacity(0.74)
                        .foregroundStyle(.secondary)
                    , target: link.link)
                .role(.secondary)
                .target(.newWindow)
                .relationship(.me)
            }.class("column").frame(width: 40, height: 40)
        }
    }
}
