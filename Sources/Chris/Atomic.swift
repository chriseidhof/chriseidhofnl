//
//  File.swift
//  
//
//  Created by Chris Eidhof on 06.07.21.
//

import Foundation

final class Atomic<A> {
    private let queue = DispatchQueue(label: "Atomic serial queue")
    private var _value: A

    init(_ value: A) {
        self._value = value
    }

    var value: A {
        get { return queue.sync { self._value } }
    }

    func mutate(_ transform: (inout A) -> ()) {
        queue.sync { transform(&self._value) }
    }
}
