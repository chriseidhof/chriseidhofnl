+++
date = "2016-08-12"
headline = "Conforming to the Collection protocol"
title = "Protocols in Swift"
advanced_swift = true

+++

Let's say we are writing our own data-structure, a singly linked list:

```swift
enum ListNode<A> {
    case end
    indirect case cons(A, ListNode)
}
```

Today's goal is to make `ListNode` conform to the `Collection` protocol. It's actually fairly easy, but it's almost impossible to figure it out by just looking at the types. The documentation tells us which methods to implement, but why is it like that? Even though the protocol is clearly specified, it's not so easy to see what you need to do. Let's give it a try without looking at the documentation, and see what the compiler tells us:


```swift
extension ListNode: Collection { }
```

The compiler tells us we don't conform to the following three protocols: `Sequence`, `IndexableBase`, and `Collection`. 

Looking at all these protocols, you might get overwhelmed. The most complicated one, `Collection`, comes in at a whopping four associated types, two subscripts, four computed properties and seven methods. A protocol is a formal "todo-list" of all the things your type needs to do in order to conform. I copy/pasted this from the Standard Library, and removed all the documentation comments. With the documentation comments, it gets even harder to see!

```swift
public protocol Collection : Indexable, Sequence {
    associatedtype IndexDistance : SignedInteger = Int
    associatedtype Iterator : IteratorProtocol = IndexingIterator<Self>
    associatedtype SubSequence : IndexableBase, Sequence = Slice<Self>
    associatedtype Indices : IndexableBase, Sequence = DefaultIndices<Self>
    public subscript(position: Self.Index) -> Self.Iterator.Element { get }
    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence { get }
    public var indices: Self.Indices { get }
    public var isEmpty: Bool { get }
    public var count: Self.IndexDistance { get }
    public var first: Self.Iterator.Element? { get }
    public func makeIterator() -> Self.Iterator
    public func prefix(upTo end: Self.Index) -> Self.SubSequence
    public func suffix(from start: Self.Index) -> Self.SubSequence
    public func prefix(through position: Self.Index) -> Self.SubSequence
    public func index(_ i: Self.Index, offsetBy n: Self.IndexDistance) -> Self.Index
    public func index(_ i: Self.Index, offsetBy n: Self.IndexDistance, limitedBy limit: Self.Index) -> Self.Index?
    public func distance(from start: Self.Index, to end: Self.Index) -> Self.IndexDistance
}
```

The interesting thing is: all associated types have default values. So if we decide to stick with them, we can cross those off of the todo-list, and fill the other parameters with their types:

```swift
public protocol Collection : Indexable, Sequence {
    public subscript(position: Self.Index) -> IndexingIterator<Self>.Element { get }
    public subscript(bounds: Range<Self.Index>) -> Slice<Self> { get }
    public var indices: DefaultIndices<Self> { get }
    public var isEmpty: Bool { get }
    public var count: Int { get }
    public var first: IndexingIterator<Self>.Element? { get }
    public func makeIterator() -> IndexingIterator<Self>
    public func prefix(upTo end: Self.Index) -> Slice<Self>
    public func suffix(from start: Self.Index) -> Slice<Self>
    public func prefix(through position: Self.Index) -> Slice<Self>
    public func index(_ i: Self.Index, offsetBy n: Int) -> Self.Index
    public func index(_ i: Self.Index, offsetBy n: Int, limitedBy limit: Self.Index) -> Self.Index?
    public func distance(from start: Self.Index, to end: Self.Index) -> Int
}
```


Many of the properties and methods have default implementations as well. For example, here are the default extensions on `Collection`:

```swift
extension Collection {
    public func map<T>(_ transform: @noescape (Self.Iterator.Element) throws -> T) rethrows -> [T]
    public func dropFirst(_ n: Int) -> Self.SubSequence
    public func dropLast(_ n: Int) -> Self.SubSequence
    public func prefix(_ maxLength: Int) -> Self.SubSequence
    public func suffix(_ maxLength: Int) -> Self.SubSequence
    public func prefix(upTo end: Self.Index) -> Self.SubSequence
    public func suffix(from start: Self.Index) -> Self.SubSequence
    public func prefix(through position: Self.Index) -> Self.SubSequence
    public func split(maxSplits: Int = default, omittingEmptySubsequences: Bool = default, whereSeparator isSeparator: @noescape (Self.Iterator.Element) throws -> Bool) rethrows -> [Self.SubSequence]
    public func index(where predicate: @noescape (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Index?
}

extension Collection {
    public var isEmpty: Bool { get }
    public var first: Self.Iterator.Element? { get }
    public var underestimatedCount: Int { get }
    public var count: Self.IndexDistance { get }
}
```

These default extensions allow us to cross the `prefix` and `suffix` methods off of our list. Our todo-list is now a bit shorter:

