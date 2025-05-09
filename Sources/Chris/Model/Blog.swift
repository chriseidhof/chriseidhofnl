//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

import Foundation
import StaticSite
import Yams
import HTML

extension BlogPost {
    static let otherPosts: [BlogPost] = [
        variadicViews,
        semanticColors,
        weeknotes15,
        safeArea,
        viewRepresentable,
        avoidGroups,
        alignmentGuides,
    ]
}

extension BlogPost {
    var bodyNode: HTML.Node {
        switch body {
        case .markdown(let s): return s.fromMarkdown
        case .pieces(let n): return n.render(prefix: link)
        }
    }
    var feedItem: FeedItem {
        FeedItem(link: link, title: metadata.title, description: bodyNode.render(xml: false), date: date.date)
    }
}


struct WriteOrUseCache: Rule {
    @Environment(\.cache) private var cache
    @Environment(\.relativeOutputPath) private var relativeOutputPath

    var outputName: String
    var data: () -> Data

    var body: some Rule {
        let c = cache!
        let r = relativeOutputPath!
        let url = c.appendingPathComponent(r).appendingPathComponent(outputName)
        let exists = FileManager.default.fileExists(atPath: url.path)
        if exists {
            let theData = try! Data(contentsOf: url)
            Write(outputName: outputName, data: theData)
        } else {
            let theData = (try? Data(contentsOf: url)) ?? data()
            Write(outputName: outputName, data: theData)
        }
    }
}

import CryptoKit

extension BlogPost {
    var shareImageName: String {
        let digest = Insecure.MD5.hash(data: shareImageHashValue.data(using: .utf8)!)
        let hex: String = digest.map {
            String(format: "%02hhx", $0)
        }.joined()
        return "og-image-\(hex.prefix(4)).png"

    }
    var shareImageLink: String {
        (link as NSString).appendingPathComponent(shareImageName)
    }

    @MainActor @RuleBuilder var shareImageRule: some Rule {
        WriteOrUseCache(outputName: shareImageName, data: { shareImage })
    }

    @MainActor @RuleBuilder var generateImages: some Rule {
        switch body {
        case .markdown(_):
            EmptyRule()
        case .pieces(let pieces):
            ForEach(Array(pieces.enumerated())) { (ix, piece) in
                AnyBuiltin(any: piece.generateImages(id: ix))
            }
        }
    }
}

struct Blog: Rule {
    let posts: [BlogPost.InContext]
    let unpublished: [BlogPost]

    var recent: [BlogPost] {
        Array(posts.map { $0.post }.prefix(5))
    }

    @MainActor
    @RuleBuilder func postAndShareImage(_ post: BlogPost.InContext) -> some Rule {
        WithEnvironment { env in // this is ugly but I couldn't get it to work otherwise
            DispatchQueue.main.sync {
                try! post.post.shareImageRule.builtin.run(environment: env)
                if case .pieces = post.post.body {
                    try! post.post.generateImages.builtin.run(environment: env)
                }
            }
        }
        .outputPath(post.post.link)
        WriteNode(outputName: "index.html", node: post.page)
            .title(post.post.metadata.title + (post.post.metadata.published == false ? " (Unpublished)" : ""))
            .environment(keyPath: \.openGraphImage, value: post.post.shareImageLink)
            .outputPath(post.post.link)
    }

    @MainActor
    @RuleBuilder var body: some Rule {
        WriteNode(outputName: "archive/index.html", node:
            posts.map { $0.post }.groupedByYear()
        )
        .title("Archive")
        ForEach(posts) { post in
            postAndShareImage(post)
        }
        ForEach(unpublished) { post in
            postAndShareImage(.init(post: post))
        }
        WriteNode(outputName: "index.xml", node: feed, xml: true)
            .resetTemplates()
    }
    
    var feed: AtomFeed {
        AtomFeed(destination: "index.xml", title: "Chris Eidhof", absoluteURL: "http://chris.eidhof.nl", description: "Personal Blog", items: BlogPost.feed.map { $0.feedItem
        })
    }
}

