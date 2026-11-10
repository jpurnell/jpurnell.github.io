import Foundation
import Ignite
#if canImport(os)
import os
#endif

/// Reads a generated showcase chart and prepares it to sit directly in a page.
///
/// An SVG loaded through `<img>` cannot see the page's CSS variables or its theme, so a chart that
/// way follows only the browser's OS setting, and not the site's own light/dark toggle. Inlined, it
/// resolves the same `--label`, `--background` and `--series-N` tokens as the text around it.
enum InlineSVGSource {

    #if canImport(os)
    private static let logger = Logger(subsystem: "com.justinpurnell", category: "InlineSVG")
    #endif

    /// Where project-showcase writes the charts, relative to the site's root.
    static var showcaseDirectory: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Assets/images/showcase", isDirectory: true)
    }

    /// The HTML for one chart.
    ///
    /// - Parameters:
    ///   - name: A bare file name such as `swiftclikit-stats.svg`; a path is refused.
    ///   - directory: The folder holding the charts.
    ///   - fallbackAlt: The `alt` text if the chart has to be shown as an `<img>` instead.
    /// - Returns: The inlined `<svg>`, or an `<img>` for the same file when it is missing, is not an
    ///   SVG, or carries script. A graphic is never silently dropped.
    static func html(named name: String, in directory: URL, fallbackAlt: String) -> String {
        guard name == (name as NSString).lastPathComponent, name.hasSuffix(".svg") else {
            return image(named: name, alt: fallbackAlt)
        }
        let text: String
        do {
            text = try String(contentsOf: directory.appendingPathComponent(name), encoding: .utf8)
        } catch {
            #if canImport(os)
            logger.notice("Chart \(name, privacy: .public) unreadable, showing it as an image: \(String(describing: error), privacy: .public)")
            #endif
            return image(named: name, alt: fallbackAlt)
        }
        return inlinable(text) ?? image(named: name, alt: fallbackAlt)
    }

    /// `text` as an inlinable `<svg>`, or `nil` if it is not a plain one.
    private static func inlinable(_ text: String) -> String? {
        var body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if body.hasPrefix("<?xml"), let end = body.range(of: "?>") {
            body = String(body[end.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let lowered = body.lowercased()
        guard body.hasPrefix("<svg "), body.hasSuffix("</svg>"),
              !lowered.contains("<script"), !lowered.contains("<foreignobject") else { return nil }
        // A blank line would end the Markdown HTML block this is handed to as.
        body = body.split(whereSeparator: \.isNewline)
            .filter { !$0.allSatisfy(\.isWhitespace) }
            .joined(separator: "\n")
        // Scale down on a narrow page, as the old <img class="img-fluid"> did.
        return body.replacingOccurrences(
            of: "<svg ", with: "<svg style=\"max-width:100%;height:auto;display:block;margin-bottom:1rem\" ",
            options: [], range: body.range(of: "<svg "))
    }

    private static func image(named name: String, alt: String) -> String {
        let escaped = alt
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
        return "<img src=\"/images/showcase/\(name)\" alt=\"\(escaped)\" class=\"img-fluid\" />"
    }
}

/// A showcase chart placed inline in the page, so it follows the site's theme.
///
/// Composed from `Text(markdown:)`: Ignite keeps the initialiser of its raw-markup primitive
/// internal, and a Markdown HTML block passes through unchanged.
public struct InlineSVG: HTML {
    private let name: String
    private let alt: String

    /// Creates an inline chart.
    /// - Parameters:
    ///   - name: The file name in `Assets/images/showcase`, such as `swiftclikit-stats.svg`.
    ///   - alt: Text for the `<img>` shown instead if the file cannot be inlined.
    public init(_ name: String, alt: String) {
        self.name = name
        self.alt = alt
    }

    /// The chart as raw markup.
    public var body: some HTML {
        Text(markdown: InlineSVGSource.html(
            named: name, in: InlineSVGSource.showcaseDirectory, fallbackAlt: alt))
    }
}
