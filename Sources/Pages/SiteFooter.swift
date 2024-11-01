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
public struct SiteFooter: Component {
    public init() { }

    public func body(context: PublishingContext) -> [any PageElement] {
		NavigationBar {
			for link in footerLinks {
				Link(link.title, target: link.url)
			}
		}
		.navigationItemAlignment(.default)
		.navigationBarStyle(.default)
		.class("noPrint")
		.style("border-top: 0.01em solid #d5d5d5;")
//		.position(.fixedBottom)
    }
}
