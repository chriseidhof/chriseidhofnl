---
date: 2023-01-25
title: "SwiftUI Views are Lists"
headline: The View Protocol Has A Misleading Name
---

When you write SwiftUI, all your views conform to the `View` protocol. The name of this protocol is a bit misleading: I it could be called `Views` or `ViewList`, or something else that suggests plurals.

For example, consider the following view:

```swift
struct MyView: View {
     var body: some View {
         Text("Hello")
         Text("World")
     }
}
```

The type of `body` is `some View` (an opaque type), and `MyView` itself conforms to the `View` protocol. So how does the above view render? *It depends*. When you create an `HStack` containing `MyView`, the text will be on a single line, but when you create a `VStack` the two texts will be below each other. Try this!

This is not a gimmick: it is essential to how SwiftUI works. When we write views, we're always constructing *lists of views*. For example, we could even do something like this:

```swift
struct MyOtherView: View {
    var body: some View {
        Text("Another Text")
        MyView()
    }
}
```

You can create a `VStack` with `MyOtherView`, and will see the three views below each other, and when you create an `HStack` they're laid out on a single line.

In general, we can say that anything that conforms to the `View` protocol really represents a list of `View`s. In the case of `MyOtherView`, we could say the list has a single `Text` view and another list (`MyView`). These lists get flattened. In the case of `MyOtherView`, the `body` flattens down to a list containing three views.

Container views such as `HStack` and `VStack` take these lists, iterate over them and lay them out. Using the `Layout` protocol, you can also see these flattened lists. For example, you could construct your own `Layout` implementation to print the number of subviews:

```swift
struct MyLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        .zero
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        print(subviews.count)
    }
}
```

When you have a `MyLayout { MyOtherView() }` you'll see that it will always print 3.

To create lists with a dynamic size, you can use conditionals such as `if`. Note that constructs like `ForEach` produce a list as well. These can even be combined with other lists. For example, the code below creates a vertical stack with eight children:

```swift
 VStack {
     MyOtherView()
     ForEach(0..<5) {
         Text("Label \($0)")
     }
 }
```

As mentioned, the `Layout` protocol lets you work with these view lists directly as of iOS 16 and macOS 13. You can also use [variadic views](https://movingparts.io/variadic-views-in-swiftui) — a non-public, but stable API — to loop over view lists. The variadic view API is really powerful (for example, you can write things like `filter`, `map` and `reduce` on view lists) but also quite low-level. I have a gist [here](https://gist.github.com/chriseidhof/5ff6ef8786f5635c18b20304ab9d9b01) with some examples, and plan to also write this up soon.

> This article was inspired by the section that Florian wrote for our book [Thinking in SwiftUI](https://www.objc.io/books/thinking-in-swiftui). We're currently rewriting the book and hope to get it out soon.
