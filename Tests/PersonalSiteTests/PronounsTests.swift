import Foundation
import Testing
@testable import PersonalSiteLib

@Suite("Pronouns on the CV")
struct PronounsTests {

    private func loadCV() throws -> CurriculumVitae {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let data = try Data(contentsOf: root.appendingPathComponent("Resources/cv.json"))
        return try JSONDecoder().decode(CurriculumVitae.self, from: data)
    }

    @Test("cv.json carries the owner's pronouns")
    func cvHasPronouns() throws {
        let pronouns = try #require(try loadCV().basics.pronouns)

        #expect(pronouns.subject == "he")
        #expect(pronouns.object == "him")
        #expect(pronouns.possessive == "his")
    }

    @Test("A CV with no pronouns still decodes, and has none")
    func absentIsNil() throws {
        let json = """
        {"id":"C74FA3A2-7653-47CF-B31C-B439C09ABA77","firstName":"A","lastName":"B","phone":"1",
         "email":"a@b.c","url":"https://x","location":{"countryCode":"US","city":"C","state":"S"},
         "socialProfiles":[]}
        """
        let basics = try JSONDecoder().decode(Basics.self, from: Data(json.utf8))

        #expect(basics.pronouns == nil)
    }

    @Test("The display form is optional and defaults to subject/object")
    func displayForm() throws {
        let plain = Pronouns(subject: "they", object: "them", possessive: "their")
        let custom = Pronouns(subject: "he", object: "him", possessive: "his", display: "he/him, any is fine")

        #expect(plain.display == "they/them")
        #expect(custom.display == "he/him, any is fine")
    }

    @Test("Pronouns round-trip through Codable")
    func roundTrip() throws {
        let original = Pronouns(subject: "she", object: "her", possessive: "hers")
        let decoded = try JSONDecoder().decode(Pronouns.self, from: JSONEncoder().encode(original))

        #expect(decoded == original)
    }

    /// Stored for tools that write about the owner. Nothing in the page or the structured data
    /// states them: schema.org's Person has no such property, and exposing them is a separate choice.
    @Test("Pronouns are not published in the JSON-LD")
    func notInStructuredData() throws {
        let nodes = CVStructuredData.graphNodes(from: try loadCV())
        let data = try JSONSerialization.data(withJSONObject: nodes)
        let text = String(decoding: data, as: UTF8.self).lowercased()

        // The key and the value, not the word: a project description may say "pronoun density".
        #expect(!text.contains("\"pronouns\""))
        #expect(!text.contains("he/him"))
        #expect(!text.contains("\"possessive\""))
    }
}
