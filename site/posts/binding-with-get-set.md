---
date: 2025-03-21
title: "Bindings"
headline: Not all Bindings are created equal
---

In SwiftUI, there are two *kinds* of bindings. There are bindings created using keypaths, and then there are bindings created using `Binding(get:set:)`. These are not the same at all.

For example, consider the following (contrived) view:

```swift
struct ContentView: View {
    @State var value1 = false
    @State var value2 = false
    var body: some View {
        VStack {
            Toggle("Test", isOn: $value1)
            Nested(value2: $value2)
        }
    }
}
```

When we change either `value1` or `value2`, the `body` of `ContentView` will re-render. This is expected. However, we only want `Nested` to re-render its body when `value2` changes, not when `value1` changes. 

Under the hood, SwiftUI looks at the `Nested` value in the attribute graph and compares it against the new value of `Nested` that we're constructing above. If these are "the same", it will not re-render the body of `Nestedima`. It is not documented how this comparison works, but Javier [found out some things](https://swiftui-lab.com/equatableview/) and there are some old tweets by SwiftUI team members. SwiftUI compares the old and new view on a field-by-field basis, and only if all fields are the same, it stops re-rendering.

In the example above, SwiftUI can do this comparison, and indeed, the `body` of `Nested` will not be re-rendered unless the actual value of `value2` changed.

## Manual Binding Problems

Instead of writing `$value2`, we could have also constructed a *manual binding* using `Binding(get: { value2 }, set: { value2 = $0 })`. This has a different behavior: every time `ContentView` re-renders its body, `Nested` will re-render its body as well. Even when only `value1` changes. While we don't have access to the SwiftUI source code, I think the problem is that these manual bindings store closures instead of a "pointer" to the state value. Every time the body of `ContentView` executes, a new closure is constructed. Swift cannot compare closures and thus SwiftUI needs to re-render the body of `Nested`.

While the above is a contrived example (no one would write `Binding(get:set:)` instead of `$value2`) the distinction between binding types becomes important when creating member bindings. For example, in [SwiftUI Binding Tricks](/post/swiftui-binding-tricks/) we look at creating a binding of `Bool` from a state property of type `Set`. While it might be easier to write this using a `Binding(get:set:)` we do create a potential efficiency trap. When you write something like `$selection[contains: element]` a binding with a keypath is constructed, and SwiftUI can compare these kinds of bindings effectively. At least one of the companies we've worked with has documentation and warnings in place because using `Binding(get:set:)` caused way too many view body redraws.

## Conclusion

I think we should avoid `Binding(get:set:)` in production code. In most cases, you will probably not see a big difference in performance, but it can come back to bite you. With some practice, bindings using key paths rather than `Binding(get:set:)` are just as easy to write and often simplify testing.

## References

- Jacob Van Order wrote an article where he [measures the different approaches](https://jacobvanorder.github.io/swiftui-bindings-digging-a-little-deeper/) using the SwiftUI Instruments templates. 
