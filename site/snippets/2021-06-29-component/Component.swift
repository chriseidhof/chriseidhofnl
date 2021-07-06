// A component is similar to a SwiftUI `View`

public protocol Component {
    associatedtype Result: Component
    var body: Result { get }
}

// Never is a component as well (the builtin components will have this as their `Result`)

extension Never: Component {
    public typealias Result = Never
    public var body: Never { fatalError("This should never happen") }
}

// This is straight from SwiftUI, except that we require values to be hashable.

public protocol PreferenceKey {
     associatedtype Value: Hashable
     static var defaultValue: Value { get }
     static func reduce(value: inout Value, nextValue: () -> Value)
 }

// A private protocol that all the built-in components conform to. Note that this does not have an associated type, which means we'll be able to dynamically cast to it.

protocol BuiltinComponent {
    func render() -> Node
    func readPreference<Key: PreferenceKey>(key: Key.Type) -> Key.Value?
}

// We should make this work so that we can take any user-defined component and use it as if it were a builtin component.

struct AnyBuiltinComponent: BuiltinComponent {
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        fatalError("TODO")
    }
    
    func render() -> Node {
        fatalError("TODO")
    }
}

// These are defaults so that we can easily conform builtin components to `Component`

extension BuiltinComponent {
    public typealias Result = Never
    public var body: Never { fatalError("This should never happen") }
}

// Swim nodes are components

extension Node: Component & BuiltinComponent {
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        return nil
    }
    func render() -> Node {
        self
    }
}
