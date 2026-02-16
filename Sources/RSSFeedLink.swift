import Foundation
import Ignite

// Post-build script to add RSS autodiscovery link
// This is a workaround for Ignite's limitations with MetaLink custom attributes
extension PublishingContext {
    func addRSSLinkToHTML() {
        // This will be called after build to inject the RSS link
    }
}
