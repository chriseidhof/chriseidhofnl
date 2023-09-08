---
date: 2023-09-08
title: "Working With UIViewRepresentable"
headline: Gotchas and patterns
published: false
---

When we work with SwiftUI, we can always drop down to UIKit level by using `UIViewRepresentable`, `NSViewRepresentable` or `UIViewControllerRepresentable`. The documentation around these protocols is still pretty sparse, and it can be hard to get them to work exactly the way you want. I tried to come up with some rules and patterns for using them. These patterns are *not* final, if you have feedback about missing things or mistakes, please let me know.

There are a few different challenges. In this article, I want to focus on communicating state between SwiftUI and UIKit. I haven't really explored layout yet. There are two separate ways of communicating: SwiftUI can let you know its state has changed, and you'll need to update the underlying `UIView`. There's also the other way around, where something in UIKit changed and you need to tell SwiftUI about it. I have come up with two rules for this ([Matt](https://www.cocoawithlove.com) helped me with this, thank you):

- Updating a UIView in response to a SwiftUI state change, you need to go over all possible properties but only change the UIView when it's really needed.
- When updating SwiftUI in response to a UIKit change, you need to make sure these updates happen async.

I'll elaborate on both of these.

**Building a Text View wrapper**

We'll focus on building a text view wrapper as our running example. My initial goal is to write a `MyTextView` component that takes a binding for both the text and the selected range. I'll write this for the Mac, so we'll be using `NSView` instead of `UIView`. I chose this because it's the simplest example I could think of to demonstrate some of the common issues.

Here's the (broken) initial version. It takes two bindings. It uses the fact that structs are values to communicate `self` to the view's coordinator. This gives the coordinator access to both bindings.

```swift
struct MyTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var selection: NSRange

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MyTextView
        unowned var textView: NSTextView!
        init(parent: MyTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            self.parent.text = textView.string
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            self.parent.selection = textView.selectedRange()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSTextView {
        let t = NSTextView()
        context.coordinator.textView = t
        t.delegate = context.coordinator
        return t
    }

    func updateNSView(_ t: NSTextView, context: Context) {
        t.textStorage?.setAttributedString(text.highlight())
        t.selectedRanges = [.init(range: selection)]
    }
}
```

When we run the example above, we can see that we get the dreaded "Modifying state during view update, this will cause undefined behavior" warning. This happens because when we set the attributed string from within `updateNSView`, the text view will fire a `textViewDidChangeSelection` notification. This notification isn't posted asynchronously, but actually does happen during the `updateNSView`.

**Updating SwiftUI in Response to an NSView Change**

Whenever we update our SwiftUI state, we need to make sure this happens outside of `updateNSView`. In many cases, the framework already does this for you (for example, the above bug doesn't happen when writing the UIKit equivalent). However, when it doesn't, the simplest workaround that I know of is wrapping your update in a `DispatchQueue.main.async`. This feels wrong, but gets rid of the warning:

```swift
func textViewDidChangeSelection(_ notification: Notification) {
    let r = self.textView.selectedRange()
    DispatchQueue.main.async {
        self.parent.selection = r
    }
}
```

Unfortunately, things are now still broken: we don't get a warning, but the cursor behaves weirdly. (The insertion point is rendered at the start of the current selection whenever the length of the selection is zero).

**Updating an NSView in Response to a SwiftUI State Change**

In principle, this is simple. Whenever something changes, SwiftUI will call `updateNSView(:context:)`. However, you don't know *what* changed, it could be any number of properties. In the above implementation, we simply set the two properties, but that's not enough.

In our update method, we should take care to inspect each property, but only set the corresponding `NSView` value if it's really necessary. For example:

```swift
func updateNSView(_ t: NSTextView, context: Context) {
    context.coordinator.parent = self
    if t.string != text {
        t.textStorage?.setAttributedString(text.highlight())
    }
    if t.selectedRange() != selection {
        t.selectedRanges = [.init(range: selection)]
    }
}
```

This solves almost all our problems. However, there is still a weird issue. When I'm typing at the end of the text field, some characters get inserted just before the last character, instead of at the end.

Here's what happens (bear with me):

When I type a character at the end of the string, the selection changes. A `self.parent.setSelection…` is enqueued. Before that runs, however, the text is updated, and `updateNSView` happens. It will set the attributed string, which in turn causes the selection to change, which adds another `setSelection` to the queue (with the old selection value). This *also* enqueues a `self.parent.setSelection…` (but with the old value). The main queue then runs the first (correct) block to set the selection, and then the second (incorrect) block. 

To keep the order of events correct, this means we also have to enqueue the changing of our text. That way, all events will happen in the order we expect:

```swift
func textDidChange(_ notification: Notification) {
    let str = textView.string
    DispatchQueue.main.async {
        self.parent.text = str
    }
}

```

**More Issues and Gotchas**

As mentioned, we need to check each property in `updateNSView(:context:)` and make sure to only update the `NSView` when it's really needed. This relies on us being able to compare values.  Sometimes this isn't possible. For example, when dealing with a map view, we might want to expose the `centerCoordinate` as a binding, but it might store an `MKMapRegion` internally. When the conversion between these two is lossy, we'll need to cache each value that we set. Inside your coordinator, you could add a helper like this:

```swift
private var previousValues: [String: Any] = [:]
func setIfNeeded<Value: Equatable>(value: Value, name: String, update: (NSTextView) -> ()) {
    if let previous = previousValues[name] as? Value, previous == value {
        return
    }
    previousValues[name] = value
    update(textView)
}   
```

When we set the new value, we first check whether or not we've previously set this value. Only if it's different, we proceed to update the underlying platform view. In a way, this is similar to SwiftUI's `onChange(of:)` modifier (only run the closure when something changed).

Similarly, when we want to start animations in SwiftUI, we'll need to have some kind of state, and our coordinator needs to track when that state changes and only start a new animation then. You could use a method similar to `setIfNeeded` to achieve this.

Sometimes, we want to communicate events back from an NSView to SwiftUI. If the event modifies a value, we could simply modify the corresponding binding. For example, if the event would be `scrollViewDidScroll`, we can change the `scrollPosition` binding. However, for other events it's more appropriate to just call a closure (this is what `Button` does each time the user taps). Of course, this closure could have parameters as well.