```swift
public protocol Collection : Indexable, Sequence {
    public subscript(position: Self.Index) -> IndexingIterator<Self>.Element { get }
    public subscript(bounds: Range<Self.Index>) -> Slice<Self> { get }
    public var indices: DefaultIndices<Self> { get }
    public func makeIterator() -> IndexingIterator<Self>
    public func index(_ i: Self.Index, offsetBy n: Int) -> Self.Index
    public func index(_ i: Self.Index, offsetBy n: Int, limitedBy limit: Self.Index) -> Self.Index?
    public func distance(from start: Self.Index, to end: Self.Index) -> Int
}
```

There are more extensions that apply, though. For example:

```swift
extension Collection where SubSequence == Slice<Self> {
    public subscript(bounds: Range<Self.Index>) -> Slice<Self> { get }
}
extension Collection where Indices == DefaultIndices<Self> {
    public var indices: DefaultIndices<Self> { get }
}
extension Collection where Iterator == IndexingIterator<Self> {
    public func makeIterator() -> IndexingIterator<Self>
}
```

Because all three apply, we can get rid of three more todos. Our list is getting shorter.

```swift
public protocol Collection : Indexable, Sequence {
    public subscript(position: Self.Index) -> IndexingIterator<Self>.Element { get }
    public func index(_ i: Self.Index, offsetBy n: Int) -> Self.Index
    public func index(_ i: Self.Index, offsetBy n: Int, limitedBy limit: Self.Index) -> Self.Index?
    public func distance(from start: Self.Index, to end: Self.Index) -> Int
}
```

If we start adding the `Indexable` requirements to our todo-list, we end up with a long list again. We now also need to conform to IndexableBase.

```swift
public protocol Collection : IndexableBase, Sequence {
    public subscript(position: Self.Index) -> IndexingIterator<Self>.Element { get }
    public func index(_ i: Self.Index, offsetBy n: Int) -> Self.Index
    public func index(_ i: Self.Index, offsetBy n: Int, limitedBy limit: Self.Index) -> Self.Index?
    public func distance(from start: Self.Index, to end: Self.Index) -> Int
    associatedtype Index : Comparable
    public var startIndex: Self.Index { get }
    public var endIndex: Self.Index { get }
    public subscript(position: Self.Index) -> Self._Element { get }
    associatedtype SubSequence
    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence { get }
    public func index(after i: Self.Index) -> Self.Index
    public func formIndex(after i: inout Self.Index)
}
```

However, after removing all default implementations that are provided by collection, and using all extension that apply to our current protocol, we can cross out almost all the newly added `Indexable` requirements (many have a default implementation). We can keep playing the game of looking at the extensions, crossing out requirements, adding new ones, until we finally end up with a minimal set of things we need to do:

```swift
public protocol Collection {
    associatedtype Index : Comparable
    public var startIndex: Self.Index { get }
    public var endIndex: Self.Index { get }
    public func index(after i: Self.Index) -> Self.Index
    public subscript(position: Self.Index) -> Element { get }
}
```

Lo and behold, we can make `ListNode` conform:

```swift
extension ListNode: Collection {
    var startIndex: Int { return 0 }
    /// This is 0(n), not the expected O(1) from `Collection`.
    var endIndex: Int {
        switch self {
        case .end: return 0
        case .cons(_, let tail): return 1 + tail.endIndex
        }
    }
    func index(after: Int) -> Int {
        return after+1
    }
    /// This is 0(n), not the expected O(1) from `Collection`.
    subscript(position: Int) -> A {
        switch (self, position) {
        case (.end, _): fatalError("Index out of bounds")
        case (.cons(let x, _), 0): return x
        case (.cons(_, let tail), _): return tail[position-1]
        }
    }
}
```

Note that we didn't have to specify the `associatedtype`, the compiler inferred this for us.

Long story short: it's really hard to see what you need to conform to. Or to be more precise: it's not that hard, it's just a *lot* of manual work. Luckily, all of this can be completely automated. Unfortunately, the tooling in this respect is currently still very immature, even though the standard library isn't. I have no idea if this will improve soon.

Rather than waiting for Apple to fix this, maybe someone in the community could do this? I imagine it's a few days of hard work: first you need to parse all the protocols in the standard library (or better: use SourceKit, because then you can also make it work on your own protocols). Then you need to have some kind of evaluation system that checks which extensions can be applied. It might need to be interactive, for example, once you specify that the `Index` associated type will be an `Int`, it could tell you what you still need to implement. 

I'd love to build this myself, however, I'm currently too busy writing the update of [Advanced Swift](https://www.objc.io/books/advanced-swift/), and preparing new [Swift Talk episodes](https://talk.objc.io). It would be the perfect procrastination project...

Update: Nicola [writes in](https://twitter.com/NSalmoria/status/764158023124258817) that "Conforming to the Collection Protocol" is actually a section of the [API documentation](https://developer.apple.com/reference/swift/collection). Very good point. He also raises the point that my `endIndex` and `subscript` implementations aren't `O(1)`, which is the expected complexity as described in the `Collection` protocol.
