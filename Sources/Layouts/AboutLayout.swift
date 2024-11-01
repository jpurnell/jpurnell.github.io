//
//  AboutLayout.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/1/24.
//


import Foundation
import Ignite

struct AboutLayout: ContentPage {
	func body(content: Content, context: PublishingContext) -> [any BlockElement] {
		Text("About").font(.title1).class("mainTitle")
		for content in context.content(ofType: "about-Justin") {
			Image(content.image ?? "default", description: (content.metadata["imageDescription"] as! String))
				.resizable()
				.frame(width: "130px", height:  "130px")
				.style("float: left", "margin-right: 1%", "margin-bottom: 1%")
			Text(content.body).frame(width: "70%", maxWidth: "800px")
		}

//		if content.hasTags {
//			Group {
//				Text("Tagged with: \(content.tags.joined(separator: ", "))")
//
//				Text("\(content.estimatedWordCount) words; \(content.estimatedReadingMinutes) minutes to read.")
//			}
//		}
	}
}
