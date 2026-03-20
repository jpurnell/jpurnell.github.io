import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("SkillType")
struct SkillTypesTests {

    @Test("All cases have non-empty raw values")
    func allRawValuesNonEmpty() {
        for skill in SkillType.allCases {
            #expect(!skill.rawValue.isEmpty, "Skill case \(skill) has empty raw value")
        }
    }

    @Test("Codable round-trip preserves value")
    func codableRoundTrip() throws {
        let original = SkillType.swift
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SkillType.self, from: data)
        #expect(decoded == original)
    }

    @Test("Invalid raw value returns nil")
    func invalidRawValue() {
        let result = SkillType(rawValue: "Nonexistent Skill XYZ")
        #expect(result == nil)
    }
}
