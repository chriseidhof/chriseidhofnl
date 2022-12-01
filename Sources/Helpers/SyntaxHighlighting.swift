import Foundation
import SwiftSyntax
import SwiftSyntaxParser
import HTML
import Swim
import StaticSite

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

class SwiftSyntaxHighlighter: SyntaxRewriter {
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

    override func visit(_ token: TokenSyntax) -> Syntax {
        write(trivia: token.leadingTrivia)
        switch token.tokenKind {
        case .floatingLiteral, .integerLiteral:
            html.append("<span class=\"hljs-number\">\(token.text)</span>")
        case _ where token.tokenKind.isKeyword:
            html.append("<span class=\"hljs-keyword\">\(token.text)</span>")
        case .identifier:
            html.append("<span class=\"hljs-identifier\">\(token.text)</span>")
        case .rawStringDelimiter, .stringSegment, .stringLiteral, .stringQuote, .multilineStringQuote:
            html.append("<span class=\"hljs-string\">\(token.text)</span>")
        default:
            html.append(token.text)
//
//        case .eof:
//            <#code#>
//        case .leftParen:
//            <#code#>
//        case .rightParen:
//            <#code#>
//        case .leftBrace:
//            <#code#>
//        case .rightBrace:
//            <#code#>
//        case .leftSquareBracket:
//            <#code#>
//        case .rightSquareBracket:
//            <#code#>
//        case .leftAngle:
//            <#code#>
//        case .rightAngle:
//            <#code#>
//        case .period:
//            <#code#>
//        case .prefixPeriod:
//            <#code#>
//        case .comma:
//            <#code#>
//        case .ellipsis:
//            <#code#>
//        case .colon:
//            <#code#>
//        case .semicolon:
//            <#code#>
//        case .equal:
//            <#code#>
//        case .atSign:
//            <#code#>
//        case .pound:
//            <#code#>
//        case .prefixAmpersand:
//            <#code#>
//        case .arrow:
//            <#code#>
//        case .backtick:
//            <#code#>
//        case .backslash:
//            <#code#>
//        case .exclamationMark:
//            <#code#>
//        case .postfixQuestionMark:
//            <#code#>
//        case .infixQuestionMark:
//            <#code#>
//        case .stringQuote:
//            <#code#>
//        case .singleQuote:
//            <#code#>
//        case .multilineStringQuote:
//            _
//        case .unknown(_):
//            <#code#>
//
//        case .unspacedBinaryOperator(_):
//            <#code#>
//        case .spacedBinaryOperator(_):
//            <#code#>
//        case .postfixOperator(_):
//            <#code#>
//        case .prefixOperator(_):
//            <#code#>
//        case .dollarIdentifier(_):
//            <#code#>
//        case .contextualKeyword(_):
//            <#code#>
//        case .stringInterpolationAnchor:
//            <#code#>
//        case .yield:
//            <#code#>
        }
        write(trivia: token.trailingTrivia)
        return Syntax(token)
    }
}

extension String {
    public var highlightedAsSwift: String {
        do {
            let parsed = try SyntaxParser.parse(source: self)
            let highlighter = SwiftSyntaxHighlighter()
            _ = highlighter.visit(parsed)
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
