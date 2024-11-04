import Foundation
import Ignite

struct cv: StaticPage {
	var title = "Justin Purnell - CV"
	
	func body(context: PublishingContext) -> [BlockElement] {
		if let cv = context.decode(resource: "cv.json", as: CurriculumVitae.self) {
			Text {
				Link(cv.basics.fullName, target: "mailto:morals.tech.0x@icloud.com?subject=[CV Inquiry]")
			}.class("mainTitle")
			
				// Summary Section
			Text("Summary").class("sectionHeader")
			Text(cv.summary.map({$0}).joined(separator: " "))
			
				// Experience Section
			Text("Experience").class("sectionHeader")
			for employer in cv.employers {
				Text {
					Link(employer.name, target: employer.websiteURL ?? "#")
				}.class("institution")
				for project in employer.projects {
					Text {
						Link(project.project, target: project.website ?? "#")
					}.class("project")
					Text(project.position ?? "PROJECT ROLE").class("role")
					Text("\(formatDates(project.startDateString!, end: project.endDateString))").class("role")
					List {
						for highlight in project.highlights {
							Text(highlight).margin(.none)
						}
					}
				}
			}
			
				// Volunteer Section
			Text("Volunteer").class("sectionHeader")
			for volunteeer in cv.volunteering {
				Text {
					Link(volunteeer.organization, target: volunteeer.website)
				}.class("institution")
				for project in volunteeer.projects?.sorted(by: {$0.startDate ?? .distantFuture > $1.startDate ?? .distantPast}) ?? [] {
					Text(project.project ?? "Organization").class("project")
					Text(project.position ?? "VOLUNTEER POSITION").class("role")
					Text("\(formatDates(project.startDateString!, end: project.endDateString))").class("role")
					List {
						for highlight in project.highlights {
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
			for education in cv.education.sorted(by: {getDate($0.startDateString ?? "") > getDate($1.startDateString ?? "") }) {
				Text {
					Link(education.institution, target: education.institution.isEmpty ? "" : education.website)
				}.class("institution").margin(.none)
				Text("\(education.studyType), \(education.area)").class("project")
				Text(getYear(education.endDateString!)).class("role")
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
//			

	}
}
