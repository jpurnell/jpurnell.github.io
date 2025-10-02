//
//  SiteFooter.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/1/24.
//

import Foundation
import Ignite

/// Displays "Created by Ignite", with a link back to the Ignite project on GitHub.
/// Including this is definitely not required for your site, but it's most appreciated 🙌
public struct SiteHeader: Component {
	public init() { }

	public func body(context: PublishingContext) -> [any PageElement] {
		NavigationBar {
			Link("Home", target: "/")
			Link("About", target: About())
			Link("CV", target: cv())
			Link("NeXT", target: next())
			Link(tumblr.title, target: tumblr.url)
		}
		.navigationItemAlignment(.default)
		.navigationBarStyle(.default)
		.style("border-bottom: 0.01em solid #d5d5d5;")
		.class("noPrint")
	}
}
