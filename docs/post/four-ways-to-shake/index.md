---
headline: Comparing SwiftUI Animation Tools
title: Four Ways to Shake
date: 2026-08-31
published: false
script: /js/shake-comparison.js
---



In SwiftUI, you can often achieve the same thing in many different ways. For example, if you wanted a shake animation in SwiftUI, there are at least four obvious ways to do it. These are not equivalent, both in terms of what's technically possible and also the smoothness of the animation.

Here's one example with four different implementations. Can you spot the differences?

<div data-swiftui-shake-preview data-wide></div>

It might be a bit hard to spot, but each of these animates in a slightly different way. In general, we want animations to have a smooth curve. For example, in the real world, when an object moves, it starts slowly, then becomes faster and finally slows down to a halt. In SwiftUI, this is typically done with the `easeInOut` timing curve.

When you animate the position of objects, it often "feels more natural" if that animation is somewhat like things happen in the real world. Start slowly, pick up speed, slow down again. Rather than only relying on what "feels natural", we can also get technical about this.

If we consider the x position of our gray box as a function that takes time as the input, and the x position as the output, we can talk about the *continuity* of that function. Ideally, we want no sudden jumps in the output values as time increases. This is C<sup>0</sup> continuity. Going one level higher, we also want the *velocity* to be continuous: if the object has a lot of motion all of a sudden, that feels unnatural. This is C<sup>1</sup> continuity. If we then go yet another level higher, we also ideally don't want jumps in the acceleration. This is C<sup>2</sup> continuity. We'll look at these in more detail.

## The Four Implementations

Perhaps the simplest way to implement this in modern SwiftUI is through a phase animator. A phase animator is essentially a bunch of chained animations. In the example below, we first animate our offset from 0 to -60 (in 0.25 seconds). When that animation completes, we then animate (in 0.5 seconds, as it takes longer to travel) to 60, and when that finally completes we animate back to zero (in 0.25 seconds).

### Phase Animator

```swift
struct Example: View {
    @State var trigger = 0

    var body: some View {
        Color.gray
            .frame(width: 48, height: 48)
            .onTapGesture { trigger += 1 }
            .phaseAnimator(
                [0.0, -60, 60, 0],
                trigger: trigger
            ) { content, offset in
                content.offset(x: offset)
            } animation: { offset in
                .easeInOut(duration: offset == 60 ? 0.5 : 0.25)
            }
    }
}
```

In the graph, we can see that the x position of the box follows a smooth curve. We also can look at the velocity, which is the *derivative* of the function that plots the x position. At the points where a next phase starts, we can see that the velocity is continuous but not smooth (the slope changes abruptly). Hence, our animation is C<sup>1</sup> continuous but not C<sup>2</sup> continuous.

<div data-swiftui-shake-example="phaseAnimator" data-wide></div>


### Custom Animatable

We can also create a custom `Animatable` view. This technique has been supported since the beginning of SwiftUI, whereas the other three techniques have been added later. The essence is to have a view that conforms to the `Animatable` protocol which then gets updated using an animation.

```swift
struct AnimatableShake: View, Animatable {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Color.gray
            .frame(width: 48, height: 48)
            .offset(x: -sin(progress * 2 * .pi) * 60)
    }
}

struct Example: View {
    @State var progress = 0.0

    var body: some View {
        AnimatableShake(progress: progress)
            .onTapGesture {
                withAnimation(.linear(duration: 1)) {
                    progress += 1
                }
            }
    }
}
```

Because we chose a sine wave to compute the animation our derivative is the cosine. Both functions are smooth and have no sudden jumps.

<div data-swiftui-shake-example="customAnimatable" data-wide></div>

Unfortunately, our animation is *not* C<sup>1</sup> continuous, even though the plotted velocity looks very smooth. This is because the initial velocity is not zero, instead, it starts with a low velocity. One way to fix this would be to first apply a smoothing function to `progress` (e.g. `UnitCurve.easeInOut`).

### Keyframe Animator

A third way to implement this is using a keyframe animation. This technique is a bit more low-level, but really powerful: we can have it animate through multiple values over time. We can specify multiple *tracks*, for example, we could animate both the rotation and the offset together in a coordinated way. In the example below, we only animate the x position, so there is no need for multiple tracks.


```swift
struct Example: View {
    @State var trigger = 0

    var body: some View {
        Color.gray
            .frame(width: 48, height: 48)
            .onTapGesture { trigger += 1 }
            .keyframeAnimator(
                initialValue: 0.0,
                trigger: trigger
            ) { content, offset in
                content.offset(x: offset)
            } keyframes: { _ in
                KeyframeTrack(\.self) {
                    CubicKeyframe(-60, duration: 0.25)
                    CubicKeyframe(60, duration: 0.5)
                    CubicKeyframe(0, duration: 0.25)
                }
            }
    }
}
```

The unique feature that keyframes have is when you specify *cubic keyframes*: the animator will then use that to build a [Catmull-Rom spline](https://en.wikipedia.org/wiki/Catmull–Rom_spline)[^1]. The intuition for this is very simple: it will try to draw a smooth line through all the control points (keyframe values) we provide:

<div data-swiftui-shake-example="keyframeAnimator" data-wide></div>

Unfortunately, these are also only C<sup>1</sup> continuous, we can clearly see a change in the slope of the velocity at exactly the control points.

> Another interesting observation is that because of how Catmull-Rom works, it overshoots a little beyond 60. For the position, this is a perfectly natural thing to happen, but for other properties, that might yield strange results (e.g. overshooting an opacity is typically not something we'd want).

### Timeline View

Perhaps the approach that gives us the most control is a `TimelineView`. This just calls the closure for every animation frame, and we are free to do whatever we want:

```swift
struct Example: View {
    @State var startedAt: Date?

    var body: some View {
        TimelineView(.animation(paused: startedAt == nil)) { context in
            let elapsed = startedAt.map {
                context.date.timeIntervalSince($0)
            } ?? 0
            let progress = min(1, max(0, elapsed))
            Color.gray
                .frame(width: 48, height: 48)
                .offset(x: -sin(progress * 2 * .pi) * 60)
                .onTapGesture { startedAt = context.date }
        }
    }
}
```

As we used the same sine wave as before, both our position and velocity functions are smooth, and just like with the custom `Animatable`, the initial velocity of the sine's derivative makes this only C<sup>0</sup> continuous.

<div data-swiftui-shake-example="timelineView" data-wide></div>

## Conclusion

All of these approaches have a time and place to be used. I try to start with just regular animations, then move to phase animations. If I need more control over the curve or need to animate multiple properties in sync, I'll use keyframe animations. I hardly ever reach for `TimelineView` unless I'm doing something really custom.

I'm hoping to do a few more of these blog posts and maybe even add this to the [SwiftUI Field Guide](https://www.swiftuifieldguide.com). We cover animations in our [SwiftUI Workshop](https://www.swiftuifieldguide.com/workshops/). I have also offered specific one-day SwiftUI Animation workshops before, but don't currently have a page for that. If your company is interested in this, do let me know.


One of the videos that got me really interested in this topic is [The continuity of splines](https://www.youtube.com/watch?v=jvPPXbo87ds) by Freya Holmér. It's really worth a watch.

AI Disclaimer: I wrote all text by hand. I used an LLM to build the visualizations and find mistakes.

[^1]: Yes, that's Edwin Catmull who also co-founded Pixar.
