import Foundation

/// Email contact link.
public let email = OffsiteLink(title: "email", url: "mailto:morals.tech.0x@icloud.com")

/// Calendar booking link.
public let calendar = OffsiteLink(title: "calendar", url: "https://cal.com/jpurnell/15min")

/// GitHub profile link.
public let github = OffsiteLink(title: "github", url: "https://github.com/jpurnell")

/// Bluesky profile link.
public let bsky = OffsiteLink(title: "bsky", url: "https://bsky.app/profile/justinpurnell.com")

/// Mastodon profile link.
public let mastodon = OffsiteLink(title: "mastodon", url: "https://mastodon.social/@jpurnell")

/// Apple Music radio station link.
public let radio = OffsiteLink(title: "radio", url: "https://music.apple.com/us/station/justin-purnells-station/ra.u-a475786ae9cc432a1abb70ff757aa95f")

/// RSS feed link.
public let rss = OffsiteLink(title: "rss", url: "https://www.justinpurnell.com/feed.rss")

/// Blog link.
public let tumblr = OffsiteLink(title: "blog", url: "http://blog.justinpurnell.com")

/// Theme toggle placeholder link.
public let theme = OffsiteLink(title: "theme", url: "#")

/// All footer navigation links in display order.
public let footerLinks: [OffsiteLink] = [email, calendar, tumblr, github, bsky, mastodon, radio, rss, theme]
