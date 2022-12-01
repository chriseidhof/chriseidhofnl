import Foundation
import StaticSite
import HTML

struct Snippets: Rule {
    var body: some Rule {
        WriteNode(outputName: "index.html", node: Snippet.all.index())
            .outputPath("snippets")
        ForEach(Snippet.all) { snippet in
            WriteNode(outputName: "index.html", node: snippet.page)
                .outputPath(snippet.link)
        }
    }
}

extension Array where Element == Snippet {
    func index() -> Node {
        ul {
            map { snippet in
                a(href: snippet.link) {
                    li {
                        snippet.name
                    }
                }
            }
        }
    }
}

extension Snippet {
    @NodeBuilder var page: Node {
        if let intro = files["index.md"] {
            div(class: "post") {
                intro.fromMarkdown
            }
        }
        
        div {
            files.keys.filter { $0 != "index.md" }.sorted().map { filename -> Node in
                let `class` = filename.hasSuffix("swift") ? "swift": nil
                return div(class: "snippet") {
                    h3 {
                        filename
                    }
                    pre {
                        %code(class: `class`) {
                            files[filename]!
                        }%
                    }
                }
            }
        }
    }
}

struct Snippet {
    var name: String
    var files: [String: String]
    
    var link: String {
        "/snippets/\(name)"
    }
}

extension Snippet {
    static var all: [Snippet] = {
        let files = try! baseEnvironment.allFiles(at: "snippets")
        return files.map { f in
            let snippetFiles = try! baseEnvironment.allFiles(at: "snippets/\(f)")
            let dict = snippetFiles.map { s -> (String, String) in
                return (s, try! baseEnvironment.read("snippets/\(f)/\(s)"))
            }
            return Snippet(name: f, files: Dictionary(uniqueKeysWithValues: dict))
        }
    }()
}
