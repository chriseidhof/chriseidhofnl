---
date: 2022-03-28
title: "Lifetime of State Properties in SwiftUI"
headline: Surprisingly Subtle
---

This post is a look inside how (a small part of) SwiftUI works. I'm mainly writing this as part of my extended memory, so that I can go back to it and read about how it works. We're currently in the process of updating our book [Thinking in SwiftUI](https://www.objc.io/books/thinking-in-swiftui/) and figuring out some of the obscure behaviors of SwiftUI. While this might not make it into the book (we keep the book concise on purpose) I figured it's worth writing up.

One of the challenging parts of SwiftUI is really understanding the way it manages view state (for example, through `@State` and `@StateObject`). In theory, it's pretty simple: anytime you want associated view state you just create a property with `@State` and you're done. For example, here's a simple view with associated state:

```swift
struct Item: View {
    var id: Int
    @State private var counter = 0
    var body: some View {
        VStack {
            Text("Item \(id)")
            Button("Counter: \(counter)") {
                counter += 1
            }
        }
    }
}
```

When SwiftUI renders this view, it creates associated storage to hold the value of `counter`. As long as the view exists, the memory for `counter` is there, and once the view stops existing, the memory is gone.

However, when you have worked with `@State` (or `@StateObject`), you will notice that there might be some strange behavior. Sometimes your state disappears, especially when working with a `List` (or to be precise: any view that uses `ForEach` directly or indirectly).

To understand this better, we have to ask ourselves an existential question: 

> What does it mean for a view to exist?

Joking aside, here's what I think happens:

When a `List` is rendered on screen, it only allocates memory for the children that are directly on screen (on iOS, anyway). We can quickly verify this by initializing a `@State` property with a value expression that prints a line:

```swift
struct StateItemTest: View {
    @State var item: Int = {
        print("Initing")
        return 0
    }()
    let body = Text("Hello")
}

// Later:
List(0..<1000) { id in
    StateItemTest()
}
```

When we show the list view, we'll see a print statement for every row that's on screen. But these are created lazily: as we scroll down more and more print statements appear. So we have now established at least one thing:

*List creates its subviews lazily*. By the way, this is the same for `ForEach` in other lazy contexts. For example, when you put a `ForEach` inside a `LazyVStack` and that inside a `ScrollView`, you get the same effect.

My next question was: *when do these state values get destroyed again?* Is this when we scroll the views out of sight? We can verify this by having a long list of views with modifiable state properties. For example, we can put our `Item` view from above inside a long list:

```swift
List(0..<1000) { id in
    Item(id: id)
}
```

When we run the above list, we can change some state at the top of the list, scroll to the very bottom, and scroll back up. The state will still be there. So we have established another thing:

*The children of a `List` will be kept around*. The lifetime of a `@State`'s property is directly tied to the lifetime of a view. Once a list child is created, it never goes away again, unless the list goes away itself. (You can verify this by putting the list inside a navigation link and navigating back). Again, this doesn't just apply to `List` but any lazy `ForEach`.

However, this behavior puzzled me. I've written many SwiftUI lists, and I swear that I have seen state objects go away. What gives? In my case, I've seen this behavior when loading a list that contains images for each cell, and the images would get reloaded after scrolling back up.

It turns out that while the children of a `List` will be kept around (including their associated state), the bodies of those views will get destroyed. These will get recreated lazily once the view appears on screen again. If we run the same example as before, but wrap our `Item` view in another layer, we'll see that our state goes away as the view disappears:

```swift
struct ItemWrapper: View {
    var id: Int
    
    var body: some View {
        ZStack {
            Item(id: id)
        }
    }
}
```

This is the behavior in the version of SwiftUI that comes with Xcode 13. The full code is [available as a gist](https://gist.github.com/chriseidhof/440dbdbe9a5fa21ff5439b5f42582a44). The behavior might change in the future, as none of this is documented.
