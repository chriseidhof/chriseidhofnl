---
date: 2023-08-31
title: "Running Code When Your View Appears"
headline: onAppear and task are not the same
---

When you're writing SwiftUI views, you definitely don't want to run expensive tasks in the view's initializer, as it might get called very often. Also, since the view doesn't have structural identity yet when the initializer runs, you can't reliably store data. Instead, you want to load data in the view's body before the view will be drawn on screen.

You can achieve this with `.task` or `.onAppear`. The `onAppear` modifier has been around since the beginning. It takes a regular closure that is called whenever the view appears on screen[^1]. The `task` modifier supports async/await without you having to create a manual `Task`. The task also gets cancelled automatically when the view disappears.

Because `task` can do anything that `onAppear` can, is there still any reason to use `onAppear`? Or can we just move to `task`? At first, I thought the two are the same, it seems like `task` is built on top of `onAppear`. There is a small difference, however (which might be an essential difference depending on how you use it). Consider the following view:

```swift
struct ContentView: View {
    @State private var color0 = Color.red
    @State private var color1 = Color.red
    var body: some View {
        VStack {
            color0
            color1
        }
        .onAppear { color0 = .green }
        .task { color1 = .green }
    }
}
```

When you launch this app, you can see that the topmost view in the `VStack` never renders in red, whereas the bottom view quickly flickers red before turning green. If you can't see it, you can use QuickTime to create a screen recording and verify it that way.

> We first noticed this behavior when implementing our own version of AsyncImage. We wanted to take a cached image, but when you use `task`, you'll always see the placeholder.


When you use `onAppear` or `onPreferenceChange` (possibly more modifiers), SwiftUI can execute your code before it even renders a single frame. Initially, the body executes, calls `onAppear` and then runs the closure inside `onAppear`. If this changes any state, the body is re-rendered before the view is even drawn on screen.


I'm not sure why task behaves differently and if the source of this "problem" is with SwiftUI or the concurrency system. I'm not sure if it's meant to be or considered a bug, but at least, at this moment in time, it does work differently.

[^1]: The closure is called at least once when the view appears, but can also be called multiple times. For example, when the view is in a scroll view or a tab bar, the closure gets called each time the view becomes visible.
