//
//  Blog.swift
//  IgniteStarter
//
//  Created by Claude Code on 1/5/26.
//

import Foundation
import Ignite

struct BusinessMath: StaticPage {
	var title = "Blog"

	func body(context: PublishingContext) -> [BlockElement] {
		// Page title
		Group {
			Text("BusinessMath")
				.font(.title1)
				.class("mainTitle")
			Text("BusinessMath is a comprehensive open-source Swift package for financial modeling, statistical analysis, simulation, and optimization. It is designed to be user-friendly and extensible, making it suitable for a wide range of financial professionals and researchers. Read more about how to use it and how we built it here.")
		}

		// Filter controls section
		Section {
			Group {
				generateTagDropdown(context: context)
				generateSortButton()
				generateResetButton()
			}
			.class("filter-controls")
			.style("margin-bottom: 2rem", "display: flex", "gap: 1rem", "align-items: center", "flex-wrap: wrap")
		}

		// Main content area with sidebar layout
		Section {
			Group {
				// Left sidebar - Month navigation
				Group {
					generateMonthSidebar(context: context)
				}
				.width(2)
				.class("col-md-2")
				.id("month-sidebar")

				// Main content - Blog posts list
				Group {
					generateBlogPostsList(context: context)
				}
				.class("col-md-10")
				.id("blog-posts-list")
			}
			.class("row")
		}

		// Include the blog filtering JavaScript
		Script(file: "/js/blog-filter.js")
	}

	// MARK: - Helper Functions

	/// Get all blog posts from the publishing context
	private func getBlogPosts(context: PublishingContext) -> [Content] {
		return context.allContent.filter { content in
			content.layout == "BlogPostLayout" || content.path.contains("/blog/")
		}
	}

	/// Extract all unique tags from blog posts
	private func extractAllTags(from posts: [Content]) -> [String] {
		var allTags = Set<String>()
		for post in posts {
			post.tags.forEach { allTags.insert($0) }
		}
		return Array(allTags)
	}

	/// Group posts by year-month and count them
	private func groupPostsByMonth(posts: [Content]) -> [String: Int] {
		var groups: [String: Int] = [:]
		for post in posts {
			let yearMonth = extractYearMonthFromDate(post.date)
			if !yearMonth.isEmpty {
				groups[yearMonth, default: 0] += 1
			}
		}
		return groups
	}

	/// Extract YYYY-MM from Date object
	private func extractYearMonthFromDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM"
		return formatter.string(from: date)
	}

	/// Extract YYYY-MM from date string
	private func extractYearMonth(from dateString: String) -> String {
		// Handle both "YYYY-MM-DD HH:mm" and "YYYY-MM-DD" formats
		let components = dateString.split(separator: " ")
		guard let datePart = components.first else { return "" }
		let parts = datePart.split(separator: "-")
		guard parts.count >= 2 else { return "" }
		return "\(parts[0])-\(parts[1])"
	}

	/// Format YYYY-MM as "January 2026"
	private func formatYearMonth(_ yearMonth: String) -> String {
		let parts = yearMonth.split(separator: "-")
		guard parts.count == 2,
			  let year = Int(parts[0]),
			  let month = Int(parts[1]) else {
			return yearMonth
		}

		let monthNames = ["", "January", "February", "March", "April", "May", "June",
						 "July", "August", "September", "October", "November", "December"]
		guard month >= 1, month <= 12 else { return yearMonth }

		return "\(monthNames[month]) \(year)"
	}

	/// Format Date object as string for data attribute
	private func formatDateForAttribute(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		return formatter.string(from: date)
	}

	// MARK: - Component Generators

	/// Generate Bootstrap dropdown with all tags
	private func generateTagDropdown(context: PublishingContext) -> Dropdown {
		let blogPosts = getBlogPosts(context: context)
		let allTags = extractAllTags(from: blogPosts).sorted()

		return Dropdown("Filter by Tag") {
			for tag in allTags {
				Link(tag, target: "#")
					.class("dropdown-item", "filter-tag")
					.data("tag", tag)
			}
		}
		.id("tag-dropdown")
		.class("btn-secondary")
	}

	/// Generate sort toggle button
	private func generateSortButton() -> Button {
		return Button("↓ Newest First")
			.id("sort-toggle")
			.class("btn", "btn-primary")
	}

	/// Generate reset filters button
	private func generateResetButton() -> Button {
		return Button("Reset Filters")
			.id("reset-filters")
			.class("btn", "btn-outline-secondary")
	}

	/// Generate the list of blog posts with data attributes
	private func generateBlogPostsList(context: PublishingContext) -> Group {
		let blogPosts = getBlogPosts(context: context)
			.sorted(by: { $0.date > $1.date })  // Newest first, using built-in date property

		return Group {
			List {
				for post in blogPosts {
					Group {
						// Post title as link
						Text {
							Link(post.metadata["title"] as? String ?? post.title, target: post.path)
						}
						.font(.title4)
						.fontWeight(.semibold)
						.style("margin-bottom: 0.5rem")

						// Metadata line: date and series
						Group {
							Text(formatPostDate(post.date))
								.class("text-muted")
								.style("font-size: 0.9rem")

							if let series = post.metadata["series"] as? String {
								Text(series)
									.class("badge", "bg-secondary")
									.style("margin-left: 0.5rem")
							}
						}
						.style("margin-bottom: 0.5rem")

						// Tags display
//						if !post.tags.isEmpty {
//							Group {
//								for tag in post.tags {
//									Text(tag)
//										.class("badge", "bg-info", "text-dark")
//										.style("margin-right: 0.25rem")
//								}
//							}
//							.style("margin-top: 0.5rem")
//						}

						// Reading time
//						Text("\(post.estimatedReadingMinutes) min read")
//							.class("text-muted")
//							.style("font-size: 0.85rem", "margin-top: 0.5rem")
					}
					.class("blog-post-item")
					.data("date", formatDateForAttribute(post.date))
					.data("tags", post.tags.joined(separator: ","))
					.data("month", extractYearMonthFromDate(post.date))
					.style("margin-bottom: 1.5rem", "padding-bottom: 1rem", "border-bottom: 1px solid #dee2e6")
				}
			}.listStyle(.custom(""))
		}
	}

	/// Format post date for display
	private func formatPostDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: date)
	}

	/// Generate month-based sidebar navigation
	private func generateMonthSidebar(context: PublishingContext) -> Group {
		let blogPosts = getBlogPosts(context: context)
		let monthGroups = groupPostsByMonth(posts: blogPosts)
		let sortedMonths = monthGroups.keys.sorted(by: >)  // Newest months first

		return Group {
			Text("Archive")
				.font(.title5)
				.fontWeight(.bold)
				.style("margin-bottom: 1rem")

//			List {
				for yearMonth in sortedMonths {
					let count = monthGroups[yearMonth] ?? 0
					Link("\(formatYearMonth(yearMonth))", target: "#")
						.class("month-filter", "d-block")
						.data("month", yearMonth)
						.style("font-size: 0.75em", "padding: 0.25rem", "text-decoration: none", "list-style: none")
//				}
			}
		}
		.style("position: sticky", "top: 10px", "border-radius: 0.2rem")
	}
}
