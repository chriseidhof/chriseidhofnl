---
date: 2024-01-07
title: "SwiftUI Binding Tips"
headline: Leverage Dynamic Member Lookup
---

When working with bindings in SwiftUI, it can be useful to modify bindings. For example, in a Slack I'm part of, someone had a binding to a Boolean and wanted to negate it. This was (roughly) the code they had:

```swift
extension Binding where Value == Bool {
    func toggled() -> Self {
        Self(
            get: {
                !wrappedValue
            },
            set: { newValue in
                wrappedValue = !newValue
            }
        )
    }
}
```

While the code works great, it always feels a bit cumbersome to write. There's a simpler way to achieve this. We can start by creating a computed property on `Bool` that's both `get` and `set`:

```swift
extension Bool {
    var flipped: Self {
        get { !self }
        set { self = !newValue }
    }
}
```

Because `Binding` supports dynamic member lookup, we can use our `flipped` property directly where we use our binding:

```swift
$myBinding.flipped
```

We've also used this pattern sometimes when projecting into a binding. For example, let's imagine we want to display a control that enables us to select edges. Our state looks like this:

```swift
@State private var edges: Set<Edge> = [Edge.top, Edge.bottom]
```

If we want to enable and disable a specific edge through a `Toggle`, we'll need to turn the binding from a `Set<Edge>` into a `Bool` binding. We can again achieve this using dynamic member lookup, but this time through a subscript:

```swift
extension Set {
    subscript(contains el: Element) -> Bool {
        get { contains(el) }
        set {
            if newValue {
                insert(el)
            } else {
                remove(el)
            }
        }
    }
}
```

Now we can write `$edges[contains: .top]` or `$edges[contains: .bottom]` and get a `Bool` binding out. The reason why we need a `subscript` is that dynamic member lookup uses key paths, and both subscripts and computed properties can be part of key paths. A regular method cannot be part of a key path. While the technique is a little obscure, I still find it easier to read than writing all that logic inside a custom binding.

In general, I much prefer components that take a `Binding` over components that observe all kinds of complicated view models, global stores or other things. They are easier to test and reuse and don't require complicated architectures. Hopefully the two tricks above help you turn the bindings that you have into the bindings that you need.

> **Update**: [Stephen Celis](https://hachyderm.io/@stephencelis) writes in:
>
> Another reason to prefer properties + dynamic member look up instead of constructing ad-hoc bindings is that ad-hoc bindings tend to break SwiftUI animation. Even if you do all the right stuff with the transaction, there is something weird deep in SwiftUI that causes an ad-hoc binding to be handed transactions with all animation info stripped away.

> **Update (2025)**: The method described in this article is [more efficient](/post/binding-with-get-set/) than creating bindings with `Binding(get:set:)`.
