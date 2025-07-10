import Foundation
import StaticSite
import Yams
import HTML

struct Note {
    var slug: String

    struct Metadata: Codable {
        let title: String
        let created: String
        let updated: String?
        let changelog: [ChangeEntry]?
        let published: Bool?
        let description: String?
    }
    
    struct ChangeEntry: Codable {
        let date: String
        let summary: String
    }
    
    enum Body {
        case markdown(String)
        case pieces([any PostPiece])
    }
    
    let metadata: Metadata
    let body: Body
    let url: String
    
    var isPublished: Bool {
        metadata.published ?? true
    }
    
    var createdDate: PostDate {
        PostDate(string: metadata.created)
    }
    
    var updatedDate: PostDate? {
        metadata.updated.map{ PostDate(string: $0) }
    }
    
    var lastModifiedDate: PostDate {
        updatedDate ?? createdDate
    }
}

extension Note {
    init?(file: String, url: String, slug: String) throws {
        let (yaml, markdown) = try file.parseMarkdownWithFrontMatter()
        guard let data = yaml else { return nil }
        let decoder = YAMLDecoder()
        self.metadata = try decoder.decode(Metadata.self, from: data)
        self.url = url
        self.slug = slug
        self.body = .markdown(markdown)
    }
    
    var bodyNode: HTML.Node {
        switch body {
        case .markdown(let s): return s.fromMarkdown
        case .pieces(let n): return n.render(prefix: url)
        }
    }
    
    @NodeBuilder var page: HTML.Node {
        NoteView(page: self).body
    }
}

func loadNotes(in dir: URL) throws -> [Note] {
    let fm = FileManager.default
    let pagesDir = dir.appendingPathComponent("notes")

    guard fm.fileExists(atPath: pagesDir.path) else {
        return []
    }
    
    let files = try fm.contentsOfDirectory(at: pagesDir, includingPropertiesForKeys: nil)
        .filter { $0.pathExtension == "md" }
    
    return try files.compactMap { file in
        let contents = try String(contentsOf: file, encoding: .utf8)
        let slug = file.deletingPathExtension().lastPathComponent
        let url = "/note/\(slug)/"
        return try Note(file: contents, url: url, slug: slug)
    }
}

struct Notes: Rule {
    let pages: [Note]
    
    var body: some Rule {
        // Generate index
        WriteNode(outputName: "index.html", node: NotesIndex(pages: publishedPages).body)
            .title("Notes")
        
        // Generate all notes page (alphabetically sorted)
        WriteNode(outputName: "index.html", node: AllNotesIndex(pages: pages).body)
            .outputPath("all")
            .title("All Notes")
        
        // Generate individual pages
        ForEach(pages.filter(\.isPublished)) { page in
            WriteNode(outputName: "index.html", node: page.page)
                .outputPath(page.slug)
                .title(page.metadata.title)
        }
    }
    
    var publishedPages: [Note] {
        pages.filter(\.isPublished).sorted { p1, p2 in
            p1.lastModifiedDate > p2.lastModifiedDate
        }
    }
}
