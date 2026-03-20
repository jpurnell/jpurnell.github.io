// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IgniteStarter",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/jpurnell/Ignite.git", branch: "feature/structured-data")
    ],
    targets: [
        .target(
            name: "PersonalSiteLib",
            dependencies: ["Ignite"]
        ),
        .executableTarget(
            name: "IgniteStarter",
            dependencies: ["PersonalSiteLib"]
        ),
        .testTarget(
            name: "PersonalSiteTests",
            dependencies: ["PersonalSiteLib"]
        ),
    ]
)
