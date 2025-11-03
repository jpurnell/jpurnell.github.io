import Foundation
import Ignite

struct cv: StaticPage {
	var title = "Justin Purnell - CV"
	
	func body(context: PublishingContext) -> [BlockElement] {
		
		if let cv = context.decode(resource: "cv.json", as: CurriculumVitae.self) {
			NavigationBar {
				Link("Experience", target: "#Experience")
				Link("Volunteer", target: "#Volunteer")
				Link("Projects & Publications", target: "#Projects & Publications")
				Link("Education", target: "#Education")
				Link("Skills", target: "#Skills")
				Link("Social", target: "#Social")
			}.class("noPrint")
			Text {
				Link(cv.basics.name, target: "mailto:morals.tech.0x@icloud.com?subject=[CV Inquiry]")
			}.class("mainTitle")
			
			// MARK: -- Summary
			sectionHeader("Summary")
			Text(cv.summaries.sorted(by: {$0.priority}).filter({$0.summaryType == .cv}).first?.summary.joined(separator: "\n") ?? "")
			
			// MARK: -- Experience
			sectionHeader("Experience")
			for employer in cv.work {
				Text {
					Link(employer.name, target: employer.url ?? "#")
				}.class("institution").id(employer.name)
				for position in employer.positions {
					positionSummary(position)
				}
			}
			
			// MARK: -- Volunteer
			sectionHeader("Volunteer")
			for volunteer in cv.volunteer {
				Text {
					Link(volunteer.organization, target: volunteer.url)
				}.class("institution").id(volunteer.organization)
				for position in volunteer.positions?.sorted(by: {$0.start ?? .distantFuture > $1.start ?? .distantPast}) ?? [] {
					positionSummary(position)
				}
			}
			
			// MARK: -- Projects & Publications
			sectionHeader("Projects & Publications")
			for publication in cv.publications.sorted(by: {$0.releaseDate > $1.releaseDate}) {
				Text {
					Link(publication.name, target: publication.url).class("institution")
					Link(Text("\(publication.publisher ?? "") \((publication.publisher == nil || publication.releaseDate.isEmpty) ? "" : " - ") \(formatDate(publication.releaseDate))"), target: publication.url).class("role")
				}.style("margin-bottom: 0rem")
				List {
					for highlight in publication.highlights {
						Text(highlight).margin(.none)
					}
				}
			}
			
			// MARK: -- Education
			sectionHeader("Education")
			for education in cv.education.sorted(by: {getDate($0.startDate ?? "") > getDate($1.startDate ?? "") }) {
				Text {
					Link(education.institution, target: education.institution.isEmpty ? "" : education.url)
				}.class("institution").margin(.none)
				Text("\(education.studyType), \(education.area)").class("project")
				Text(getYear(education.endDate!)).class("role")
				List {
					for course in education.courses {
						Text(course).margin(.none)
					}
				}
			}
			// MARK: -- Skills
			sectionHeader("Skills")
			Text(cv.skills.map{($0.name.hint(text: "\($0.level)\n\($0.keywords.map({word in word}).joined(separator: " | "))"))}.joined(separator: " | "))
		}
			// MARK: -- Social
			Group {
				sectionHeader("Social")
				Group { SocialLinks() }.padding(.horizontal)
			}.class("noPrint")
	}
}

extension cv {
	// MARK: -- Section Header
	func sectionHeader(_ text: String) -> Text {
		return Text(text).class("sectionHeader").id(text)
	}
	
	// MARK: -- Position Summary
	func positionSummary(_ position: Position) -> Group {
		return Group {
			Text {
				Link(position.project, target: position.url ?? "#")
			}.class("project")
			Text(position.position ?? "PROJECT ROLE").class("role").id(position.position ?? "#")
			Text("\(formatDates(position.startDate!, end: position.endDate))").class("role")
			List {
				for highlight in position.highlights {
					Text(highlight).margin(.none)
				}
			}
		}.id(position.project)
	}
}
