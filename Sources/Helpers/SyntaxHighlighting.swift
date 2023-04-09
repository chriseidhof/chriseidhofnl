import Foundation
import SwiftSyntax
import HTML
import Swim
import StaticSite
import SwiftParser

struct Highlighter: Visitor {
    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        guard name == "code", attributes["class"] == "swift", let c = child else {
            return .element(name, attributes, child.map { visitNode($0) })
        }
        
        return .element(name, attributes, HighlightAllText().visitNode(c))
    }
}

struct HighlightAllText: Visitor {
    func visitText(text: String) -> Node {
        .raw(text.highlightedAsSwift)
    }
}

extension TriviaPiece {
    var isComment: Bool {
        switch self {
        case .lineComment, .blockComment, .docLineComment, .docBlockComment:
            return true
        default:
            return false
        }
    }
}

class SwiftSyntaxHighlighter: SyntaxVisitor {
    var html: String = ""
    
    func write(trivia: Trivia) {
        for piece in trivia {
            if piece.isComment {
                html.append("<span class=\"hljs-comment\">")
            }
            piece.write(to: &html)
            if piece.isComment {
                html.append("</span>")
            }
        }
    }

    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        write(trivia: token.leadingTrivia)
        switch token.tokenKind {
        case .floatingLiteral, .integerLiteral:
            html.append("<span class=\"hljs-number\">\(token.text)</span>")
        case _ where token.tokenKind.isLexerClassifiedKeyword:
            html.append("<span class=\"hljs-keyword\">\(token.text)</span>")
        case .identifier:
            html.append("<span class=\"hljs-identifier\">\(token.text)</span>")
        case .rawStringDelimiter, .stringSegment, .stringQuote, .multilineStringQuote:
            html.append("<span class=\"hljs-string\">\(token.text)</span>")
        default:
            html.append(token.text)
        }
        write(trivia: token.trailingTrivia)
        return .visitChildren
    }
}

extension String {
    public var highlightedAsSwift: String {
        do {
            let parsed = try Parser.parse(source: self)
            let highlighter = SwiftSyntaxHighlighter(viewMode: .all)
            highlighter.walk(parsed)
            return highlighter.html
        } catch {
            print(error)
            return self
        }
    }
}


let highlighter = Highlighter()
public func highlight(_ env: EnvironmentValues, node: Node) -> Node {
    highlighter.visitNode(node)
}
