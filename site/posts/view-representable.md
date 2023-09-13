---
date: 2023-09-13
title: "Working With UIViewRepresentable"
headline: Preventing Runtime Warnings and Loops
---

When we work with SwiftUI, we can always drop down to UIKit level by using `UIViewRepresentable`, `NSViewRepresentable` or `UIViewControllerRepresentable`. The documentation around these protocols is still pretty sparse, and it can be hard to get them to work exactly the way we want. I tried to come up with some rules and patterns for using them. These patterns are *not* final, if you have feedback about missing things or mistakes, please let me know. 

There are a few different challenges. In this article, I want to focus on communicating state between SwiftUI and UIKit/AppKit. Communication can happen in either direction: we'll need to update our `UIView` when SwiftUI's state changes, and we'll need to update our SwiftUI state based on UIView changes.

Here are two rules for working with representables. ([Matt](https://www.cocoawithlove.com) helped me with this, thank you):

- When updating a UIView in response to a SwiftUI state change, we need to go over all the representable's properties, but only change the UIView properties that need it.
- When updating SwiftUI in response to a UIKit change, we need to make sure these updates happen asynchronously.

If we don't follow these rules, there are a few issues we might see:

- The dreaded "Modifying state during view update, this will cause undefined behavior" warning
- Unnecessary redraws of our `UIViewRepresentable`, or even infinite loops
- Strange behavior where the state and the view are a little bit out of sync

In my testing, these issues are becoming less relevant with UIKit, but are very relevant when dealing with AppKit. My guess is that UIKit components have seen some internal changes to make writing view representables simpler. However, as we'll see, this isn't the case for every UIKit view.

**Building a MapView wrapper**

MapKit's `Map` view for SwiftUI used to be very limited, and a popular target for wrapping in a representable. As of iOS 17 it gained a lot of new capabilities, but we'll still use it as our first example.

We'll be writing a simple wrapper that takes a binding to the map view's center coordinate. As a first step, we'll create an `MKMapView` and set the delegate to be our coordinator.

```swift
struct HybridMap: UIViewRepresentable {
    @Binding var position: CLLocationCoordinate2D
    
    // ...

    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.delegate = context.coordinator
        view.preferredConfiguration = MKHybridMapConfiguration()
        return view
    }

    // ...
}
```

For the coordinator, there is a nice technique to pass in all properties of `HybridMap` directly (this is especially useful when we have more than one property). You can simply pass a copy of `self`, as `HybridMap` is a struct:

```swift
// ...
class Coordinator: NSObject, MKMapViewDelegate {
    var parent: HybridMap
    init(parent: HybridMap) {
        self.parent = parent
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        parent.position = mapView.centerCoordinate
    }
}

func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
}
// ...
```

Finally, here's our `updateUIView` method:

```swift
func updateUIView(_ view: MKMapView, context: Context) {
    context.coordinator.parent = self
    view.centerCoordinate = position
}
```

We can now create a simple view with a state property for the position:

```swift
let initialPosition = CLLocationCoordinate2D(latitude: 52.518611, longitude: 13.408333)

struct ContentView: View {
    @State private var position = initialPosition
    
    var body: some View {
        VStack {
            Text("\(position.latitude) \(position.longitude)")
            Button("Reset Position") { position = initialPosition }
            HybridMap(position: $position)
        }
    }
}
```

When we launch the above app, we'll immediately get a runtime warning: "Modifying state during view update, this will cause undefined behavior.". To debug this, we can add print statements to the beginning and ending of both our `updateUIView` as well as `mapViewDidChangeVisibleRegion` methods:

```swift
func updateUIView(_ view: MKMapView, context: Context) {
    print("Begin updateUIView", position)
    defer { print("End updateUIView") }
    context.coordinator.parent = self
    view.centerCoordinate = position
}
// ...
func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    print("Begin didChange", mapView.centerCoordinate)
    defer { print("End didChange") }
    parent.position = mapView.centerCoordinate
}
```

When we launch the app, we get the following print statements:

```
Begin updateUIView CLLocationCoordinate2D(latitude: 52.518611, longitude: 13.408333)
End updateUIView
Begin didChange CLLocationCoordinate2D(latitude: 51.117027, longitude: 10.333652000000006)
End didChange
Begin didChange CLLocationCoordinate2D(latitude: 52.51861099999999, longitude: 13.40833300000003)
End didChange
Begin updateUIView CLLocationCoordinate2D(latitude: 52.51861099999999, longitude: 13.40833300000003)
Begin didChange CLLocationCoordinate2D(latitude: 52.51861099999999, longitude: 13.40833300000003)
[SwiftUI] Modifying state during view update, this will cause undefined behavior.
End didChange
End updateUIView
```

Here's what happens: first, the view is rendered and put on screen. After that, the `didChange` runs. We can see that map views don't store their center coordinate directly, my guess is that they only store the visible region as their source of truth. This is why the values in the print statements are different from our initial value. Towards the end, we see that a `didChange` runs from within our `updateUIView` method, updating our SwiftUI state. This causes the "Modifying state" error.

As far as I know, the only reliable way I know of to get rid of this warning is by doing this state change asynchronously. The simplest way is by enqueueing another block on the main queue:

```swift
func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    DispatchQueue.main.async {
        self.parent.position = mapView.centerCoordinate
    }
}
```

This makes the runtime warning go away. However, we can't drag the map anymore, after a single drag movement it halts. There is one more step left to make this representable work:

```swift
func updateUIView(_ view: MKMapView, context: Context) {
    context.coordinator.parent = self
    if view.centerCoordinate != position {
        view.centerCoordinate = position
    }
}
```

By only doing the view update when necessary we're not triggering another `didChange`. Both of these changes are specific instances of the rules at the beginning of the article:

- We need to change our SwiftUI state asynchronously in response to UIKit changes.
- We need to only update properties of UIKit views when absolutely necessary

**Building a Text View wrapper**

As a second example, we'll build an `NSTextView` wrapper. My goal is to write a `MyTextView` component that takes a binding for both the text and the selected range. This is for the Mac, so we'll be using `NSView` instead of `UIView`.

Here's the (broken) initial version, with a structure very similar to our map view:

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

Similar to the map view, we can now wrap our update by enqueueing it on the main queue:

```swift
func textViewDidChangeSelection(_ notification: Notification) {
    let r = self.textView.selectedRange()
    DispatchQueue.main.async {
        self.parent.selection = r
    }
}
```

Unfortunately, things are still broken: we don't get a runtime warning anymore, but the cursor behaves weirdly. (The insertion point is rendered at the start of the current selection whenever the length of the selection is zero).

**Updating an NSView in Response to a SwiftUI State Change**

In principle, this is simple. Whenever something changes, SwiftUI will call `updateNSView(:context:)`. However, we don't know *what* changed, it could be any number of properties. In the above implementation, we simply set the two properties, but that's not enough.

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

When I type a character at the end of the string, the selection changes. A `self.parent.setSelection…` is enqueued. Before that runs, however, the text is updated, and `updateNSView` happens. It will set the attributed string, which in turn causes the selection to change, which adds another `setSelection` to the queue (with the old selection value). The main queue then runs the first (correct) block to set the selection, and then the second (incorrect) block. 

To keep the order of events correct, this means we also have to enqueue the changing of our text. That way, all events will happen in the order we expect:

```swift
func textDidChange(_ notification: Notification) {
    let str = textView.string
    DispatchQueue.main.async {
        self.parent.text = str
    }
}
```

This is tricky to find and tricky to debug. A simple rule of thumb would be that once we start enqueueing one change asynchronously, we probably need to do all of the other updates asynchronously as well.

**More Issues and Gotchas**

As mentioned, we need to check each property in `updateNSView(:context:)` and make sure to only update the `NSView` when it's really needed. This relies on us being able to compare values.  Sometimes this isn't possible. For example, when dealing with the map view, we saw that the center coordinate conversion is lossy. In the cases where we can't read out the current value, we can cache each value that we set. Inside our coordinator, we could add a helper like this:

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

I'm sure there are many more issues when doing this in practice, if you have any feedback or comments I'd love to hear about it.

If you want to learn more about SwiftUI, check out our book [Thinking in SwiftUI](https://www.objc.io/books/thinking-in-swiftui/).
