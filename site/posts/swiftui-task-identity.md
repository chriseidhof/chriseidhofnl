---
date: 2025-11-13
title: "Task Identity"
headline: No automated dependency tracking
---

When you write SwiftUI views, one of the big advantages over UIKit is that SwiftUI performs automatic dependency tracking. Whenever your model invalidates or one of your view's properties change, your view is re-rendered.

Consider the following view that loads an image. It runs the image loading code in a `task`. The task will run the first time the view appears, and it seems to work:

```swift
struct ImageLoader: View {
    var url: URL
    @State private var loaded: NSImage? = nil
    var body: some View {
        ZStack {
            if let loaded {
                Image(nsImage: loaded)
            } else {
                Text("Loading…")
            }
        }
        .task {
            guard let data = try? await URLSession.shared.data(from: url).0 else { return }
            loaded = NSImage(data: data)
        }
    }
}
```

When we use the view in our `ContentView`, everything seems fine:

```swift
struct ContentView: View {
    var body: some View {
        ImageLoader(url: URL(string: "https://picsum.photos/200/300")!)
    }
}
```

However, there is a subtle bug in the initial code that is really hard to spot. The problem is that `task` runs the code exactly once — when the view appears. When the `url` property changes, the view's body will be re-rendered, but the task will not be re-run as the view has already appeared. If you use `onAppear` instead of `task` you'll have exactly the same problem.

We can verify by changing our `ContentView`:

```swift
struct ContentView: View {
    @State private var height = 300
    var body: some View {
        ImageLoader(url: URL(string: "https://picsum.photos/200/\(height)")!)
            .onTapGesture {
                height = height == 300 ? 200 : 300
            }
    }
}
```

When we run the code above, we can see that the image never loads again (beyond the initial load) even when the URL changes. We can put a print statement or breakpoint in the `ImageLoader`'s body and verify that the body is actually rerun when the URL changes.

The problem is our `task`: it runs when the view appears. And only when the view appears.

> **Note** Unfortunately, `task` and `onAppear` are currently the best way to run code when a view gets created in the [attribute graph](https://chris.eidhof.nl/note/attribute-graph/). However, the concept of "view appearance" is not clearly defined in SwiftUI. For example, the task will re-run when you put the image loader in a `List` and scroll it out of bounds and back into bounds. Likewise, when you put the image loader in a tab view, the task will also run again when switching tabs.

To fix our problem, we need to understand the core issue. Let's look at the code again:

```swift
struct ImageLoader: View {
    var url: URL
    @State private var loaded: NSImage? = nil
    var body: some View {
        // ...
        .task {
            guard let data = try? await URLSession.shared.data(from: url).0 else { return }
            loaded = NSImage(data: data)
        }
    }
}
```

Inside our `task` *we have a dependency on the `url` property*. This is causing our problems: ideally, we want our `task` to re-run whenever the `url` changes. We can do so by making the `url` part of the identity of our `task`:

```swift
.task(id: url) {
    guard let data = try? await URLSession.shared.data(from: url).0 else { return }
    loaded = NSImage(data: data)
}
```

This now makes our code work correctly. The task will run initially, and when the identity changes, the previous task gets cancelled and a new task is created.

### Adding More Properties

Let's consider a slightly more complicated example. Here we have a `task` that depends on two properties, `baseURL` (from the environment) and `path` (a regular property):

```swift
struct ImageLoader: View {
    @Environment(\.baseURL) private var baseURL
    var path: String

    @State private var loaded: NSImage? = nil

    var body: some View {
        // ...
        .task {
            let url = baseURL.appendingPathComponent(path)
            guard let data = try? await URLSession.shared.data(from: url).0 else { return }
            loaded = NSImage(data: data)
        }
    }
}
```

To make this work correctly, we now need to create a *compound* identity that combines both the `path` and `baseURL`, as the `task` depends on both. In addition, this value needs to conform to `Equatable`. An easy way to solve this is by taking all your dependencies and sticking them into an `[AnyHashable]`, for example by saying `[baseURL as AnyHashable, path as AnyHashable]`. In this specific example, we could actually pull out the `url` property — as it already combines both values — and use that as the identity:

```swift
struct ImageLoader: View {
    // ...

    var body: some View {
        let url = baseURL.appendingPathComponent(path)
        // ...
        .task(id: url) {
            guard let data = try? await URLSession.shared.data(from: url).0 else { return }
            loaded = NSImage(data: data)
        }
    }
}
```

Here's my advice: whenever you use `task` or `onAppear` in your code, be extremely careful about the dependencies. Make sure to review your code carefully, and ideally, have someone else review it as well.

> **Note** When you use `onAppear` instead of `task`, you can replace the `onAppear` with an [`onChange(of:initial:_:)`](https://developer.apple.com/documentation/swiftui/view/onchange(of:initial:_:)-4psgg). As the `value`, you'd use the compound identity.

Clearly, Apple can't just change the implementation of `task` or `onAppear` to make this work automatically, as I'm sure there are many apps that depend on the current behavior. I wonder if it can even be done automatically without introducing cycles in the graph.
