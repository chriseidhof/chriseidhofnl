//
//  File.swift
//  
//
//  Created by Chris Eidhof on 10.02.23.
//

import Foundation
import SwiftUI

extension BlogPost {
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
        }.render(size: .unspecified, colorScheme: .dark)
    }
}
