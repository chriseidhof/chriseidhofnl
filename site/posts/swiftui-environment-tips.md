---
date: 2023-02-08
title: "SwiftUI Environment Tips"
headline: Precise Updates
---

In our [SwiftUI workshop](https://www.objc.io/workshops/) we always include an exercise where you learn about how the environment works. Often, we build some kind of stylesheet that gets passed down the environment, from the root view. The stylesheet could look like this:

```swift
struct Stylesheet {
    var buttonColor: Color = .blue
    var cardColor: Color = .primary.opacity(0.1)
}
```

In a child view, we then read and use the stylesheet (you'll also have to add an environment key for this to work):

```swift
struct Nested1: View {
    @Environment(\.stylesheet) private var stylesheet
    var body: some View {
        Text("Hello")
            .background(stylesheet.buttonColor)
    }
}
```

In the above view, the code works fine, but we could also write it using a more specific key path:

```swift
struct Nested2: View {
    @Environment(\.stylesheet.buttonColor) private var buttonColor
    var body: some View {
        Text("Hello")
            .background(buttonColor)
    }
}
```

This technique is useful when you have nested types (e.g. typically a stylesheet has more than just two colors, and might be composed out of other structs). There's a *performance advantage* as well: when anything in the stylesheet changes, `Nested1` will be rerendered. `Nested2`, however, will only get rerendered whenever the `buttonColor` property changes. This can make a big difference performance-wise (although often it doesn't matter).

You can also use this with other properties — even computed properties. For example:

```swift
struct Nested3: View {
    @Environment(\.dynamicTypeSize.isAccessibilitySize) 
    private var isAccesibilitySize
    
    var body: some View {
        // ...
    }
}

```

Another thing you might notice in the code samples above is that we marked our environment property as `private`. We always do this for Environment, State, StateObject as well as ScaledMetric. These properties are populated just before the body renders, and it makes no sense to expose them to the outside. We even have a very crude [swiftlint rule](https://gist.github.com/chriseidhof/d8c079ca97099a6122f37890a144e9b0) for this.
