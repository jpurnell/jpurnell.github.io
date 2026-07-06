import Foundation
import Ignite

/// Article page layout for developer showcase entries, displaying project narratives and SVG infographics.
public struct ShowcaseLayout: ArticlePage {
    /// Creates a new showcase article layout.
    public init() {}

    /// The rendered showcase entry with narrative content and SVG infographics.
    public var body: some HTML {
        Text(article.metadata["title"] as? String ?? article.title)
            .font(.title1)
            .class("mainTitle")

        Group {
            if let date = article.metadata["date"] as? String {
                Text(date)
                    .class("blogDateTime")
            }

            if let project = article.metadata["project"] as? String {
                Text(project)
                    .class("blogDateTime")
                    .style(.marginLeft, "1em")
            }

            Text("\(article.estimatedReadingMinutes) min read")
                .class("blogDateTime")
                .style(.marginLeft, "1em")
        }
        .style(.marginBottom, "2em")

        Section {
            article.text
        }
        .frame(width: .percent(70%), maxWidth: .px(800))
        .class("blurb")

        if let infoSlug = infographicSlug {
            Section {
                Image("/images/showcase/\(infoSlug)-stats.svg",
                      description: "\(infographicLabel) statistics")
                    .resizable()
                    .accessibilityLabel("\(infographicLabel) statistics infographic")
                Image("/images/showcase/\(infoSlug)-commits.svg",
                      description: "\(infographicLabel) commit history")
                    .resizable()
                    .accessibilityLabel("\(infographicLabel) commit history chart")
                Image("/images/showcase/\(infoSlug)-releases.svg",
                      description: "\(infographicLabel) release history")
                    .resizable()
                    .accessibilityLabel("\(infographicLabel) release history chart")
            }
            .class("showcase-infographics")
        }

        if !(article.tags?.isEmpty ?? true) {
            Divider()
            Group {
                Text("Tagged with: \(filteredTags.joined(separator: ", "))")
                    .class("blurb")
                    .style(.fontStyle, "italic")
            }
            .style(.marginTop, "2em")
        }
    }

    /// Converts a project name into a URL-friendly slug.
    private func slug(from project: String) -> String {
        project.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    /// The slug used to locate this entry's SVG infographics, or `nil` to omit the block.
    ///
    /// Infographics are generated per-repository as `{slug}-{stats,commits,releases}.svg`,
    /// where `{slug}` matches the entry's own filename — so we key off the article's own path,
    /// NOT the `project` metadata (which is a display/grouping label like "Internal Infrastructure"
    /// and does not correspond to a card). An `infographics:` front-matter value overrides the
    /// slug, or suppresses the block when set to `false`/`none` (e.g. overview pages with no card).
    private var infographicSlug: String? {
        if let override = article.metadata["infographics"] as? String {
            let lowered = override.lowercased()
            if lowered == "false" || lowered == "none" { return nil }
            return slug(from: override)
        }
        guard let last = article.path.split(separator: "/").last else { return nil }
        let filenameSlug = String(last).lowercased()
        return filenameSlug.isEmpty ? nil : filenameSlug
    }

    /// A human-readable label for the infographic alt text (the display project name, else title).
    private var infographicLabel: String {
        (article.metadata["project"] as? String) ?? article.title
    }

    /// Returns article tags with "showcase" and "project" filtered out.
    private var filteredTags: [String] {
        (article.tags ?? []).filter { $0 != "showcase" && $0 != "project" }
    }
}
