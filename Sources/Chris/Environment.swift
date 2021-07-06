//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

import Foundation
import StaticSite
import Swim

struct ExtraFooterContent: EnvironmentKey {
    static var defaultValue: Node? = nil
}

extension EnvironmentValues {
    var extraFooterContent: Node? {
        get {
            self[ExtraFooterContent.self]
        }
        set {
            self[ExtraFooterContent.self] = newValue
        }
    }
}

extension Rule {
    func extraFooterContent(_ node: Node) -> some Rule {
        self.environment(keyPath: \.extraFooterContent, value: node)
    }
}

extension EnvironmentValues {
    var relativeOutputPath: String {
        let prefix = siteOutputPath.path
        let urlString = output.path
        assert(urlString.hasPrefix(prefix))
        return String(urlString.dropFirst(prefix.count))
    }
}
