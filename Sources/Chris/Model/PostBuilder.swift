import SwiftUI
import HTML
import Helpers
import StaticSite


protocol PostPiece {
    associatedtype R: Rule
    func render(state: inout FState, id: Int, prefix: String) -> Node
    @MainActor @RuleBuilder func generateImages(id: Int) -> R
}

extension PostPiece {
    @MainActor @RuleBuilder func generateImages(id: Int) -> some Rule {
        EmptyRule()
    }
}

struct Markdown: PostPiece {
    init(_ contents: String) {
        self.contents = contents
    }

    var contents: String

    func render(state: inout FState, id: Int, prefix: String) -> Node {
        return contents.markdownWithSeparateFootnotes(state: &state)
    }
}

extension Node: PostPiece {
    func render(state: inout FState, id: Int, prefix: String) -> Node {
        self
    }
}

extension Array where Element == any PostPiece {
    func render(prefix: String) -> Node {
        var state = FState()
        return .fragment(enumerated().map { ix, el in
            el.render(state: &state, id: ix, prefix: prefix)
        } + [state.rendered])
    }
}

@resultBuilder
enum PieceBuilder {
    static func buildBlock(_ components: (any PostPiece)...) -> [any PostPiece] {
        Array(components)
    }
}
