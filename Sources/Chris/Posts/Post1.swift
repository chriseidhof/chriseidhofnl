import SwiftUI
import HTML

let myPost = BlogPost(metadata: .init(title: "My title", date: "2023-01-06"), body: .pieces(myPostBody), link: "/post/my-title")

@PieceBuilder
var myPostBody: [PostPiece] {
    "This *is* a test".fromMarkdown.piece
    HStack {
        Text("Test")
        Circle()
            .fill(Color.green)
            .frame(width: 50, height: 50)
    }.foregroundColor(.white).embed()
    "More text".fromMarkdown.piece
    Text("Hello, world")
        .font(.title)
        .foregroundColor(.green)
        .embed()
}

let otherPosts: [BlogPost] = [
]

enum PostPiece {
    case node(Node)
    case swiftUI(AnyView, size: ProposedViewSize = .unspecified)
}

extension Array where Element == PostPiece {
    func render(prefix: String) -> Node {
        var counter = -1
        return .fragment(map { el in
            switch el {
            case .node(let n): return n
            case .swiftUI:
                counter += 1
                return img(srcset: prefix + "/\(counter).png 2x", style: "width: auto;")
            }
        })
    }
}

extension Node {
    var piece: PostPiece { .node(self) }
}

extension View {
    func embed(size: ProposedViewSize = .unspecified) -> PostPiece {
        .swiftUI(AnyView(self), size: size)
    }
}

@resultBuilder
enum PieceBuilder {
    static func buildBlock(_ components: PostPiece...) -> [PostPiece] {
        Array(components)
    }
}
