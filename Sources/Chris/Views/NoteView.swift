import Foundation
import HTML
import Helpers

struct NoteView {
    let page: Note
    
    @NodeBuilder var body: HTML.Node {
        article {
            div(class: "") {
                // Page header with title and metadata
                div(class: "") {
                    h1 { page.metadata.title }
                    
                    if let description = page.metadata.description {
                        p(class: "") { description }
                    }
                }
                
                // Changelog section if present

                // Main content
                switch page.body {
                case .markdown(let md):
                    md.fromMarkdown
                case .pieces(let pieces):
                    pieces.render(prefix: page.url)
                }

                metadata

                if let changelog = page.metadata.changelog, !changelog.isEmpty {
                    div(class: "") {
                        details {
                            summary(class: "") {
                                "Version History (\(changelog.count) updates)"
                            }

                            div(class: "") {
                                Node.fragment(changelog.reversed().map { entry in
                                    div(class: "") {
                                        time(class: "", datetime: entry.date) {
                                            PostDate(string: entry.date).dateString
                                        }
                                        span { entry.summary }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    @NodeBuilder var metadata: HTML.Node {
        div(class: "metadata") {
            span {
                span(class: "key") {
                    "Created: "
                }
                time(datetime: page.metadata.created) {
                    page.createdDate.dateString
                }
            }

            if let u = page.metadata.updated, let d = page.updatedDate {
                span {
                    span(class: "key") {
                        "Last updated: "
                    }
                    time(datetime: u) {
                        d.dateString
                    }
                }
            }
        }
    }

    
    @NodeBuilder var authorAndDate: HTML.Node {
        address {
            span {
                span { "By " }
                a(href: "/about/", rel: "author") { "Chris Eidhof" }
            }
            
            span {
                " – "
                time(datetime: page.metadata.updated) {
                    page.lastModifiedDate.date.pretty(style: .dayMonthYear)
                }
            }
        }
    }
}
