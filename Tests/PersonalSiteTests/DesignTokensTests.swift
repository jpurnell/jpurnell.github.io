import Testing
import Foundation
import DesignTokens

@Suite("DesignTokens adoption")
struct DesignTokensAdoptionTests {

    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    private static func read(_ path: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
    }

    @Test("tokens.css equals a fresh emit from the DesignTokens package")
    func tokensAreCurrent() throws {
        #expect(try Self.read("Assets/css/tokens.css") == CSSEmitter.emit())
    }

    @Test("main.css holds no colour literals; every colour comes from tokens.css")
    func mainCSSHasNoLiterals() throws {
        let css = try Self.read("Assets/css/main.css")
        let literal = try Regex(#"#[0-9a-fA-F]{3,8}\b|rgba?\(|hsla?\("#)
        let hits = css.matches(of: literal).map { String(css[$0.range]) }
        #expect(hits.isEmpty, "colour literals in main.css: \(hits)")
    }

    @Test("main.css refers only to custom properties that tokens.css defines")
    func customPropertiesAreDefined() throws {
        let main = try Self.read("Assets/css/main.css")
        let tokens = try Self.read("Assets/css/tokens.css")
        let use = try Regex(#"var\((--[a-z0-9-]+)"#)
        let names = Set(main.matches(of: use).compactMap { $0.output[1].substring.map(String.init) })
        // Bootstrap's own variables are defined by Bootstrap, not by the tokens.
        let ours = names.filter { !$0.hasPrefix("--bs-") }
        let missing = ours.filter { !tokens.contains("\($0):") }.sorted()
        #expect(missing.isEmpty, "undefined in tokens.css: \(missing)")
    }

    @Test("main.css names no font family: type comes from the --font-* tokens")
    func noFontNames() throws {
        let css = try Self.read("Assets/css/main.css")
        let literal = css.split(whereSeparator: \.isNewline).filter { $0.contains("font-family:") && !$0.contains("var(") }
        #expect(literal.isEmpty, "font-family without a token: \(literal)")
        #expect(!css.contains("Ovo") && !css.contains("Garamond") && !css.contains("@font-face"))
    }

    @Test("Swift sources hold no colour literals, so inline styles cannot bypass the tokens")
    func swiftSourcesHaveNoLiterals() throws {
        let sources = Self.root.appendingPathComponent("Sources")
        let literal = try Regex(#"#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b(?![0-9a-zA-Z])"#)
        let enumerator = try #require(FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil))
        var offenders: [String] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            let text = try String(contentsOf: url, encoding: .utf8)
            for line in text.split(whereSeparator: \.isNewline) where !line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                if line.contains(literal) { offenders.append("\(url.lastPathComponent): \(line.trimmingCharacters(in: .whitespaces))") }
            }
        }
        #expect(offenders.isEmpty, "colour literals in Swift: \(offenders)")
    }
}
