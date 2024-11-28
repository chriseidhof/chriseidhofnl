//
//  File.swift
//  
//
//  Created by Chris Eidhof on 30.06.21.
//

import Foundation
import HTML

extension BlogPost.InContext {
    @NodeBuilder var page: HTML.Node {
        post.page
        if post.isAdvancedSwift {
            advancedSwiftPromo
        }
        HTML.footer {
            nav(id: "post-nav") {
                if let p = previous {
                    span(class: "prev") {
                        a(href: p.link) {
                            span(class: "arrow") {
                                "←"
                            }
                            p.metadata.title
                        }
                    }
                }
                if let n = next {
                    span(class: "next") {
                        a(href: n.link) {
                            n.metadata.title
                            span(class: "arrow") {
                                "→"
                            }
                        }
                    }
                }
            }
        }
    }
}

extension String {
    var fromMarkdown: HTML.Node {
        markdownWithFootnotes()
//        CommonMark.Node(markdown: self).elements.asNode()
    }
}

extension BlogPost {
    @NodeBuilder var page: HTML.Node {
        article(class: "post") {
            header {
                h1 { metadata.title }
                if let h = metadata.headline {
                    h2(class: "headline") { h }
                }
            }
            if metadata.published == false {
                unpublished
            }
            section(class: "postbody") {
                switch body {
                case .markdown(let m):
                    m.markdownWithFootnotes()
                case .pieces(let pieces):
                    pieces.render(prefix: link)
                }
            }
            footer
        }
    }
    
    @NodeBuilder var footer: HTML.Node {
        HTML.footer(class: "group", id: "post-meta") {
            div {
                span {
                    "Posted on "
                    span {
//                        time(datetime: "2019-12-30T00:00:00+00:00", itemprop: "datePublished", pubdate: "pubdate") {
//                            "Mon, Dec 30, 2019"
                            
//                        }
                        time {
                            date.date.pretty(style: .dayMonthYear)
                        }
                        " by Chris Eidhof "
                        "(" %% a(href: "https://m.objc.io/@chris", rel: "me") {
                            "Mastodon"
                        } %% ", " %% a(href: "https://bsky.app/profile/chriseidhof.bsky.social") { "BSky" }
                        %% ")."
                        if let update = updateDate {
                                "(Last update: "
                                //                        time(datetime: "2019-12-30T00:00:00+00:00", itemprop: "datePublished", pubdate: "pubdate") {
                                //                            "Mon, Dec 30, 2019"

                                //                        }
                                time {
                                    update.date.pretty(style: .dayMonthYear)
                                }
                                ")"
                        }
                    }
                }
            }
//            section(id: "sharing") {
//                a(class: "twitter", href: "https://twitter.com/share") {
//                    span(class: "icon-twitter-circled")
//                }
//            }
        }
        
    }
}

var advancedSwiftPromo: HTML.Node {
    footer(class: "group promo", id: "post-meta") {
        div {
            img(src: "/images/advanced-swift.png", style: "width: 90px;")
            
        }
        p {
            """
            If you liked this article, check out our book [Advanced Swift](https://www.objc.io/books/advanced-swift/), or check out [Swift Talk](https://talk.objc.io).
            """.fromMarkdown
            
        }
        
    }
    
}

var unpublished: HTML.Node {
    footer(class: "group promo", id: "post-meta") {
        p {
            """
            Please don't share this, it's not published yet.
            """.fromMarkdown

        }
    }
}
