import Foundation
import Ignite

/// The CV (curriculum vitae) page, rendering structured career data from `cv.json`.
public struct CV: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "CV"
    @Environment(\.decode) var decode

    public init() {}

    public var body: some HTML {
        if let cv = decode("cv.json", as: CurriculumVitae.self) {
            NavigationBar(logo: nil, items: {
                Link("Experience", target: "#Experience")
                Link("Volunteer", target: "#Volunteer")
                Link("Projects & Publications", target: "#Projects & Publications")
                Link("Education", target: "#Education")
                Link("Skills", target: "#Skills")
                Link("Social", target: "#Social")
            })
            .class("noPrint")

            Text {
                Link(cv.basics.name, target: "mailto:morals.tech.0x@icloud.com?subject=[CV Inquiry]")
            }.class("mainTitle")

            // MARK: - Summary
            Text("Summary").class("sectionHeader").id("Summary")

            Group {
                let summaryArray = cv.summaries.sorted(by: { $0.priority }).filter({ $0.summaryType == .cv })
                if let summary = summaryArray.last,
                   let first = summary.summary.first {
                    Text(markdown: first)
                        .class("mainText")
                    List {
                        ForEach(summary.summary.dropFirst()) { line in
                            Text(markdown: line)
                        }
                    }
                }
            }

            // MARK: - Experience
            Text("Experience").class("sectionHeader").id("Experience")
            ForEach(cv.work) { employer in
                Text {
                    Link(employer.name, target: employer.url ?? "#").target(.blank)
                }.class("institution").id(employer.name)
                ForEach(employer.positions) { position in
                    Group {
                        Text {
                            Link(position.project, target: position.url ?? "#").target(.blank)
                        }.class("project")
                        Text(position.position ?? "PROJECT ROLE").class("role").id(position.position ?? "#")
                        Text("\(formatDates(position.startDate ?? "", end: position.endDate))").class("role")
                        List {
                            ForEach(position.highlights) { highlight in
                                Text(highlight).margin(.none)
                            }
                        }
                    }.id(position.project)
                }
            }

            // MARK: - Volunteer
            Text("Volunteer").class("sectionHeader").id("Volunteer")
            ForEach(cv.volunteer) { volunteer in
                Text {
                    Link(volunteer.organization, target: volunteer.url).target(.blank)
                }.class("institution").id(volunteer.organization)
                ForEach(volunteer.positions?.sorted(by: { $0.start ?? .distantFuture > $1.start ?? .distantPast }) ?? []) { position in
                    Group {
                        Text {
                            Link(position.project, target: position.url ?? "#").target(.blank)
                        }.class("project")
                        Text(position.position ?? "PROJECT ROLE").class("role").id(position.position ?? "#")
                        Text("\(formatDates(position.startDate ?? "", end: position.endDate))").class("role")
                        List {
                            ForEach(position.highlights) { highlight in
                                Text(highlight).margin(.none)
                            }
                        }
                    }.id(position.project)
                }
            }

            // MARK: - Projects & Publications
            Text("Projects & Publications").class("sectionHeader").id("Projects & Publications")
            ForEach(cv.publications.sorted(by: { $0.releaseDate > $1.releaseDate })) { publication in
                Text {
                    Link(publication.name, target: publication.url).target(.blank).class("institution")
                    Link("\(publication.publisher ?? "") \((publication.publisher == nil || publication.releaseDate.isEmpty) ? "" : " - ") \(formatDate(publication.releaseDate))", target: publication.url).target(.blank).class("role")
                }.style(.marginBottom, "0rem")
                List {
                    ForEach(publication.highlights) { highlight in
                        Text(highlight).margin(.none)
                    }
                }
            }

            // MARK: - Education
            Text("Education").class("sectionHeader").id("Education")
            ForEach(cv.education.sorted(by: { getDate($0.startDate ?? "") > getDate($1.startDate ?? "") })) { education in
                Text {
                    Link(education.institution, target: education.institution.isEmpty ? "" : education.url).target(.blank)
                }.class("institution").margin(.none)
                Text("\(education.studyType), \(education.area)").class("project")
                Text(getYear(education.endDate ?? "")).class("role")
                List {
                    ForEach(education.courses) { course in
                        Text(course).margin(.none)
                    }
                }
            }

            // MARK: - Skills
            Text("Skills").class("sectionHeader").id("Skills")
            Text(cv.skills.map { "\($0.name)" }.joined(separator: " | "))
        }
        // MARK: - Social
        Section {
            Text("Social").class("sectionHeader").id("Social")
            Section { SocialLinks() }
                .padding(.horizontal)
                .class("clearfix")
        }.class("noPrint")
    }
}
