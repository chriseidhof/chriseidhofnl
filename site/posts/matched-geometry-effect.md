---
date: 2023-04-04
title: "When Matched Geometry Effect Doesn't Work"
headline: The Declaration Order Matters
---

One of the SwiftUI APIs that always kept confusing me is matchedGeometryEffect. I often thought I could use it but couldn't figure out exactly how to make it work, always getting weird effects. I tried to distill the problematic code down to the essence:

```swift
struct ContentView: View {
    @State private var detail = false
    @Namespace private var ns

    var body: some View {
        ZStack {
            if detail {
                Color.red
                    .frame(width: 100, height: 100)
                    .matchedGeometryEffect(id: "rect", in: ns)
            } else {
                Color.red
                    .frame(width: 300, height: 300)
                    .matchedGeometryEffect(id: "rect", in: ns)
            }
        }
        .animation(.default, value: detail)
        .onTapGesture {
            detail.toggle()
        }
    }
}
```

When you run the code above, you will see that there is something like a transition between the two red squares, but there's nothing smooth about it. Why doesn't the small square grow bigger, and why doesn't the large square grow smaller? They only seem to shift.

<video class="light-video" width="320" height="320" autoplay playsinline muted loop>
   <source src="/movies/mge-light.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>
<video class="dark-video" width="318" height="318" autoplay playsinline muted loop>
   <source src="/movies/mge-dark.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

What helped me understand is [reimplementing matchedGeometryEffect](https://talk.objc.io/episodes/S01E260-matched-geometry-effect-part-3). While there is a bit more to it, the matched geometry effect will essentially apply a `frame` and an `offset` modifier. Let's consider only the if-branch:

```swift
Color.red
    .frame(width: 100, height: 100)
    .matchedGeometryEffect(id: "rect", in: ns)
```

If we virtually "inline" the matched geometry effect, the code looks like this:

```swift
Color.red
    .frame(width: 100, height: 100)
    .offset(x: <matchedX>, y: <matchedY>)
    .frame(width: <matchedWidth>, height: <matchedHeight>)
```

While the outer frame and offset will have an effect on where the view is positioned, we can see that the inner frame will ultimately control the size, overriding the proposed size of the outer frame modifier. In other words: the red square will *always* render at 100⨉100.

To fix this, we need to change the order of our modifiers so that the `matchedGeometryEffect` is directly applied to the color. As the color is completely flexible, this doesn't cause any problems. Here's the changed `if` branch, the `else` branch needs to change as well:

```swift
Color.red
     .matchedGeometryEffect(id: "rect", in: ns)
     .frame(width: 100, height: 100)
```

Now our rectangle animates smoothly between the two states:

<video class="light-video" width="318" height="318" autoplay playsinline muted loop>
   <source src="/movies/mge-fixed-light.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>
<video class="dark-video" width="318" height="318" autoplay playsinline muted loop>
   <source src="/movies/mge-fixed-dark.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

(Of course, the above animation could be done in a much simpler way by removing the if/else, but I wanted to work with a minimal example that uses matched geometry effect.)
