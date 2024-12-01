import Foundation
import StaticSite
import HTML

struct Index: Rule {
    var body: some Rule {
        WriteNode(outputName: "index.html", node: [
            BlogPost.homePage.list(showYear: true),
            archiveLink
        ])
        .extraFooterContent(aboutMe)
    }
    
    @NodeBuilder var aboutMe: Node {
        HTML.footer(id: "about-me") {
            let miniBio = """
            I'm Chris Eidhof, co-founder of [objc.io](https://www.objc.io) and creator of [SwiftUI Field Guide](https://www.swiftuifieldguide.com/). This is my personal blog. More [about me](/about).
            """
            miniBio.fromMarkdown
            
        }
        HTML.footer(id: "footer") {
            p(class: "small") {
                "Made by Chris Eidhof "

                "(" %% a(href: "https://m.objc.io/@chris", rel: "me") {
                    "Mastodon"
                } %% ", " %% a(href: "https://bsky.app/profile/eidhof.nl") { "BSky" }
                %% ")."
                
            }
            
        }
    }
}
