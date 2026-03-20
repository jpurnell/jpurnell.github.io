import Foundation

/// A social media platform link with logo asset reference.
public struct SocialLink {
    /// Display name of the platform (e.g. "LinkedIn").
    public let site: String
    /// Filename stem for the SVG logo in `/images/social/`.
    public let logoImage: String
    /// Full URL to the profile page.
    public let link: String

    /// Path to the SVG logo asset, derived from ``logoImage``.
    public var fullLink: String { return "/images/social/\(logoImage).svg" }

    /// Creates a new social link.
    /// - Parameters:
    ///   - site: Display name of the platform.
    ///   - logoImage: Filename stem for the SVG logo.
    ///   - link: Full URL to the profile page.
    public init(site: String, logoImage: String, link: String) {
        self.site = site
        self.logoImage = logoImage
        self.link = link
    }
}
