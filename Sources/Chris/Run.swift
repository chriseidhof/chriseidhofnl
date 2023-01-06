import StaticSite
import HTML
import Foundation
import Helpers

struct Site: Rule {
    var body: some Rule {
        Copy("css")
        Copy("images")
        Copy(from: "well-known", to: ".well-known")
        Index()
        AboutMe().outputPath("about")
        Blog(posts: BlogPost.inContext())
        Snippets()
        Write(outputName: ".nojekyll", data: Data())
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
    let p = siteOutputPath.path
    if fm.fileExists(atPath: p) {
        for c in try fm.contentsOfDirectory(atPath: p) {
            try fm.removeItem(atPath: (p as NSString).appendingPathComponent(c))
        }
    } else {
        try fm.createDirectory(at: siteOutputPath, withIntermediateDirectories: true, attributes: nil)
    }
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

    // Start workaround, for some reason `applyTransform` crashes with EXC_BAD_ACCESS (Xcode 13.3)
    var copy = baseEnvironment
    copy.transformNode = { env, node in
        recordLinks(env.relativeOutputPath, highlight(env, node: node))
    }
    // End workaround

    try Site()
        .wrap(Main())
//        .applyTransform(highlight)
//        .applyTransform(recordLinks)
        .measure()
        .builtin
        .run(environment: copy)
    checkLocalLinks(outputPath: siteOutputPath.path)
}