struct PostDate: Equatable {
    var year: Int
    var month: Int
    var day: Int

    static let df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        return df
    }()

    static let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .ordinal
        return nf
    }()
}

extension PostDate: Comparable {
    static func <(l: PostDate, r: PostDate) -> Bool {
        if l.year < r.year { return true }
        if r.year < l.year { return false }
        if l.month < r.month { return true }
        if r.month < l.month { return false }
        return l.day < r.day
    }
}

extension PostDate {
    init(string: String) {
        let components = string.prefix(10).split(separator: "-").prefix(3).map { Int($0)! }
        year = components[0]
        month = components[1]
        day = components[2]
    }
    
    var date: Date {
        let components = DateComponents(year: year, month: month, day: day)
        return NSCalendar.current.date(from: components)!
    }
    
    var dateString: String {
        let monthName = Self.df.string(from: date)
        let dayOrdinal = Self.nf.string(from: NSNumber(value: day))!
        return "\(monthName) \(dayOrdinal), \(year)"
    }
}

enum PostBody {
    case markdown(String)
    case pieces([any PostPiece])
}

struct BlogPost {
    var metadata: Metadata
    var body: PostBody
    var date: PostDate {
        PostDate(string: metadata.date)
    }
    var updateDate: PostDate? {
        metadata.updatedAt.map { PostDate(string: $0) }
    }
    
    var outputName: String {
        link + "/index.html"
    }
    
    var link: String
    
    var isAdvancedSwift: Bool {
        metadata.advanced_swift ?? false
    }
    
    var published: Bool {
        return metadata.published ?? true
    }
 
    struct Metadata: Codable, Equatable, Hashable {
        var headline: String?
        var title: String
        var date: String
        var updatedAt: String?
        var aliases: [String]?
        var advanced_swift: Bool?
        var published: Bool?
    }

}

extension BlogPost {
    static let all: [BlogPost] = {
        loadPosts(path: "posts") { file, _ in
            PostDate(string: file)
        } buildLinkName: { filename in
            let name = (filename as NSString).deletingPathExtension
            return "/post/\(name)"
        }
    }()

    static var published: [BlogPost] {
        return all.filter { $0.published }
    }
    
    static var feed: [BlogPost] {
        return Array(published.prefix(20))
    }
    
    static var homePage: [BlogPost] {
        return Array(published.prefix(5))
    }
}

extension String {
    var isMarkdown: Bool {
        let ext = (self as NSString).pathExtension
        return ["md", "markdown"].contains(ext)
    }
}

func loadPosts(path: String, buildDate: (_ filename: String, _ metadata: BlogPost.Metadata) -> PostDate, buildLinkName: (String) -> String) -> [BlogPost] {
    let files = try! baseEnvironment.allFiles(at: path).filter { $0.isMarkdown }
    let decoder = YAMLDecoder()
    let parsed = try! files.map { file -> BlogPost in
        let s: String = try baseEnvironment.read(path + "/" + file)
        let (yaml, contents) = try! s.parseMarkdownWithFrontMatter()
        let meta: BlogPost.Metadata = try decoder.decode(from: yaml!)
        return BlogPost(metadata: meta, body: .markdown(contents), link: buildLinkName(file))
    }
    let all = parsed + BlogPost.otherPosts
    return all.sorted(by: { $0.date < $1.date }).reversed()
}

extension BlogPost {
    struct InContext {
        var previous: BlogPost?
        var post: BlogPost
        var next: BlogPost?
    }
    
    static func publishedInContext() -> [InContext] {
        let all = self.all.filter { $0.published }
        return all.indices.map { i in
            InContext(previous: i > 0 ? all[i-1] : nil , post: all[i], next: i + 1 < all.endIndex ? all[i + 1] : nil)
        }
    }

    static func unpublishedInContext() -> [BlogPost] {
        self.all.filter { !$0.published }
    }
}
