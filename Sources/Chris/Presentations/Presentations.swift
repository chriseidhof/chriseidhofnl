//

import Foundation
import StaticSite
import HTML
import RegexBuilder

struct Presentation {
    var title: String
    var link: String
    var date: PostDate
    var location: String
    var conferenceName: String
    var conferenceLink: URL?
    var sourcePDF: String
    var transcript: String
}

extension Presentation {
    static let all: [Presentation] = [
        .init(title: "A Day in the Life of a SwiftUI View", link: "day-in-the-life", date: .init(year: 2023, month: 08, day: 12), location: "Toronto, Canada", conferenceName: "SwiftConf.to", conferenceLink: URL(string: "https://www.swiftconf.to")!, sourcePDF: "2023-08-11-swiftto.pdf", transcript: "swiftto.md")
    ]
}

extension Presentation {
    @NodeBuilder func page(path: String) -> Node {
        let markdown: String = try! baseEnvironment.read("presentations/\(transcript)")
        article(class: "post presentation") {
            header {
                h1 { title }
                // todo
                p {
                    date.dateString
                    "•"
                    location
                    "•"
                    if let u = conferenceLink {
                        a(href: u.absoluteString) { conferenceName }
                    } else {
                        conferenceName
                    }
                }
//                if let h = metadata.headline {
//                    h2(class: "headline") { h }
//                }
            }
            section(class: "postbody") {
                markdown
                    .replaceSlidePlaceholders(path: path)
                    .markdownWithFootnotes()
            }
//            footer
        }
    }
}

extension String {
    func replaceSlidePlaceholders(path: String) -> Self {
        let regex = Regex {
            "<"
            Capture { OneOrMore(.digit) }
            ">"
          }
        return replacing(regex) { match in
            let page = Int(match.output.1)!
            return "![](\(path)/\(page-1).png)"
        }
    }

}

struct Presentations: Rule {
    var body: some Rule {
        ForEach(Presentation.all) { presentation in
            PresentationRule(presentation: presentation)
                .outputPath(presentation.link)
        }
        .outputPath("presentations")
    }
}

import PDFKit

struct PresentationRule: Rule {
    var presentation: Presentation
    @Environment(\.relativeOutputPath) var relativeOutputPath

    var body: some Rule {
        let filename = String(presentation.sourcePDF.dropLast(4))
        let url = Bundle.module.url(forResource: .init(filename), withExtension: "pdf")!
        let document = PDFDocument(url: url)!
        ForEach(Array(0..<document.pageCount)) { ix in
            WriteOrUseCache(outputName: "\(ix).png", data: {
                let img = document.image(page: ix).bitmap()
                return img.representation(using: .png, properties: [:])!
            })
        }
        WriteNode(outputName: "index.html", node: presentation.page(path: relativeOutputPath!))
            .title(presentation.title)
//            .environment(keyPath: \.openGraphImage, value: post.post.shareImageLink)
    }
}

extension NSImage {
    func bitmap() -> NSBitmapImageRep {
        let i = NSImage(size: self.size, flipped: false) { rect in
            self.draw(in: rect)
            return true
        }
        let rep = NSBitmapImageRep(data: i.tiffRepresentation!)
        return rep!
    }
}

extension PDFDocument {
    func image(page: Int) -> NSImage {
        NSImage(data: self.page(at: page)!.dataRepresentation!)!
    }
}

