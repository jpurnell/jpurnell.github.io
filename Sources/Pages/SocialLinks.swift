	//
	//  SocialLinks.swift
	//  IgniteStarter
	//
	//  Created by Justin Purnell on 10/1/24.
	//


import Foundation
import Ignite

public struct SocialLinks: Component {
	var links: [SocialLink] = socialLinkList
	
	public func body(context: PublishingContext) -> [any PageElement] {
		for link in links {
			Text {
				Link(
					Image(link.fullLink, description: link.site)
						.resizable()					
						.opacity(0.74)
						.foregroundStyle(.secondary)
					, target: link.link)
				.role(.secondary)
				.target(.newWindow)
				.relationship(.me)
			}.class("column").frame(width: 40, height: 40)
		}
	}
	
	public init() {}
	
}
