//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

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
                "Made in Fürstenberg, by "
                a(href: "https://www.twitter.com/chriseidhof/") {
                    "@chriseidhof"
                }
                "."
                
            }
            
        }
    }
}
