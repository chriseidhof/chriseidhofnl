//
//  File.swift
//  
//
//  Created by Chris Eidhof on 06.01.23.
//

import Foundation
import StaticSite

struct WithEnvironment: BuiltinRule, Rule {
    let child: (EnvironmentValues) -> ()
    init(child: @escaping (EnvironmentValues) -> ()) {
        self.child = child
    }

    func run(environment: EnvironmentValues) throws {
        child(environment)
    }
}
