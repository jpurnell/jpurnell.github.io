import Foundation
import Testing
@testable import PersonalSiteLib

@Suite("Inline showcase graphics")
struct InlineSVGTests {

    private func directory(with files: [String: String]) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("inline-svg-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        for (name, text) in files {
            try text.write(to: url.appendingPathComponent(name), atomically: true, encoding: .utf8)
        }
        return url
    }

    static let chart = """
    <svg xmlns="http://www.w3.org/2000/svg" class="ig" role="img" aria-label="X statistics" width="460" height="220" viewBox="0 0 460 220">
      <style>svg.ig { --ig-label: #111214; }</style>
      <rect class="ig-bg" width="460" height="220"/>
    </svg>
    """

    @Test("A chart on disk is inlined as an svg, not an img")
    func inlinesTheFile() throws {
        let dir = try directory(with: ["x-stats.svg": Self.chart])
        let html = InlineSVGSource.html(named: "x-stats.svg", in: dir, fallbackAlt: "X statistics")

        #expect(html.contains("<svg "))
        #expect(html.contains("--ig-label"))
        #expect(!html.contains("<img"))
    }

    @Test("The chart scales down on a narrow page")
    func isResponsive() throws {
        let dir = try directory(with: ["x-stats.svg": Self.chart])
        let html = InlineSVGSource.html(named: "x-stats.svg", in: dir, fallbackAlt: "X")

        #expect(html.contains("max-width:100%"))
        #expect(html.contains("height:auto"))
        #expect(html.contains("viewBox=\"0 0 460 220\""))
    }

    /// The chart is handed to Markdown as a raw HTML block, and a blank line ends such a block: the
    /// rest would be parsed as prose. The generators write blank lines between elements.
    @Test("No blank line survives, so the svg stays one HTML block")
    func noBlankLines() throws {
        let spaced = Self.chart.replacingOccurrences(of: "\n", with: "\n\n  \n")
        let dir = try directory(with: ["x.svg": spaced])
        let html = InlineSVGSource.html(named: "x.svg", in: dir, fallbackAlt: "X")

        #expect(!html.contains("\n\n"))
        #expect(!html.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).contains { $0.allSatisfy(\.isWhitespace) })
        #expect(html.hasPrefix("<svg "))
    }

    @Test("An XML prolog is dropped, since it is not valid inside an HTML page")
    func dropsProlog() throws {
        let dir = try directory(with: ["x.svg": "<?xml version=\"1.0\"?>\n" + Self.chart])
        let html = InlineSVGSource.html(named: "x.svg", in: dir, fallbackAlt: "X")

        #expect(!html.contains("<?xml"))
        #expect(html.hasPrefix("<svg "))
    }

    @Test("A missing file falls back to an img rather than showing nothing")
    func fallsBackToImage() throws {
        let dir = try directory(with: [:])
        let html = InlineSVGSource.html(named: "gone-stats.svg", in: dir, fallbackAlt: "Gone \"stats\"")

        #expect(html.contains("<img src=\"/images/showcase/gone-stats.svg\""))
        #expect(html.contains("alt=\"Gone &quot;stats&quot;\""))
    }

    @Test("A file that is not an svg is not inlined")
    func refusesNonSVG() throws {
        let dir = try directory(with: ["x.svg": "<html><script>alert(1)</script></html>"])
        let html = InlineSVGSource.html(named: "x.svg", in: dir, fallbackAlt: "X")

        #expect(!html.contains("<script"))
        #expect(html.contains("<img"))
    }

    @Test("A name cannot reach outside the images directory")
    func refusesTraversal() throws {
        let dir = try directory(with: ["x.svg": Self.chart])
        let html = InlineSVGSource.html(named: "../x.svg", in: dir.appendingPathComponent("sub"), fallbackAlt: "X")

        #expect(!html.contains("<svg "))
        #expect(html.contains("<img"))
    }

    @Test("Every generated chart in Assets/ is a well-formed svg that inlines")
    func realChartsInline() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let dir = root.appendingPathComponent("Assets/images/showcase")
        let names = try FileManager.default.contentsOfDirectory(atPath: dir.path).filter { $0.hasSuffix(".svg") }
        try #require(!names.isEmpty)
        for name in names {
            let html = InlineSVGSource.html(named: name, in: dir, fallbackAlt: name)
            #expect(html.hasPrefix("<svg "), "\(name) did not inline")
        }
    }
}
