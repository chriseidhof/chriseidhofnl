---
date: 2025-03-03
title: "SwiftUI Phase Animation \"Bug\""
headline: An Unexpected Behavior
---

I noticed that phase animators weren't behaving as expected, and I initially assumed I'd found a bug in SwiftUI. It took me way too long to realize the problem here, that's why I am writing this up. Spoiler alert: *there is no bug*.

I am preparing a workshop on SwiftUI Animations (this is a follow-up to our regular [SwiftUI Workshop](https://www.swiftuifieldguide.com/workshops/)). As I went through the exercises, I created a very minimal shake animation to demo how phase animators work. 

A phase animator lets you animate between multiple phases (in the example below, the initial phase is 0, the second phase is 20 and the third phase -20). It starts by displaying the view at its initial phase. When we change the trigger value, it animates to the second phase. When that animation completes, it animates to the third phase. Finally, it animates back to the initial phase. This is essentially a really nice way to run nested animations in completion handlers. In the animation closure, you get the *target phase* in and can choose which animation curve you want to animate towards that value.

Here's my attempt at trying to create a shake animation with a custom timing curve for the first part of the animation. I exaggerated the curve so that it's really clear that this doesn't work:

```swift
struct ContentView: View {
    @State var trigger = 0
    var body: some View {
        Button("Hello") {
            trigger += 1
        }.phaseAnimator([0, 20, -20], trigger: trigger) {
            $0.offset(x: $1) // somehow always animates with the default animation
        } animation: { phase in
            switch phase {
            case 20: .linear(duration: 5)
            default: .default
            }
        }
    }
}
```

If you run the example above, you can even set a breakpoint and see that the `linear` animation gets used. What's more, you can add a `transaction { print($0.animation) }` to the content closure, and you'll see the correct animation printed out. Yet it does not animate slowly.

The problem has two causes:

- SwiftUI buttons have an implicit animation going on. This happens even with a custom `ButtonStyle`. I haven't verified this, but I think it animates when you depress a button (when `isPressed` changes back to false). 
- Layout modifiers such as `offset` are applied at the leaf nodes in the view tree (in this case, the actual button). In other words, the `offset` itself does not animate, but instead, the `x` position of the button animates. 

As far as I'm aware, the button animation behavior is not documented. The layout behavior is underdocumented and could be much clearer. There are a number of solutions: the easiest is to apply a `geometryGroup` before the `offset`. This causes the offset to apply to the group as a whole, rather than being applied at the leaf views. Interestingly, the documentation of `geometryGroup` actually explains that position and size are set at the leaf views.

```swift
struct ContentView: View {
    @State var trigger = 0
    var body: some View {
        Button("Hello") {
            trigger += 1
        }.phaseAnimator([0, 20, -20], trigger: trigger) {
            $0
                .geometryGroup() // this now animates as a whole rather than at the leaf views
                .offset(x: $1)
        } animation: { phase in
            switch phase {
            case 20: .linear(duration: 5)
            default: .default
            }
        }
    }
}
```

The geometry group above now animates its frame and uses the animation it receives from the current transaction (the five second linear animation). Internally, the button animates its pressed state but that doesn't influence the position anymore.

Alternatively, for my purposes (demoing phase animators) I could use an `onTapGesture` instead of a button, as I don't need all the extra stuff that button provides (highlighting, styling and accessibility). Or use a different modifier than `offset`, such as rotation or scale (these don't apply at the leaf nodes).

This is not the first time I've been bitten by the default button animations, and probably not the last. Hopefully writing this post will help me remember in the future.
