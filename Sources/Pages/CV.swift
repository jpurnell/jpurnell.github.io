import Foundation
import Ignite

struct cv: StaticPage {
	var title = "Justin Purnell - CV"
	
	func body(context: PublishingContext) -> [BlockElement] {
		if let cv = context.decode(resource: "cv.json", as: CurriculumVitae.self) {
			Text {
				Link(cv.basics.name, target: "mailto:morals.tech.0x@icloud.com?subject=[CV Inquiry]")
			}.class("mainTitle")
			
				// Summary Section
			Text("Summary").class("sectionHeader")
			Text(cv.summaries.filter({$0.summaryType == .cv}).first?.summary.joined(separator: "\n") ?? "")
			
				// Experience Section
			Text("Experience").class("sectionHeader")
			for employer in cv.work {
				Text {
					Link(employer.name, target: employer.url ?? "#")
				}.class("institution")
				for position in employer.positions {
					Text {
						Link(position.project, target: position.url ?? "#")
					}.class("project")
					Text(position.position ?? "PROJECT ROLE").class("role")
					Text("\(formatDates(position.startDate!, end: position.endDate))").class("role")
					List {
						for highlight in position.highlights {
							Text(highlight).margin(.none)
						}
					}
				}
			}
			
				// Volunteer Section
			Text("Volunteer").class("sectionHeader")
			for volunteeer in cv.volunteer {
				Text {
					Link(volunteeer.organization, target: volunteeer.url)
				}.class("institution")
				for position in volunteeer.positions?.sorted(by: {$0.start ?? .distantFuture > $1.start ?? .distantPast}) ?? [] {
					Text(position.project ?? "Organization").class("project")
					Text(position.position ?? "VOLUNTEER POSITION").class("role")
					Text("\(formatDates(position.startDate!, end: position.endDate))").class("role")
					List {
						for highlight in position.highlights {
							Text(highlight).margin(.none)
						}
					}
				}
			}
			
				// Projects & Publications
			Text("Projects & Publications").class("sectionHeader")
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
			
				// Education
			Text("Education").class("sectionHeader")
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
				// Skills
			Text("Skills").class("sectionHeader")
			Text(cv.skills.map{($0.name.hint(text: "\($0.level)\n\($0.keywords.map({word in word}).joined(separator: " | "))"))}.joined(separator: " | "))
		}
				// Social
			Group {
				Text("Social").class("sectionHeader")
				Group { SocialLinks() }.padding(.horizontal)
			}.class("noPrint")
	}
}
