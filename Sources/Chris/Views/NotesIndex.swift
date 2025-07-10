import Foundation
import HTML
import Helpers

struct NotesIndex {
    let pages: [Note]
    
    @NodeBuilder var body: HTML.Node {
        article {
            div{
                p {
                    "Living notes that evolve over time. These pages are updated with new insights, corrections, and improvements. Similar to a wiki but with a single editor."
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
                    div {
                        Node.fragment(pages.prefix(10).map { page in
                            pageCard(page)
                        })
                    }
                }
            }
        }
    }
    
    @NodeBuilder func pageCard(_ page: Note) -> HTML.Node {
        div {
            h2 {
                a(href: page.url) {
                    page.metadata.title
                }
            }
            
            if let description = page.metadata.description {
                p { description }
            }
            
            div {
                span {
                    "Created: "
                    page.createdDate.dateString
                }

                if let u = page.updatedDate {
                    span {
                        "Updated: "
                        u.dateString
                    }
                }

                if let changelog = page.metadata.changelog, !changelog.isEmpty {
                    span {
                        "\(changelog.count) revision\(changelog.count == 1 ? "" : "s")"
                    }
                }
            }
        }
    }
    
}
