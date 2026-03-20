import Testing
import Foundation
@testable import PersonalSiteLib

@Suite("Build Output")
struct BuildOutputTests {

    /// Project root directory, derived from the test file location.
    /// Path: Tests/PersonalSiteTests/File.swift → Tests/PersonalSiteTests → Tests → project root
    private static let projectRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // → Tests/PersonalSiteTests
        .deletingLastPathComponent() // → Tests
        .deletingLastPathComponent() // → project root

    /// Path to the docs/ build output directory.
    private var docsPath: String {
        Self.projectRoot
            .appendingPathComponent("docs")
            .path
    }

    private func readFile(_ relativePath: String) throws -> String {
        let fullPath = docsPath + "/" + relativePath
        return try String(contentsOfFile: fullPath, encoding: .utf8)
    }

    @Test("index.html exists in build output")
    func indexHTMLExists() {
        let exists = FileManager.default.fileExists(atPath: docsPath + "/index.html")
        #expect(exists, "docs/index.html should exist")
    }

    @Test("llms.txt exists in build output")
    func llmsTxtExists() {
        let exists = FileManager.default.fileExists(atPath: docsPath + "/llms.txt")
        #expect(exists, "docs/llms.txt should exist")
    }

    @Test("ai.txt exists in build output")
    func aiTxtExists() {
        let exists = FileManager.default.fileExists(atPath: docsPath + "/ai.txt")
        #expect(exists, "docs/ai.txt should exist")
    }

    @Test("feed.rss exists in build output")
    func feedRSSExists() {
        let exists = FileManager.default.fileExists(atPath: docsPath + "/feed.rss")
        #expect(exists, "docs/feed.rss should exist")
    }

    @Test("index.html contains JSON-LD structured data")
    func indexHasJSONLD() throws {
        let html = try readFile("index.html")
        #expect(html.contains("application/ld+json"))
        #expect(html.contains("\"@type\" : \"Person\"") || html.contains("\"@type\":\"Person\""))
    }

    @Test("index.html contains Open Graph meta tags")
    func indexHasOGTags() throws {
        let html = try readFile("index.html")
        #expect(html.contains("og:description"))
        #expect(html.contains("og:image"))
    }
}
