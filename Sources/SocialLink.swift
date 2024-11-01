//
//  SocialLink.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/1/24.
//

import Foundation

public struct SocialLink {
	let site: String
	let logoImage: String
	let link: String
	var fullLink: String { return "/images/social/\(logoImage).svg"}
}

public let socialLinkList: [SocialLink] = [
	SocialLink(site: "Instagram", logoImage: "instagram", link: "https://www.instagram.com/jpurnell/"),
	SocialLink(site: "Mastodon", logoImage: "mastodon", link: "https://mastodon.social/@jpurnell"),
	SocialLink(site: "Bluesky", logoImage: "bluesky", link: "https://bsky.app/profile/justinpurnell.com"),
	SocialLink(site: "Threads", logoImage: "threads", link: "https://www.threads.net/@jpurnell"),
	SocialLink(site: "Facebook", logoImage: "facebook", link: "https://www.facebook.com/jpurnell"),
	SocialLink(site: "Twitter", logoImage: "twitter", link: "https://twitter.com/jpurnell")
]
