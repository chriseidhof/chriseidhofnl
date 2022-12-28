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
            I'm Chris Eidhof, co-founder of [objc.io](https://www.objc.io), where we [write books](https://www.objc.io/books/) and [create videos](https://talk.objc.io) about Swift, SwiftUI, iOS, Mac and other similar topics. This is my personal blog.
            """
            miniBio.fromMarkdown
            
        }
        HTML.footer(id: "footer") {
            p(class: "small") {
                "Made by "
                a(href: "https://m.objc.io/@chris", rel: "me") {
                    "@chris@m.objc.io"
                }
                "."
                
            }
            
        }
    }
}
