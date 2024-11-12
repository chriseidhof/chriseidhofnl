import Foundation
import StaticSite
import HTML

struct Notes: Rule {
    var body: some Rule {
        WriteNode(outputName: "index.html", node: Note.all.index())
            .outputPath("notes")
        ForEach(Note.all) { snippet in
            WriteNode(outputName: "index.html", node: snippet.page)
                .outputPath(snippet.link)
        }
    }
}

extension Array where Element == Note {
    func index() -> Node {
        p {
            "TODO"
        }
        /*
        ul {
            map { snippet in
                a(href: snippet.link) {
                    li {
                        snippet.name
                    }
                }
            }
        }
         */
    }
}

extension Note {
    @NodeBuilder var page: Node {
        b { "Please don't share this, it's an unpublished note" }
        div(class: "post") {
            body.fromMarkdown
        }

    }
}

struct Note {
    var name: String
    var body: String

    var link: String {
        "/notes/\(name)"
    }
}

extension Note {
    static var all: [Note] = {
        let files = try! baseEnvironment.allFiles(at: "notes")
        return files.map { f in
            let body: String = try! baseEnvironment.read("notes/\(f)")
            let name = (f as NSString).deletingPathExtension
            return Note(name: name, body:  body)
        }
    }()
}
