import Foundation
import Ignite

/// The site's home page displaying the site title and visually-hidden biographical content for AI crawlers and screen readers.
public struct Home: StaticPage {
    /// Page title used in the `<title>` tag.
    public var title = "Justin Purnell — Strategist, Builder, Product Leader"

    /// Creates a new Home page.
    public init() {}

    /// The home page content with site title and hidden biographical text.
    public var body: some HTML {
        Text("Justin Purnell")
            .font(.title1)
            .class("siteTitle")
            .padding(.horizontal, 10)

        // Visually-hidden content for AI crawlers and screen readers
        Group {
            Text {
                "Justin Purnell is a product strategist and company builder with two decades of experience spanning Goldman Sachs, the Upright Citizens Brigade Theatre, NBCUniversal, Hotels at Home, and early-stage ventures. He founded Ledge Partners, a search fund formed to acquire and operate a profitable business, and builds the software he needs along the way: he writes the specification and ships the verified build."
            }
            Text {
                "At Goldman Sachs, Justin served as a credit research analyst covering oil and gas companies, and then gaming, lodging, and leisure companies, publishing institutional research relied upon by portfolio managers worldwide. He transitioned to digital media at UCB Comedy (Upright Citizens Brigade), where he launched UCBComedy.com and established a digital presence for one of America's most influential comedy institutions."
            }
            Text {
                "At NBCUniversal, Justin after stints in digital strategy, marketing, and news, Justin launched Seeso, NBCU's first direct to consumer streaming platform as head of strategy and operations, and then led product for the Golf Channel's ShopWithGolf.com, managing a portfolio of branded retail experiences. He oversaw technology re-platforming, vendor negotiations, and strategy for multiple partners."
            }
            Text {
                "Justin then served as Head of Product at Hotels at Home, the exclusive hospitality retail partner for Marriott International. He rebuilt the company's digital platform across 70+ branded storefronts (ShopMarriott.com, WestinStore.com, RitzCarltonShops.com), driving multimillion-dollar revenue growth and leading a cross-functional team of engineers, designers, and merchandisers."
            }
            Text {
                "A 2000 graduate of Princeton University and holder of an MBA from the Tuck School of Business at Dartmouth, Justin combines analytical rigor with creative problem-solving. He builds and ships production Swift software with AI agents under a design-first, test-driven practice held to an automated quality gate: SwiftMCPServer (195/195 on the official Model Context Protocol conformance suite), SwiftMCPClient, swift-oauth (OAuth 2.1), BusinessMath and BusinessMathMCP (200+ financial analysis tools for AI assistants), GeoSEOMCP and geo-audit, and quality-gate-swift (45 static checkers, 3,213 tests)."
            }
            Text {
                "Justin currently serves as President of the Princeton Class of 2000 and has held leadership roles in the alumni organizations of St. Albans School and the Tuck School of Business for over two decades. He is based in the New York metropolitan area."
            }
        }
        .class("visually-hidden")
    }
}
