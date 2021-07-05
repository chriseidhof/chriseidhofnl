//
//  File.swift
//
//
//  Created by Chris Eidhof on 29.06.21.
//

import Foundation

extension Never: Component {
    public typealias Result = Never
    public var body: Never { fatalError("This should never happen") }
}

public protocol Component {
    associatedtype Result: Component
    var body: Result { get }
}

public protocol PreferenceKey {
     associatedtype Value: Hashable
     static var defaultValue: Value { get }
     static func reduce(value: inout Value, nextValue: () -> Value)
 }

// A private protocol
protocol BuiltinComponent {
    func render() -> Node
    func readPreference<Key: PreferenceKey>(key: Key.Type) -> Key.Value?
}

struct AnyBuiltinComponent: BuiltinComponent {
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        fatalError("TODO")
    }
    
    func render() -> Node {
        fatalError("TODO")
    }
}

extension BuiltinComponent {
    public typealias Result = Never
    public var body: Never { fatalError("This should never happen") }
}

extension Node: Component & BuiltinComponent {
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        return nil
    }
    func render() -> Node {
        self
    }
}
