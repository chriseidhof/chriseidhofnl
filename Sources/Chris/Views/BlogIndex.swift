//
//  File.swift
//  
//
//  Created by Chris Eidhof on 30.06.21.
//

import Foundation
import HTML

let df: DateFormatter = {
    var x = DateFormatter()
    x.dateFormat = "MMM d, yyyy"
    return x
}()

let df2: DateFormatter = {
    var x = DateFormatter()
    x.dateFormat = "MMM d"
    return x
}()

extension Date {
    func pretty(showYear: Bool) -> String {
        showYear ?
            df.string(from: self) : df2.string(from: self)
    }
}

let months = [
    "", // 0
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
]

extension Array where Element == BlogPost {
    func groupedByYear() -> Node {
        HTML.div(id: "archive-list") {
            self.group(by: \.date.year).map { (year) -> Node in
                [
                    h1(class: "archive") { "\(year[0].date.year)" },
                    year.group(by: \.date.month).map { (month) -> Node in
                        [
                            h2(class: "month") { "\(months[month[0].date.month])" },
                            month.list(showYear: false)
                        ]
                    }.asNode()
                ].asNode()
            }.asNode()
        }
    }
    
    func list(showYear: Bool) -> Node {
        ul(id: "post-list") {
            self.map { (post: BlogPost) in
                li {
                    a(href: post.link) {
                        aside(class: "dates") {
                            "\(post.date.date.pretty(showYear: showYear))"
                        }
                        
                    }
                    a(href: post.link) {
                        post.metadata.title
                        h2 {
                            post.metadata.headline ?? ""
                        }
                        
                    }
                    
                }
            }
        }

    }
}

@NodeBuilder var archiveLink: Node {
    footer(id: "post-list-footer") {
        a(href: "/archive", id: "archive-link") {
            span(class: "arrow") { "←" }
            "Archive"
        }
    }
}
