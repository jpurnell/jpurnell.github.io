import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("CurriculumVitae")
struct CurriculumVitaeTests {

    /// Project root directory, derived from the test file location.
    /// Path: Tests/PersonalSiteTests/File.swift → Tests/PersonalSiteTests → Tests → project root
    private static let projectRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // → Tests/PersonalSiteTests
        .deletingLastPathComponent() // → Tests
        .deletingLastPathComponent() // → project root

    /// Loads and decodes the real cv.json from the Resources directory.
    private func loadCV() throws -> CurriculumVitae {
        let url = Self.projectRoot
            .appendingPathComponent("Resources")
            .appendingPathComponent("cv.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(CurriculumVitae.self, from: data)
    }

    // MARK: - Golden Path

    @Test("cv.json decodes successfully")
    func decodesSuccessfully() throws {
        let cv = try loadCV()
        #expect(!cv.basics.firstName.isEmpty)
    }

    @Test("Basics has correct name")
    func basicsName() throws {
        let cv = try loadCV()
        #expect(cv.basics.name == "Justin Purnell")
    }

    @Test("Basics has valid email")
    func basicsEmail() throws {
        let cv = try loadCV()
        #expect(cv.basics.email.contains("@"))
    }

    @Test("Basics has location")
    func basicsLocation() throws {
        let cv = try loadCV()
        #expect(!cv.basics.location.city.isEmpty)
        #expect(!cv.basics.location.state.isEmpty)
    }

    @Test("Work section is non-empty")
    func workNonEmpty() throws {
        let cv = try loadCV()
        #expect(!cv.work.isEmpty)
    }

    @Test("Each employer has at least one position")
    func employerPositions() throws {
        let cv = try loadCV()
        for employer in cv.work {
            #expect(!employer.positions.isEmpty, "Employer \(employer.name) has no positions")
        }
    }

    @Test("Education section is non-empty")
    func educationNonEmpty() throws {
        let cv = try loadCV()
        #expect(!cv.education.isEmpty)
    }

    @Test("Skills section is non-empty")
    func skillsNonEmpty() throws {
        let cv = try loadCV()
        #expect(!cv.skills.isEmpty)
    }

    @Test("Publications section is non-empty")
    func publicationsNonEmpty() throws {
        let cv = try loadCV()
        #expect(!cv.publications.isEmpty)
    }

    @Test("Volunteer section is non-empty")
    func volunteerNonEmpty() throws {
        let cv = try loadCV()
        #expect(!cv.volunteer.isEmpty)
    }

    @Test("Summaries include a CV type")
    func summariesIncludeCV() throws {
        let cv = try loadCV()
        let cvSummaries = cv.summaries.filter { $0.summaryType == .cv }
        #expect(!cvSummaries.isEmpty)
    }

    // MARK: - Computed Properties

    @Test("Summary wordCount is positive")
    func summaryWordCount() throws {
        let cv = try loadCV()
        if let summary = cv.summaries.first {
            #expect(summary.wordCount > 0)
        }
    }

    @Test("Summary charCount is positive")
    func summaryCharCount() throws {
        let cv = try loadCV()
        if let summary = cv.summaries.first {
            #expect(summary.charCount > 0)
        }
    }

    @Test("Position start date parses correctly")
    func positionStartDate() throws {
        let cv = try loadCV()
        let firstPosition = cv.work.first?.positions.first
        if let position = firstPosition, position.startDate != nil {
            #expect(position.start != nil)
        }
    }

    // MARK: - Invalid Input

    @Test("Invalid JSON throws DecodingError")
    func invalidJSON() {
        let badData = Data("{ invalid }".utf8)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(CurriculumVitae.self, from: badData)
        }
    }

    @Test("Empty JSON object throws DecodingError")
    func emptyJSON() {
        let emptyData = Data("{}".utf8)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(CurriculumVitae.self, from: emptyData)
        }
    }

    // MARK: - SummaryType

    @Test("SummaryType decodes from raw value")
    func summaryTypeDecoding() throws {
        let json = Data(#""cv""#.utf8)
        let decoded = try JSONDecoder().decode(SummaryType.self, from: json)
        #expect(decoded == .cv)
    }
}
