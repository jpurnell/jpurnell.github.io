//
//  CurriculumVitae.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 9/8/24.
//

import Foundation

enum SummaryType: String, Codable {
	case cv
	case resume
	case website
}

struct CurriculumVitae: Codable {
	let id: UUID
	let basics: Basics
	let summaries: [Summary]
	let skills: [Skill]
	let publications: [Publication]
	let work: [Employer]
	let education: [Education]
	let volunteer: [VolunteerRole]
}

struct Images: Codable {
	let imageType: String
	let image: String
	let imageDescription: String
}

struct Summary: Codable {
	let priority: Int
	let summaryType: SummaryType
	let summary: [String]
	var wordCount: Int { return summary.joined(separator: "\n").split{ !$0.isLetter}.count }
	var charCount: Int { return summary.joined(separator: "\n").count }
}

struct Basics: Codable {
	let id: UUID
	let label: String?
	let firstName: String
	let lastName: String
	let picture: String?
	let phone: String
	let email: String
	let url: String
	let location: Location
	let socialProfiles: [SocialProfile]
	var name: String { "\(firstName) \(lastName)" }
}

struct Location: Codable {
	let postalCode: String?
	let countryCode: String
	let city: String
	let state: String
	let address: String?
}

struct SocialProfile: Codable {
	let username: String
	var id: UUID = UUID()
	let url: String
	let network: String
}

struct Skill: Codable {
	var id: UUID = UUID()
	let level: String
	let name: String
	let keywords: [String]
}

struct Employer: Codable {
	let location: Location
	let endDate: String?
	let startDate: String?
	let url: String?
	let positions: [Position]
	var id: UUID = UUID()
	let name: String
	let position: String?
}

struct Publication: Codable {
	var id: UUID = UUID()
	let releaseDate: String
	let highlights: [String]
	let name: String
	let publisher: String?
	let url: String
}

struct Position: Codable {
	let location: Location
	var id: UUID = UUID()
	let url: String?
	let name: String?
	let endDate: String?
	let startDate: String?
	let position: String?
	let project: String
	let highlights: [String]
	let skill: [Skill]?
	var start: Date? {
		guard let startDate else { return nil }
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		return df.date(from: startDate)
	}
}

struct Education: Codable {
	let location: Location
	let area: String
	let endDate: String?
	let studyType: String
	var id: UUID
	let startDate: String?
	let url: String
	let institution: String
	let gpa: String?
	let courses: [String]
	let positions: [Position]?
	let recognition: [String]?
}

struct VolunteerRole: Codable {
	let location: Location
	let url: String
	let endDate: String?
	var id: UUID = UUID()
	let organization: String
	let positions: [Position]?
	var startDate: Date? {
		return positions?.sorted(by: { $0.start ?? .distantPast < $1.start ?? .distantFuture }).first?.start
	}
	var start: String? {
		guard let date = startDate else { return nil }
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		return df.string(from: date)
	}
}
