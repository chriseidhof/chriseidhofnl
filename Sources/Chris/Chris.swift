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
        // TODO: aliases
    }
}

let fm = FileManager.default
let path = URL(fileURLWithPath: fm.currentDirectoryPath)
let out = path.appendingPathComponent("_build")
let baseEnvironment = EnvironmentValues(inputBaseURL: path.appendingPathComponent("site"), outputBaseURL: out)

func recreateBuildDir() throws {
    let fm = FileManager.default
    if fm.fileExists(atPath: out.path) {
        try fm.removeItem(atPath: out.path)
        try fm.createDirectory(at: out, withIntermediateDirectories: true, attributes: nil)
    }
}

public func run() throws {
    try recreateBuildDir()
    try Site()
        .wrap(Main())
        .measure()
        .builtin
        .run(environment: baseEnvironment)
}
