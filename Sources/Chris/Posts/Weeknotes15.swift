import SwiftUI
import HTML
import StaticSite

let weeknotes15 = BlogPost(metadata: .init(headline: "Book Layout", title: "Weeknotes № 15", date: "2023-04-16"), body: .pieces(myPostBody), link: "/post/2023-15")

@PieceBuilder
fileprivate var myPostBody: [any PostPiece] {
    Markdown("""
    In Germany everyone gets time off for easter, and we spent time with friends and family. We also planted a bunch more things, really looking forward to summer where we'll have a lot of fresh vegetables. We're trying out a bunch of new things, so excited to see how well everything goes. The spinach, salad and onions are cropping up already.

    I worked on getting our book building software up to date. There are many dependencies (rendering using attributed strings, drawing diagrams, our own layout implementation to help generate explanations, and so on). We were still depending on an internal version of [attributed-string-builder](https://github.com/objcio/attributed-string-builder) which was essentially an extend subset of the public repository.

    I configured everything to (hopefully) be a very low-friction experience. I set up single Xcode project with virtually all code in Swift packages. For editing, we can just drop the package into the Xcode project and have a local editable version.

    While we wrote the book using Dropbox Paper, we now are typesetting it using attributed strings. All of our previous published books were typeset using a mix of homegrown scripts, Pandoc, LaTeX and a bunch of other stuff. We always had the full setup working on at least one machine, but we decided to try a different setup for this release.

    I also worked on a simple "connecting the dots" view to draw lines between arbitrary views in the view hierarchy. This works by propagating the center of each of the icons up (using anchors), and then drawing lines between all the connections. This technique is useful beyond this example, of course:
    """)

    SwiftUIView {
        DirectionList(padding: 10)
            .cornerRadius(5)
            .frame(width: 300, height: 145)
    }
    Markdown("""
    I'll try to either write this up as a blog post or we'll record it for Swift Talk.
    """)
}

struct DirectionItem: Identifiable {
    var id = UUID()
    var icon: Image
    var text: String
}

let sample: [DirectionItem] = [
    .init(icon: Image(systemName: "location.circle.fill"), text: "My Location"),
    .init(icon: Image(systemName: "pin.circle.fill"), text: "Berlin Hauptbahnhof"),
    .init(icon: Image(systemName: "pin.circle.fill"), text: "Westend")
]

extension Sequence {
    func withPrevious() -> [(previous: Element?, item: Element)] {
        var previous: Element? = nil
        return map { el in
            let result = (previous, el)
            previous = el
            return result
        }
    }
}

struct IconFrames: PreferenceKey {
    static let defaultValue: [UUID: Anchor<CGRect>] = [:]
    static func reduce(value: inout [UUID : Anchor<CGRect>], nextValue: () -> [UUID : Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct ContentView: View {
    @State var padding: CGFloat = 5
    var body: some View {
        VStack {
            Slider(value: $padding, in: 0...10)
            DirectionList(padding: padding)
        }
    }
}

struct VerticalDots: Shape {
    var dotSize = CGSize(width: 3, height: 3)
    func path(in rect: CGRect) -> Path {
        let spacing: CGFloat = 2
        return Path { p in
            let numDots = floor(rect.height / (dotSize.height + spacing))
            var totalDotHeight = numDots * dotSize.height + (numDots-1) * spacing
            var pos: CGPoint = .init(x: (rect.width-dotSize.width)/2, y: (rect.height - totalDotHeight)/2)
            for i in 0..<Int(numDots) {
                p.addEllipse(in: .init(origin: pos, size: dotSize))
                pos.y += dotSize.height
                pos.y += spacing
            }
        }
    }
}

struct DottedLine: View {
    var from: CGPoint
    var to: CGPoint

    var body: some View {
        let x = min(from.x, to.x)
        let y = min(from.y, to.y)
        VerticalDots()
            .padding(.vertical, 0)
            .frame(width: 10, height: abs(to.y-from.y))
            .offset(x: x-5, y: y)

    }
}

struct Line: View {
    var from: CGPoint
    var to: CGPoint

    var body: some View {
        let x = min(from.x, to.x)
        let y = min(from.y, to.y)
        Rectangle()
            .frame(width: 1, height: abs(to.y-from.y))
            .offset(x: x, y: y)
    }
}

extension CGRect {
    subscript(unitPoint: UnitPoint) -> CGPoint {
        var result = origin
        result.x += unitPoint.x * width
        result.y += unitPoint.y * height
        return result
    }
}

extension View {
    func propagateIconFrame(id: UUID) -> some View {
        anchorPreference(key: IconFrames.self, value: .bounds, transform: { [id: $0] })
    }
}

extension View {
    func drawIconFrames() -> some View {
        overlayPreferenceValue(IconFrames.self) { frames in
            GeometryReader { proxy in
                ForEach(sample.withPrevious(), id: \.item.id) { (previous, item) in
                    if let p = previous, let from = frames[p.id], let to = frames[item.id] {
                        DottedLine(from: proxy[from][.bottom], to: proxy[to][.top])
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct DirectionList: View {
    var padding: CGFloat = 5
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(sample.withPrevious(), id: \.item.id) { (previous, item) in
                let even = sample.firstIndex(where: { $0.id == item.id })!.isMultiple(of: 2)
                HStack {
                    item.icon
                        .propagateIconFrame(id: item.id)
                        .frame(width: 50)
                    Text(item.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, padding)
                .background {
                    if even {
                        Color.primary.opacity(0.1)
                    }
                }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .drawIconFrames()
    }
}
