import Foundation
import Ignite

@main
struct IgniteWebsite {
    static func main() async {
        let site = PersonalSite()

        do {
            try await site.publish(buildDirectoryPath: "docs")

            // Run post-build script to add RSS autodiscovery links
            // Get the current working directory
            let fileManager = FileManager.default
            let currentPath = fileManager.currentDirectoryPath
            let scriptPath = "\(currentPath)/add-rss-link.sh"

            // Check if script exists
            if fileManager.fileExists(atPath: scriptPath) {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/bin/bash")
                process.arguments = [scriptPath]
                process.currentDirectoryURL = URL(fileURLWithPath: currentPath)
                try process.run()
                process.waitUntilExit()

                if process.terminationStatus == 0 {
                    print("✓ RSS autodiscovery links added")
                }
            } else {
                print("⚠️  Post-build script not found at: \(scriptPath)")
                print("   Run the script manually or ensure you're in the project root directory")
            }
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
	var syntaxHighlighters: [SyntaxHighlighter] {
		[.swift, .python, .javaScript, .yaml, .bash, .markdown, .sql]
	}

    var author = "Justin Purnell"

    var homePage = Home()
    var theme = MyTheme()
	
	var pages: [any StaticPage] {
		About()
		BusinessMath()
		cv()
		Portfolio()
		Projects()
		next()
	}
	
	var layouts: [any ContentPage] {
		AboutLayout()
		ProjectLayout()
		BlogPostLayout()
	}
}


