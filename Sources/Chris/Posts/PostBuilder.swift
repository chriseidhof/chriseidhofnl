import SwiftUI
import HTML
import Helpers

//@PieceBuilder
//fileprivate var myPostBody: [PostPiece] {
//    "This *is* a test".fromMarkdown.piece
//    HStack {
//        Text("Test")
//        Circle()
//            .fill(Color.green)
//            .frame(width: 50, height: 50)
//    }.foregroundColor(.white).embed()
//    "More text".fromMarkdown.piece
//    Text("Hello, world")
//        .font(.title)
//        .foregroundColor(.green)
//        .embed()
//}

let otherPosts: [BlogPost] = [
    variadicViews
]

enum PostPiece {
    case node(Node)
    case markdown(String)
    case swiftUI(AnyView, size: ProposedViewSize = .unspecified)
}

extension String {
    var markdownPiece: PostPiece {
        return .markdown(self)
    }
}

extension Array where Element == PostPiece {
    func render(prefix: String) -> Node {
        var counter = -1
        var state = FState()

        return .fragment(map { el in
            switch el {
            case .node(let n): return n
            case .markdown(let m):
                return m.markdownWithSeparateFootnotes(state: &state)
            case .swiftUI:
                counter += 1
                return p {
                    picture(class: "swiftui") {
                        source(media: "(prefers-color-scheme: dark)", srcset: prefix + "/\(counter)-dark.png 2x")
                        img(srcset: prefix + "/\(counter).png 2x", style: "width: auto;")
                    }
                }
            }
        } + [state.rendered])
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
