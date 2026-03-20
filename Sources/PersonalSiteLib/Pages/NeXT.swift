import Foundation
import Ignite

/// The NeXT page embedding external content via an HTML include.
public struct NeXT: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "NeXT"

    public init() {}

    public var body: some HTML {
        Include("NeXTEmbed.html")
    }
}
