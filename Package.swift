// swift-tools-version: 6.2
// legibility:description: This is the codebase for my personal website, built using the Ignite static site generator.
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IgniteStarter",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/jpurnell/Ignite.git", revision: "161588651d1e0153a245672ec978ee23a48a4e4b"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
        // Public repository, fetched over HTTPS like the rest of the fleet.
        .package(url: "https://github.com/jpurnell/DesignTokens.git", from: "0.6.0"),
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
            dependencies: [
                "PersonalSiteLib",
                .product(name: "DesignTokens", package: "DesignTokens"),
            ]
        ),
    ]
)
