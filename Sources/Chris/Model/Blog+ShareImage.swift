//
//  File.swift
//  
//
//  Created by Chris Eidhof on 10.02.23.
//

import Foundation
import SwiftUI

extension BlogPost {
    var shareImageHashValue: String {
        // ugly but works
        metadata.title + (metadata.headline ?? "nil") + ""
    }

    @MainActor
    var shareImage: Data {
        ShareImage {
            DefaultShareImageContents {
                Text(metadata.title)
            } subtitle: {
                if let h = metadata.headline {
                    Text(h)
                }
            }
        }.render(size: .unspecified, colorScheme: .light)
    }
}

