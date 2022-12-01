//
//  File.swift
//  
//
//  Created by Chris Eidhof on 06.07.21.
//

import Foundation
import HTML
import StaticSite

// This will only work for a single build! Don't try to do multiple builds as it won't reset.
fileprivate var allLinks: Atomic<[String: [String]]> = Atomic([:])

public func checkLocalLinks(outputPath: String) {
    let fm = FileManager.default
    for (page, links) in allLinks.value {
        for link in links {
            if link.contains("://") || link.hasPrefix("//") || link.hasPrefix("#") || link.hasPrefix("mailto") {
                continue
            } else {
                if fm.fileExists(atPath: (outputPath as NSString).appendingPathComponent(link)) {
                    continue
                }
                print("Broken link: \(page): \(link)")
            }
        }
    }
}

public func recordLinks(_ outputPath: String, _ node: Node) -> Node {
    LinkVisitor(outputName: outputPath).visitNode(node)
    return node
}

// This list is from https://github.com/gohugoio/hugo/blob/master/transform/urlreplacers/absurlreplacer.go
fileprivate let linkAttributes = [
    "src",
    "href",
    "url",
    "action",
    "srcset"
]

struct LinkVisitor: Visitor {
    var outputName: String
    
    func visitElement(name: String, attributes: [String : String], child: Node?) -> () {
        if let c = child { visitNode(c) }
        
        for a in linkAttributes {
            if let link = attributes[a] {
                assert(a != "srcset", "TODO")
                allLinks.mutate { prev in
                    prev[outputName, default: []].append(link)
                }
            }
        }
    }
}
