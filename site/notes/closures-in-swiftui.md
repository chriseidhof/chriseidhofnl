---
title: "Closures in SwiftUI"
created: 2025-07-10
---

Main pages: 

- [Attribute Graph](/note/attribute-graph) 
- [Attribute Graph in SwiftUI](/note/attribute-graph-in-swiftui).
- [SwiftUI View Equality](/note/swiftui-view-equality).

In general, closures cannot be compared for equality. This can cause unnecessary view invalidations. For example, consider the view below. Instead of passing `value` as an `Int` we pass a closure that computes the `Int`. Every time the `unrelated` state property changes, the `Nested` body is recomputed (we can see this because of the color change). If we pass the `value` as an `Int` instead, the recompution doesn't happen.

```swift
struct Nested: View {
    var value: () -> Int

    var body: some View {
        Text("Value: \(value())")
            .background(Color(hue: .random(in: 0...1), saturation: 0.8, brightness: 0.8))
    }
}

struct ContentView: View {
    @State var value = 0
    @State var unrelated = 0

    var body: some View {
        VStack {
            Nested(value: { value })
            Button("Unrelated: \(unrelated)") {
                unrelated += 1
            }
        }
    }
}
```

In practice, this might not be a big deal for most views, but it could be something to keep in mind if you're seeing more invalidations than expected.

SwiftUI itself doesn't typically pass functions through the environment. Instead, it uses [defunctionalization](/note/defunctionalization) to pass a value that implements [`callAsFunction`](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations/#Methods-with-Special-Names). This is done by e.g. [`DismissAction`](https://developer.apple.com/documentation/swiftui/dismissaction/callasfunction()), [`RefreshAction`](https://developer.apple.com/documentation/swiftui/refreshaction/callasfunction()) and [`OpenWindowAction`](https://developer.apple.com/documentation/swiftui/openwindowaction).

Another option if you need to pass closures down the environment is to use a (stable) object. The identity of the object doesn't change and SwiftUI won't need to rerender views because of this.

SwiftUI itself could have been modeled as view functions rather than `View` structs. Instead, [views are defunctionalized](http://localhost:8000/note/swiftui-views-are-functions/) to be able to compare for equality.
