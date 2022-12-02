import Minilog
import StaticSite
import HTML
import Swim
import Foundation
import Helpers

// todo don't hardcode the minilog path here!

extension EnvironmentValues {
    func load() throws -> Model {
        let data: Data = try read("log/log.json")
        let decoder = JSONDecoder()
        return try decoder.decode(Model.self, from: data)
    }
}


public struct Minilog: Rule {
    @Environment(\.self) var env
    public init() { }

    public var body: some Rule {
        let model = try! env!.load()
        Index(model: model)
    }
}

struct Index: Rule {
    var model: Model
    @Environment(\.relativeOutputPath) var relativePath

    var body: some Rule {
        WriteNode(outputName: "index.html", node:
                    model.publicPosts.indexList(basePath: relativePath!)
        ).title("Minilog")
        Posts(model: model)
    }
}

struct Posts: Rule {
    var model: Model

    @Environment(\.relativeOutputPath) var relativePath

    var body: some Rule {
        ForEach(model.publicPosts) { post in
            WriteNode(outputName: post.outputName, node: post.page(basePath: relativePath!))
        }
    }
}

extension Post {
    var outputName: String { "\(id)/index.html" }
    func link(basePath: String) -> String {
        (basePath as NSString).appendingPathComponent(id.uuidString)
    }
}

extension Post {
    @NodeBuilder func page(basePath: String) -> Node {
        [self].list(basePath: basePath)

        HTML.footer {
            a(href: basePath) {
                span(class: "arrow") {
                    "←"
                }
            }
        }
    }
    func node(basePath: String) -> Node {
        li { // todo shouldn't be li as the root
            a(href: link(basePath: basePath)) {
                aside(class: "dates") {
                    createdAt.pretty(style: .dateTime)
                }

            }
            contents.map { (p: Piece) -> Node in
                switch p.contents {
                case .image(_):
                    return "TODO"
                case .markdown(let m):
                    return m.markdownWithFootnotes()
                }
            }
        }
    }
}

extension Array where Element == Post {

    @NodeBuilder
    func indexList(basePath: String) -> Node {
        div(class: "intro") {
            """
            This is my minilog. Kind of like a weblog, but shorter, quicker and with less of a filter.
            """
        }
        list(basePath: basePath)
    }

    @NodeBuilder
    func list(basePath: String) -> Node {
        ul(id: "log-list") {
            self.map { post in post.node(basePath: basePath) }
        }
    }
}
