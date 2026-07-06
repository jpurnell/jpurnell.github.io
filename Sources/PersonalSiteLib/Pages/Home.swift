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
                "Justin Purnell is a product strategist and company builder with two decades of experience spanning Goldman Sachs, the Upright Citizens Brigade Theatre, NBCUniversal, Hotels at Home, and early-stage ventures. He founded Ledge Partners to help growth-stage companies translate complex strategy into measurable results."
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
                "A 2000 graduate of Princeton University and holder of an MBA from the Tuck School of Business at Dartmouth, Justin combines analytical rigor with creative problem-solving. He is an active Swift and Python developer, building open-source tools including BusinessMath (a financial computation framework) and contributing to projects in AI/ML and data science."
            }
            Text {
                "Justin currently serves as President of the Princeton Class of 2000 and has held leadership roles in the alumni organizations of St. Albans School and the Tuck School of Business for over two decades. He is based in the New York metropolitan area."
            }
        }
        .class("visually-hidden")
    }
}
