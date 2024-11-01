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
	var description = "Official Homepage for Justin Purnell"
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
	}
	
	var layouts: [any ContentPage] {
		AboutLayout()
	}
}


