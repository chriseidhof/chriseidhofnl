import SwiftUI
import HTML
import Helpers
import StaticSite


protocol PostPiece {
    associatedtype R: Rule
    func render(state: inout FState, id: Int, prefix: String) -> Node
    func renderMarkdown(id: Int, prefix: String) -> String
    @MainActor @RuleBuilder func generateImages(id: Int) -> R
}

extension PostPiece {
    @MainActor @RuleBuilder func generateImages(id: Int) -> some Rule {
        EmptyRule()
    }

    func renderMarkdown(id: Int, prefix: String) -> String {
        ""
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

    func renderMarkdown(id: Int, prefix: String) -> String {
        contents
    }
}

extension Node: PostPiece {
    func render(state: inout FState, id: Int, prefix: String) -> Node {
        self
    }

    func renderMarkdown(id: Int, prefix: String) -> String {
        render(xml: false)
    }
}

extension Array where Element == any PostPiece {
    func render(prefix: String) -> Node {
        var state = FState()
        return .fragment(enumerated().map { ix, el in
            el.render(state: &state, id: ix, prefix: prefix)
        } + [state.rendered])
    }

    func renderMarkdown(prefix: String) -> String {
        enumerated()
            .map { ix, el in el.renderMarkdown(id: ix, prefix: prefix).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }
}

@resultBuilder
enum PieceBuilder {
    static func buildBlock(_ components: (any PostPiece)...) -> [any PostPiece] {
        Array(components)
    }
}
