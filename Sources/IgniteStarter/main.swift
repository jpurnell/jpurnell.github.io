import Foundation
import Ignite
import PersonalSiteLib

/// Entry point that builds the site and runs post-build scripts.

var site = PersonalSite()

do {
    try await site.publish(buildDirectoryPath: "docs")

    // Run post-build script to add RSS autodiscovery links
    let fileManager = FileManager.default
    let currentPath = fileManager.currentDirectoryPath
    let scriptPath = "\(currentPath)/add-rss-link.sh"

    if fileManager.fileExists(atPath: scriptPath) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptPath]
        process.currentDirectoryURL = URL(fileURLWithPath: currentPath)
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("RSS autodiscovery links added")
        }
    } else {
        print("Post-build script not found at: \(scriptPath)")
        print("   Run the script manually or ensure you're in the project root directory")
    }
} catch {
    print(error.localizedDescription)
}
