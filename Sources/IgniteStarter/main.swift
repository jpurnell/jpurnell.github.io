import Ignite
#if canImport(os)
import os
#endif
import PersonalSiteLib

/// Entry point that builds the static site.

let logger = Logger(subsystem: "com.justinpurnell", category: "SiteBuilder")

do {
    var site = PersonalSite()
    try await site.publish(buildDirectoryPath: "docs")
} catch {
    logger.error("Site build failed: \(error.localizedDescription, privacy: .public)")
}
