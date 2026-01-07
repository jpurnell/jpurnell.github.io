//
//  BlogPostLayout.swift
//  IgniteStarter
//
//  Created by Claude Code on 1/5/26.
//


import Foundation
import Ignite

struct BlogPostLayout: ContentPage {
	func body(content: Content, context: PublishingContext) -> [any BlockElement] {
		// Display the post title
		Text(content.metadata["title"] as? String ?? content.title)
			.font(.title1)
			.class("mainTitle")

		// Display timestamp and metadata
		Group {
			if let date = content.metadata["date"] as? String {
				Text(date)
					.class("blogDateTime")
			}

			// Show series information if available
			if let series = content.metadata["series"] as? String {
				Text(series)
					.class("blogDateTime")
					.style("margin-left: 1em")
			}

			// Show estimated reading time
			Text("\(content.estimatedReadingMinutes) min read")
				.class("blogDateTime")
				.style("margin-left: 1em")
		}
		.style("margin-bottom: 2em")

		// Main content body - Ignite automatically converts markdown to HTML
		// This includes inline code, images, audio, video, and all other markdown elements
		Text(content.body)
			.frame(width: "70%", maxWidth: "800px")
			.class("blurb")

		// Display tags at the bottom
		if content.hasTags {
			Divider()
			Group {
				Text("Tagged with: \(content.tags.joined(separator: ", "))")
					.class("blurb")
					.style("font-style: italic")
			}
			.style("margin-top: 2em")
		}
	}
}
