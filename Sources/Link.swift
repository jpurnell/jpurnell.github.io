//
//  File.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/1/24.
//

import Foundation

struct offsiteLink: Codable {
	let title: String
	let url: String
}

let email: offsiteLink = offsiteLink(title: "email", url: "mailto:morals.tech.0x@icloud.com")
let calendar: offsiteLink = offsiteLink(title: "calendar", url: "https://cal.com/jpurnell/15min")
let github: offsiteLink = offsiteLink(title: "github", url: "https://github.com/jpurnell")
let bsky: offsiteLink = offsiteLink(title: "bsky", url: "https://bsky.app/profile/justinpurnell.com")
let mastodon: offsiteLink = offsiteLink(title: "mastodon", url: "https://mastodon.social/@jpurnell")
let radio: offsiteLink = offsiteLink(title: "radio", url: "https://music.apple.com/us/station/justin-purnells-station/ra.u-a475786ae9cc432a1abb70ff757aa95f")
let rss: offsiteLink = offsiteLink(title: "rss", url: "https://www.justinpurnell.com/feed.rss")
let tumblr: offsiteLink = offsiteLink(title: "blog", url: "http://blog.justinpurnell.com")
let theme: offsiteLink = offsiteLink(title: "theme", url: "#")

let footerLinks: [offsiteLink] = [email, calendar, tumblr, github, bsky, mastodon, radio, rss, theme]
