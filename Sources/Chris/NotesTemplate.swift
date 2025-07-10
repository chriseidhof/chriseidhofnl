import StaticSite
import HTML

struct NotesTemplate: Template {
    @NodeBuilder
    func run(content: Node) -> Node {
        h1 {
            a(href: "/note") { "Notes" }
        }
        content
    }
    
}
