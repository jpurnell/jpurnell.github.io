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

        if let project = article.metadata["project"] as? String {
            Section {
                Image("/images/showcase/\(slug(from: project))-stats.svg",
                      description: "\(project) statistics")
                    .resizable()
                    .accessibilityLabel("\(project) statistics infographic")
                Image("/images/showcase/\(slug(from: project))-commits.svg",
                      description: "\(project) commit history")
                    .resizable()
                    .accessibilityLabel("\(project) commit history chart")
                Image("/images/showcase/\(slug(from: project))-releases.svg",
                      description: "\(project) release history")
                    .resizable()
                    .accessibilityLabel("\(project) release history chart")
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

    /// Returns article tags with "showcase" and "project" filtered out.
    private var filteredTags: [String] {
        (article.tags ?? []).filter { $0 != "showcase" && $0 != "project" }
    }
}
