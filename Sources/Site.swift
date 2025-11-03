import Foundation
import Ignite

@main
struct IgniteWebsite {
    static func main() async {
        let site = PersonalSite()

        do {
            try await site.publish(buildDirectoryPath: "docs")
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct PersonalSite: Site {
    var name = "Justin Purnell"
    var titleSuffix = ""
	var url = URL(string: "https://www.justinpurnell.com")!
	var description = "Product Executive (GS, UCB, NBCU) specializing in AI, digital re-platforming (70+ sites), and high-growth strategy. Expert in Swift development and consensus leadership."
	var keywords: [String] = ["Product Manager", "Strategy", "Product Leader", "Goldman Sachs", "NBCUniversal", "Hotels at Home", "AI", "LLM", "Digital Transformation", "e-commerce", "Swift", "Consensus Leadership", "Leadership", "Agile", "DevOps", "Continuous Integration", "Continuous Deployment", "Cloud", "Data Science", "Machine Learning", "Python", "JavaScript", "Front-end", "Back-end", "Full-stack", "Responsive Design", "Accessibility", "SEO", "Content Strategy", "User Experience", "User Interface", "Design", "Agile", "Product Strategy","Technical Strategy"]
	var language: Locale.Language = .init(identifier: "en-US")

    var builtInIconsEnabled = true
	var feedConfiguration = RSS()
	var robotsConfiguration = Robots()
	
    var author = "Justin Purnell"

    var homePage = Home()
    var theme = MyTheme()
	
	var pages: [any StaticPage] {
		About()
		cv()
		Portfolio()
		Projects()
		next()
	}
	
	var layouts: [any ContentPage] {
		AboutLayout()
		ProjectLayout()
	}
}


