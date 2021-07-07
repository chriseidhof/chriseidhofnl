//
//  File.swift
//  
//
//  Created by Chris Eidhof on 17.06.21.
//

import Foundation
import CommonMark
import HTML

let linkPrefix = "fnref"
let refPrefix = "fnref-rev"

struct FootnoteState {
    var counter: Int = 1
    var notes: [Int:String] = [:]
}

extension String {
    func replacingFootnoteLinks(state: inout FootnoteState) -> [Inline] {
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
        guard !matches.isEmpty else { return [.text(text: self)] }
        
        var result: [Inline] = []
        var start = self.startIndex
        for match in matches {
            result.append(.text(text: String(self[start..<match.range.lowerBound])))
            result.append(.html(text: "<sup><a href=\"#\(linkPrefix)\(match.label)\" name=\"\(refPrefix)\(match.label)\">\(match.number)</a></sup>"))
            start = match.range.upperBound
        }
        if start < endIndex {
            result.append(.text(text: String(self[start..<endIndex])))
        }
        return result
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

extension String {
    public func markdownWithFootnotes() -> HTML.Node {
        let node = Node(markdown: self)
        var state = FootnoteState()
        var definitions: [String:[Inline]] = [:]
        var result = node.elements
        result = result.deepApply({ (block: Block) in
            guard case let .paragraph(p) = block else { return [block] }
            guard case var .text(t) = p.first else { return [block] }
            if let (label, range) = t.findFootnoteDefinition() {
                t.removeSubrange(range)
                definitions[label] = [.text(text: t)] + p.dropFirst()
                return []
            } else {
                return [block]
            }
        })
        result = result.deepApply( { (inline: Inline) -> [Inline] in
            guard case let .text(t) = inline else { return [inline] }
            return t.replacingFootnoteLinks(state: &state)
        })
        var fragment = [
            result.asNode()
        ]
        if !state.notes.isEmpty {
            fragment.append(div(class: "footnotes") {
                hr()
                ol {
                    state.notes.keys.sorted().map { key -> HTML.Node in
                        let label = state.notes[key]!
                        guard var paragraphChildren: [Inline] = definitions[label] else {
                            fatalError("No definition for footnote \(label)")
                        }
                        paragraphChildren.append(.text(text: " "))
                        paragraphChildren.append(.link(children: [.text(text: "↩")], title: nil, url: "#\(refPrefix)\(label)"))
                        return li(id: "\(linkPrefix)\(label)") {
                            HTML.Node.raw(Node(blocks: [.paragraph(text: paragraphChildren)]).html(options: .unsafe))
                        }
                    }
                }
            }
            )
        }
        return fragment.asNode()
    }
}
