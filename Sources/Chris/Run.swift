import StaticSite
import HTML
import Foundation

struct Site: Rule {
    var body: some Rule {
        Copy("css")
        Copy("fonts")
        Copy("images")
        Index()
        Blog(posts: BlogPost.inContext())
        Snippets()
        Write(outputName: "CNAME", data: "chris.eidhof.nl".data(using: .utf8)!)
        // TODO: aliases
    }
}

let fm = FileManager.default
let basePath = URL(fileURLWithPath: fm.currentDirectoryPath)
let siteOutputPath = basePath.appendingPathComponent("docs")
let baseEnvironment = EnvironmentValues(inputBaseURL: basePath.appendingPathComponent("site"), outputBaseURL: siteOutputPath)

func recreateBuildDir() throws {
    let fm = FileManager.default
    if fm.fileExists(atPath: siteOutputPath.path) {
        try fm.removeItem(atPath: siteOutputPath.path)
        try fm.createDirectory(at: siteOutputPath, withIntermediateDirectories: true, attributes: nil)
    }
}

let highlighter = Highlighter()
func highlight(_ env: EnvironmentValues, node: Node) -> Node {
    highlighter.visitNode(node)
}

extension Rule {
    func applyTransform(_ f: @escaping (EnvironmentValues, Node) -> Node) -> some Rule {
        modifyEnvironment(keyPath: \.transformNode, modify: { g in
            let old = g
            g = { env, node in f(env, old(env, node)) }
        })
    }
}

public func run() throws {
    try recreateBuildDir()
    try Site()
        .wrap(Main())
        .applyTransform(highlight)
        .applyTransform(recordLinks)
        .measure()
        .builtin
        .run(environment: baseEnvironment)
    print(checkLocalLinks(outputPath: siteOutputPath.path))
}
