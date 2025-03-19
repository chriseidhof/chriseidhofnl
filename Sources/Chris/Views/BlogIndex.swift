//
//  File.swift
//  
//
//  Created by Chris Eidhof on 30.06.21.
//

import Foundation
import HTML
import Helpers

let months = [
    "", // 0
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
]

extension Array where Element == BlogPost {
    func groupedByYear() -> Node {
            self.group(by: \.date.year).map { (year) -> Node in
                [
                    h1 { "\(year[0].date.year)" },
                    year.group(by: \.date.month).map { (month) -> Node in
                        [
                            h2(class: "month") { "\(months[month[0].date.month])" },
                            month.list(showYear: false)
                        ]
                    }.asNode()
                ].asNode()
            }.asNode()
    }
    
    func list(showYear: Bool) -> Node {
        Node.fragment(
            self.map { (post: BlogPost) in
                article {
                    a(href: post.link) {
                        h2 { post.metadata.title }
                        p {
                            post.metadata.headline ?? ""
                        }
                        a(href: post.link) {
                            time {
                                "\(post.date.date.pretty(style: showYear ? .dayMonthYear : .dayMonth))"
                            }

                        }

                    }

                }
            }
        )
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
