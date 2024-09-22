---
date: 2024-09-22
title: "Phase Animator Behavior"
headline: Unexpected Results
---

I'm currently still busy researching all the animation APIs in SwiftUI. I'd like to understand them at such a level that I have either my own working implementation or know how to build it.

With `PhaseAnimator`, I always was a little confused as to how it actually works and why it sometimes seems to skip phases. Here's what I think is going on:

- Initially the content closure of the phase animation is rendered using the first phase provided
- When you start a phase animation (either using the trigger or automatically by not providing a trigger), it calls the animation closure to determine the timing curve and animates to the next phase.
- When there are no more phases, it animates back to the initial phase.

Sounds simple enough. I wanted to do an animation where a view would move up a bit, then wait there and finally move back down. Here's what I did to have the view move up and back down:

``` swift
struct ContentView: View {
    @State private var trigger = 0

    var body: some View {
        Image(systemName: "globe")
            .phaseAnimator([0, -100], trigger: trigger) { view, phase in
                view.offset(y: phase)
            }
            .onTapGesture { trigger += 1}
    }
}
```

This works fine: whenever the trigger changes, the `.default` animation is used to move to offset -100, then when that animation completes the view moves back to 0 using another `.default` animation.

I thought I could let the view stay at -100 by just adding another phase with -100 to the array of phases, but unfortunately, that does not work, it just moves from 0 to -100 and back to 0 without staying at -100.

When I naively tried to reimplement `PhaseAnimator` I got the same behavior. My implementation works by first animating from the first to the second phase, and in the completion handler I'd animate to the next phase, and so on.

It took me a minute to realize why my code was behaving the same way. When you change a view's position from (say) -100 to -100 the attribute graph does not change. The nodes are exactly the same before and after the update, and there is nothing to be animated. When there are no concrete animations, the animation's completion handler is called immediately. In other words, we're moving to the next phase straight away.

To solve the actual problem I had, I instead added a delayed animation when animating back to the initial phase:

```
Image(systemName: "globe")
    .phaseAnimator([0, -100], trigger: trigger) { view, phase in
        view.offset(y: phase)
    } animation: { offset in
        offset == 0 ? .default.delay(1) : .default
    }
    .onTapGesture { trigger += 1}
```

This works as expected: the view animates to -100, stays there for a second and then animates back to 0.
