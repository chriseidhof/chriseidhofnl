import Foundation
import HTML
import Helpers

struct NotesIndex {
    let pages: [Note]
    
    @NodeBuilder var body: HTML.Node {
        article {
            div{
                p {
                    "These notes are updated with new insights, corrections, and improvements. Similar to a wiki but with a single editor, updated on an irregular basis."
                }

                p {
                    "These notes are not highly edited or finished articles. They are a collection of ideas, links and thoughts mainly for myself (but made public)."
                }

                if pages.isEmpty {
                    p {
                        "No notes available yet."
                    }
                } else {
                    h2 { "Recent Edits" }
                    pages.prefix(10).map { page in
                        pageCard(page)
                    }

                    h2 { "All Notes"}

                    p {
                        a(href: "/note/all/") {
                            "View all notes alphabetically →"
                        }
                    }
                }
            }
        }
    }
    
    @NodeBuilder func pageCard(_ page: Note) -> HTML.Node {
        div(class: "pageCard") {
            a(href: page.url) {
                page.metadata.title
            }
            div {
                if let u = page.updatedDate {
                    time {
                        u.dateString
                    }
                } else {
                    time {
                        page.createdDate.dateString
                    }
                }
            }
        }
    }
    
}
