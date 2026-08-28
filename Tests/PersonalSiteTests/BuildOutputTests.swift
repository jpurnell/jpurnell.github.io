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
        return try String(contentsOf: buildOutputURL(relativePath), encoding: .utf8)
    }

    /// A build-output URL with `.` and `..` segments already collapsed.
    ///
    /// String concatenation followed by `FileManager.fileExists(atPath:)` takes the
    /// path exactly as handed over, so a `..` segment silently reads outside `docs/`.
    /// Standardizing the URL resolves those segments before anything touches the
    /// filesystem — the actual CWE-22 defence, not a way to quiet the warning about it.
    private func buildOutputURL(_ relativePath: String) -> URL {
        Self.projectRoot
            .appendingPathComponent("docs")
            .appendingPathComponent(relativePath)
            .standardized
    }

    /// Whether a build-output file exists, checked through the standardized URL.
    private func buildOutputExists(_ relativePath: String) -> Bool {
        (try? buildOutputURL(relativePath).checkResourceIsReachable()) ?? false
    }

    @Test("index.html exists in build output")
    func indexHTMLExists() {
        let exists = buildOutputExists("index.html")
        #expect(exists, "docs/index.html should exist")
    }

    @Test("llms.txt exists in build output")
    func llmsTxtExists() {
        let exists = buildOutputExists("llms.txt")
        #expect(exists, "docs/llms.txt should exist")
    }

    @Test("ai.txt exists in build output")
    func aiTxtExists() {
        let exists = buildOutputExists("ai.txt")
        #expect(exists, "docs/ai.txt should exist")
    }

    @Test("feed.rss exists in build output")
    func feedRSSExists() {
        let exists = buildOutputExists("feed.rss")
        #expect(exists, "docs/feed.rss should exist")
    }

    @Test("index.html contains JSON-LD structured data with @graph")
    func indexHasJSONLD() throws {
        let html = try readFile("index.html")
        #expect(html.contains("application/ld+json"))
        #expect(html.contains("\"@graph\""))
        #expect(html.contains("\"@type\" : \"Person\"") || html.contains("\"@type\":\"Person\""))
    }

    @Test("index.html contains Open Graph meta tags")
    func indexHasOGTags() throws {
        let html = try readFile("index.html")
        #expect(html.contains("og:description"))
        #expect(html.contains("og:image"))
    }
}
