import Foundation
import Ignite

struct MyTheme: Theme {
    func render(page: Page, context: PublishingContext) -> HTML {
        HTML {
			Head(for: page, in: context) {
				MetaTag(name: "description", content: PersonalSite().description)
				MetaTag(name: "fediverse:creator", content: "@jpurnell@mastodon.social")
				MetaTag(name: "tags", content: PersonalSite().keywords.map({$0}).joined(separator: ", "))
				Script(code: """
	(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
	new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
	j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
	'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
	})(window,document,'script','dataLayer','GTM-K3TZS8J');
""")
				MetaLink(href: "/css/main.css", rel: "stylesheet")
			}

            Body {
				Include("GTM.html")
				SiteHeader()
				Section {
					page.body
				}
				.width(.max)
				SiteFooter()
				Script(file: "/js/theme-toggle.js")
			}
        }
    }
}
