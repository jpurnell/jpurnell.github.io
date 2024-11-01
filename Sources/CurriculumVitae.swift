//
//  CurriculumVitae.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 9/8/24.
//

import Foundation

struct CurriculumVitae: Codable {
	let basics: Basics
	let summary: [String]
	let skills: [Skill]
	let id: UUID
	let publications: [Publication]
	let employers: [Employer]
	let education: [Education]
	let volunteering: [VolunteerRole]
}

struct Basics: Codable {
	let id: UUID
	let label: String?
	let firstName: String
	let lastName: String
	let picture: String?
	let phone: String
	let email: String
	let website: String
	let location: Location
	let socialProfiles: [SocialProfile]
	var fullName: String { "\(firstName) \(lastName)" }
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
	let endDateString: String?
	let startDateString: String?
	let websiteURL: String?
	let projects: [Project]
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

struct Project: Codable {
	let location: Location
	var id: UUID = UUID()
	let website: String?
	let name: String?
	let endDateString: String?
	let startDateString: String?
	let position: String?
	let project: String
	let highlights: [String]
	var startDate: Date? {
		guard let startDateString else { return nil }
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		return df.date(from: startDateString)
	}
}

struct Education: Codable {
	let location: Location
	let area: String
	let endDateString: String?
	let studyType: String
	var id: UUID
	let startDateString: String?
	let website: String
	let institution: String
	let gpa: String?
	let courses: [String]
	let roles: [Project]?
	let recognition: [String]?
}

struct VolunteerRole: Codable {
	let location: Location
	let website: String
	let endDateString: String?
	var id: UUID = UUID()
	let organization: String
	let projects: [Project]?
	var startDate: Date? {
		return projects?.sorted(by: { $0.startDate ?? .distantPast < $1.startDate ?? .distantFuture }).first?.startDate
	}
	var startDateString: String? {
		guard let date = startDate else { return nil }
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		return df.string(from: date)
	}
}
