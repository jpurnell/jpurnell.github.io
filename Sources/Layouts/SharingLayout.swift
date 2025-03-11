//
//  AboutLayout.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/1/24.
//


import Foundation
import Ignite

struct SharingLayout: ContentPage {
	func body(content: Content, context: PublishingContext) -> [any BlockElement] {
		for content in context.content(ofType: "sharing") {
			Text(content.metadata["title"] as! String).font(.title1).fontWeight(.semibold).class("mainTitle")
			Text(content.body).frame(width: "70%", maxWidth: "800px")
			if content.hasTags {
				Group {
					Text("Tagged with: \(content.tags.joined(separator: ", "))")
				}
			}
		}
	}
}
