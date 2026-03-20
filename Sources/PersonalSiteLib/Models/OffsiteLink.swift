import Foundation

/// An external link used in the site footer navigation.
public struct OffsiteLink: Codable {
    /// Display text for the link.
    public let title: String
    /// Destination URL (may be `mailto:`, `http://`, or `#`).
    public let url: String

    /// Creates a new offsite link.
    /// - Parameters:
    ///   - title: Display text for the link.
    ///   - url: Destination URL.
    public init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}
