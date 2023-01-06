////
////  File.swift
////
////
////  Created by Chris Eidhof on 17.06.21.
////
//
import Foundation
import HTML
import Markdown

let linkPrefix = "fnref"
let refPrefix = "fnref-rev"

struct FootnoteState {
    var counter: Int = 1
    var notes: [Int:String] = [:]
}

// Todo: it would be really nice to replace this with symbols: https://en.wikipedia.org/wiki/Note_(typography)

extension String {
    func replacingFootnoteLinks(state: inout FootnoteState) -> Node {
        let pattern = "(\\[\\^(.*?)\\])([^:]|$)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = (self as NSString)
        var matches: [(number: Int, range: Range<String.Index>, label: String)] = []
        regex.enumerateMatches(in: self, options: [], range: NSRange(startIndex..<endIndex, in: self)) { result, flags, pointer in
            let range = result!.range(at: 1)
            let label = nsString.substring(with: result!.range(at: 2))
            matches.append((number: state.counter, range: Range(range, in: self)!, label: label))
            state.notes[state.counter] = label
            state.counter += 1
        }
        guard !matches.isEmpty else { return asNode() }

        var result: [Node] = []
        var start = self.startIndex
        for match in matches {
            result.append(String(self[start..<match.range.lowerBound]).asNode())
            result.append(.raw("<sup><a href=\"#\(linkPrefix)\(match.label)\" name=\"\(refPrefix)\(match.label)\">\(match.number)</a></sup>"))
            start = match.range.upperBound
        }
        if start < endIndex {
            result.append(.text(String(self[start..<endIndex])))
        }
        return .fragment(result)
    }

    func findFootnoteDefinition() -> (label: String, markerRange: Range<String.Index>)? {
        let pattern = "^\\[\\^(.*?)\\]: "
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = (self as NSString)
        guard let result = regex.firstMatch(in: self, options: [], range: NSRange(startIndex..<endIndex, in: self)) else { return nil }
        let label = nsString.substring(with: result.range(at: 1))
        return (label: label, markerRange: Range(result.range(at: 0), in: self)!)
    }
}

typealias Definitions = [String: [InlineMarkup]]

struct CollectDefinitions: MarkupRewriter {
    var definitions: Definitions = [:]
    mutating func visitParagraph(_ paragraph: Paragraph) -> Markup? {
        guard paragraph.childCount > 0,
              var t = paragraph.child(at: 0) as? Text,
              let (label, range) = t.string.findFootnoteDefinition() else {
            return paragraph
        }
        t.string.removeSubrange(range)
        definitions[label] = [t] + Array(paragraph.inlineChildren.dropFirst())
        return nil
    }
}

struct AddInlineLinks: MarkupRewriter {
    var state = FootnoteState()

    mutating func visitText(_ text: Text) -> Markup? {
        var result = ""
        text.string.replacingFootnoteLinks(state: &state).write(to: &result)
        return Markdown.InlineHTML(result)
    }
}

extension String {
    public func markdownWithFootnotes() -> HTML.Node {
        let doc = Document(parsing: self)
        var rewriter = CollectDefinitions()
        var result = rewriter.visit(doc) ?? doc

        guard !rewriter.definitions.isEmpty else {
            return result.toNode()
        }

        var a = AddInlineLinks()
        result = a.visit(result) ?? result
        let node = result.toNode()
        let footnotes = div(class: "footnotes") {
            hr()
            ol {
                a.state.notes.keys.sorted().map { key -> HTML.Node in
                    let label = a.state.notes[key]!
                    guard var paragraphChildren: [InlineMarkup] = rewriter.definitions[label] else {
                        fatalError("No definition for footnote \(label)")
                    }
                    paragraphChildren.append(Text(" "))
                    paragraphChildren.append(Link(destination: "#\(refPrefix)\(label)", [Text("↩")]))
                    return li(id: "\(linkPrefix)\(label)") {
                        Paragraph(paragraphChildren).toNode()
                    }
                }
            }
        }
        return .fragment([node, footnotes])
    }
}
