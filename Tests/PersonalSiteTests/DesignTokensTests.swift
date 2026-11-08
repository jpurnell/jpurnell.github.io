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
}
