import Foundation
import Ignite

/// Root site configuration for justinpurnell.com.
///
/// Defines all metadata, pages, layouts, and feed settings consumed by the Ignite build pipeline.
public struct PersonalSite: Site {
    /// Site display name used in titles and metadata.
    public var name = "Justin Purnell"
    /// Suffix appended to every page `<title>`.
    public var titleSuffix = " | Justin Purnell"
    // swiftlint:disable:next force_unwrapping
    /// The site's base URL. Force unwrap is safe — this is a compile-time constant required by the `Site` protocol.
    public var url = URL(string: "https://www.justinpurnell.com")!
    /// SEO meta description used in OG and Twitter tags.
    public var description: String? = "Justin Purnell — Founder of Ledge Partners. Former Goldman Sachs credit analyst, Head of Product at Hotels at Home, VP at NBCUniversal. Princeton '00, Tuck MBA."
    /// Content language for the `<html lang>` attribute.
    public var language: Language = .english
    /// Bootstrap asset loading strategy.
    public var builtInIconsEnabled: BootstrapOptions = .localBootstrap
    /// Author name used in `<meta name="author">`.
    public var author = "Justin Purnell"
    /// RSS feed configuration including image and content count.
    public var feedConfiguration: FeedConfiguration? = FeedConfiguration(
        mode: .full,
        contentCount: 20,
        path: "/feed.rss",
        image: FeedConfiguration.FeedImage(
            url: "https://www.justinpurnell.com/images/logos/rss.png",
            width: 144,
            height: 152
        )
    )

    /// The site's home page.
    public var homePage = Home()
    /// The shared layout wrapping all pages.
    public var layout = MainLayout()
    /// Placeholder tag page (no tag index).
    public var tagPage = EmptyTagPage()

    /// All static pages registered with the site.
    public var staticPages: [any StaticPage] {
        About()
        BusinessMath()
        CV()
        Portfolio()
        Projects()
        NeXT()
    }

    /// Article page layouts matched by the `layout` front-matter key.
    public var articlePages: [any ArticlePage] {
        AboutLayout()
        ProjectLayout()
        BlogPostLayout()
    }

    public init() {}
}
