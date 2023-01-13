//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

import Chris
import Foundation

@main
struct Program {
    static func main() async throws {
        DispatchQueue.global().async {
            try! run()
            exit(EXIT_SUCCESS)
        }
        RunLoop.main.run()
    }
}
