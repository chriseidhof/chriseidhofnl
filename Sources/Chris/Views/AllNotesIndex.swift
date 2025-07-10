import Foundation
import HTML
import Helpers

struct AllNotesIndex {
    let pages: [Note]
    
    @NodeBuilder var body: HTML.Node {
        article {
            div{
                h1 { "All Notes" }
                
                p {
                    "Complete collection of notes, sorted alphabetically by title."
                }
                
                if pages.isEmpty {
                    p {
                        "No notes available yet."
                    }
                } else {
                    div {
                        Node.fragment(sortedPages.map { page in
                            pageCard(page)
                        })
                    }
                }
            }
        }
    }
    
    var sortedPages: [Note] {
        pages.filter(\.isPublished).sorted { p1, p2 in
            p1.metadata.title.lowercased() < p2.metadata.title.lowercased()
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
                        " • Updated: "
                        u.dateString
                    }
                }
            }
        }
    }
}