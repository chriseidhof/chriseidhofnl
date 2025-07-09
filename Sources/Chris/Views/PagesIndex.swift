import Foundation
import HTML
import Helpers

struct PagesIndex {
    let pages: [Page]
    
    @NodeBuilder var body: HTML.Node {
        article {
            div(class: "prose max-w-none") {
                h1 { "Pages" }
                
                p(class: "text-lg text-gray-600") {
                    "Living documents that evolve over time. These pages are regularly updated with new insights, corrections, and improvements."
                }
                
                if pages.isEmpty {
                    p(class: "text-gray-500 italic") {
                        "No pages available yet."
                    }
                } else {
                    div(class: "space-y-6 mt-8") {
                        Node.fragment(pages.map { page in
                            pageCard(page)
                        })
                    }
                }
            }
        }
    }
    
    @NodeBuilder func pageCard(_ page: Page) -> HTML.Node {
        div(class: "border rounded-lg p-6 hover:shadow-lg transition-shadow") {
            h2(class: "text-xl font-semibold mb-2") {
                a(class: "hover:underline", href: page.url) {
                    page.metadata.title
                }
            }
            
            if let description = page.metadata.description {
                p(class: "text-gray-600 mb-3") { description }
            }
            
            div(class: "flex flex-wrap gap-4 text-sm text-gray-500") {
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
                    span(class: "text-blue-600") {
                        "\(changelog.count) revision\(changelog.count == 1 ? "" : "s")"
                    }
                }
            }
        }
    }
    
}
