//

import Foundation
import StaticSite
import HTML


struct Presentation {
    var title: String
    var date: PostDate
    var location: String
    var conferenceName: String
    var conferenceLink: URL?
    var sourcePDF: String
}

extension Presentation {
    static let all: [Presentation] = [
        .init(title: "A Day in the Life of a SwiftUI View", date: .init(year: 2023, month: 08, day: 12), location: "Toronto, Canada", conferenceName: "SwiftConf.to", sourcePDF: "2023-08-11-swiftto.pdf")
    ]
}

struct Presentations: Rule {
    var body: some Rule {
        ForEach(Presentation.all) { presentation in
            PresentationRule(presentation: presentation)
        }
    }
}

import PDFKit

struct PresentationRule: Rule {
    var presentation: Presentation

    var body: some Rule {
        let filename = String(presentation.sourcePDF.dropLast(4))
//        let _ = print(filename)
//        let _ = print(Bundle.module.resourcePath!)
        let url = Bundle.module.url(forResource: .init(presentation.sourcePDF.dropLast(4)), withExtension: "pdf")!
        let document = PDFDocument(url: url)!
        ForEach(Array(0..<document.pageCount)) { ix in
            let img = document.image(page: ix)
            // todo render as png
        }
//        fatalError()
    }
}

extension PDFDocument {
    func image(page: Int) -> NSImage {
        NSImage(data: self.page(at: page)!.dataRepresentation!)!
    }
}

