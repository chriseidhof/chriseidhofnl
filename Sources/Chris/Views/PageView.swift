import Foundation
import HTML
import Helpers

struct PageView {
    let page: Page
    
    @NodeBuilder var body: HTML.Node {
        article {
            div(class: "prose max-w-none") {
                // Page header with title and metadata
                div(class: "mb-8 border-b pb-6") {
                    h1 { page.metadata.title }
                    
                    if let description = page.metadata.description {
                        p(class: "text-lg text-gray-600 mt-2") { description }
                    }
                    
                    // Version information
                    div(class: "flex flex-wrap gap-4 text-sm text-gray-500 mt-4") {
                        span {
                            "Created: "
                            time(datetime: page.metadata.created) {
                                page.createdDate.dateString
                            }
                        }

                        if let u = page.metadata.updated, let d = page.updatedDate {
                            span {
                                "Last updated: "
                                time(datetime: page.metadata.updated) {
                                    d.dateString
                                }
                            }
                        }
                    }
                }
                
                // Changelog section if present
                if let changelog = page.metadata.changelog, !changelog.isEmpty {
                    div(class: "mb-8 bg-gray-50 p-4 rounded-lg") {
                        details {
                            summary(class: "cursor-pointer font-semibold") {
                                "Version History (\(changelog.count) updates)"
                            }
                            
                            div(class: "mt-4 space-y-2") {
                                Node.fragment(changelog.reversed().map { entry in
                                    div(class: "flex gap-4 text-sm") {
                                        time(class: "text-gray-500 min-w-[100px]", datetime: entry.date) {
                                            PostDate(string: entry.date).dateString
                                        }
                                        span { entry.summary }
                                    }
                                })
                            }
                        }
                    }
                }
                
                // Main content
                switch page.body {
                case .markdown(let md):
                    md.fromMarkdown
                case .pieces(let pieces):
                    pieces.render(prefix: page.url)
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
