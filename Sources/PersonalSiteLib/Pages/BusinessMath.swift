import Foundation
import Ignite

/// The BusinessMath page displaying the course introduction, blog post index with filtering, and a month-based archive sidebar.
public struct BusinessMath: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "BusinessMath"
    @Environment(\.articles) var articles

    public init() {}

    public var body: some HTML {
        ForEach(articles.all.filter({ $0.title == "Welcome to BusinessMath: A 12-Week Journey" })) { article in
            Text {
                Link("BusinessMath", target: "https://www.github.com/jpurnell/BusinessMath")
            }.font(.title1).class("mainTitle")
            Divider()
            Text(markdown: article.text).frame(width: .percent(70%), maxWidth: .px(800))
        }

        // Filter controls section
        Section {
            generateTagDropdown()
            generateSortButton()
            generateResetButton()
        }
        .class("filter-controls")
        .style(.marginBottom, "2rem")
        .style(.display, "flex")
        .style(.gap, "1rem")
        .style(.alignItems, "center")
        .style(.flexWrap, "wrap")

        // Main content area with sidebar layout
        Section {
            Section {
                generateMonthSidebar()
            }
            .class("col-md-3")
            .id("month-sidebar")

            Section {
                generateBlogPostsList()
            }
            .class("col-md-9")
            .id("blog-posts-list")
        }
        .class("row")

        // Include the blog filtering JavaScript
        Script(file: "/js/blog-filter.js")
    }

    // MARK: - Helper Functions

    /// Returns all articles that use the blog post layout or reside under `/blog/`.
    private func getBlogPosts() -> [Article] {
        return articles.all.filter { article in
            article.layout == "BlogPostLayout" || article.path.contains("/blog/")
        }
    }

    /// Collects all unique tags from the given posts.
    private func extractAllTags(from posts: [Article]) -> [String] {
        var allTags = Set<String>()
        for post in posts {
            post.tags?.forEach { allTags.insert($0) }
        }
        return Array(allTags)
    }

    /// Groups posts by "yyyy-MM" key and returns a count per month.
    private func groupPostsByMonth(posts: [Article]) -> [String: Int] {
        var groups: [String: Int] = [:]
        for post in posts {
            let yearMonth = extractYearMonthFromDate(post.date)
            if !yearMonth.isEmpty {
                groups[yearMonth, default: 0] += 1
            }
        }
        return groups
    }

    /// Formats a `Date` as "yyyy-MM" for month grouping.
    private func extractYearMonthFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }

    /// Converts "yyyy-MM" to "Month Year" (e.g. "2025-01" → "January 2025").
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

    /// Formats a `Date` as "yyyy-MM-dd HH:mm" for use in HTML data attributes.
    private func formatDateForAttribute(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }

    // MARK: - Component Generators

    /// Builds the tag filter dropdown menu.
    @HTMLBuilder
    private func generateTagDropdown() -> some HTML {
        let blogPosts = getBlogPosts()
        let allTags = extractAllTags(from: blogPosts).sorted()

        Dropdown("Filter by Tag") {
            for tag in allTags {
                Link(tag, target: "#")
            }
        }
        .id("tag-dropdown")
        .class("btn-secondary")
    }

    /// Builds the sort order toggle button.
    @HTMLBuilder
    private func generateSortButton() -> some HTML {
        Button("Newest First")
            .id("sort-toggle")
            .class("btn", "btn-primary")
    }

    /// Builds the filter reset button.
    @HTMLBuilder
    private func generateResetButton() -> some HTML {
        Button("Reset Filters")
            .id("reset-filters")
            .class("btn", "btn-outline-secondary")
    }

    /// Builds the chronological list of blog posts with date, tags, and reading time metadata.
    @HTMLBuilder
    private func generateBlogPostsList() -> some HTML {
        let blogPosts = getBlogPosts()
            .sorted(by: { $0.date < $1.date })

        for post in blogPosts {
            Section {
                Text {
                    Link(post.metadata["title"] as? String ?? post.title, target: post.path)
                }
                .font(.title4)
                .fontWeight(.semibold)
                .style(.marginBottom, "0.5rem")

                Section {
                    Text(formatPostDate(post.date))
                        .class("blogDateTime")

                    Text("\(post.estimatedReadingMinutes) min read")
                        .class("blogDateTime")
                        .style(.marginTop, "0.5rem")
                }
                .style(.marginBottom, "0.5rem")
            }
            .class("blog-post-item")
            .data("date", formatDateForAttribute(post.date))
            .data("tags", (post.tags ?? []).joined(separator: ","))
            .data("month", extractYearMonthFromDate(post.date))
            .style(.marginBottom, "1.5rem")
            .style(.paddingBottom, "1rem")
            .style(.borderBottom, "1px solid #dee2e6")
        }
    }

    /// Formats a `Date` in medium date style for display (e.g. "Jan 15, 2025").
    private func formatPostDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Builds the sticky sidebar listing months with post counts for archive navigation.
    @HTMLBuilder
    private func generateMonthSidebar() -> some HTML {
        let blogPosts = getBlogPosts()
        let monthGroups = groupPostsByMonth(posts: blogPosts)
        let sortedMonths = monthGroups.keys.sorted(by: >)

        if monthGroups.count > 1 {
            Section {
                Text("Archive")
                    .font(.title5)
                    .fontWeight(.bold)
                    .style(.marginBottom, "1rem")

                for yearMonth in sortedMonths {
                    Link("\(formatYearMonth(yearMonth))", target: "#")
                        .class("month-filter", "d-block")
                        .data("month", yearMonth)
                        .style(.fontSize, "0.75em")
                        .style(.padding, "0.25rem")
                        .style(.textDecoration, "none")
                }
            }
            .style(.position, "sticky")
            .style(.top, "10px")
            .style(.borderRadius, "0.2rem")
        }
    }
}
