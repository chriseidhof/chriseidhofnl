---
date: 2026-08-31
title: Four Ways to Shake
headline: Comparing SwiftUI Animation Tools
published: false
script: /js/shake-comparison.js
---

SwiftUI gives us several very different ways to describe the same animation.
To compare them, I implemented one small shake four times: the box moves from
the center to the left, then to the right, and finally back to the center.

The examples below use a custom `Animatable`, a `PhaseAnimator`, a `KeyframeAnimator`, and a `TimelineView`. Tap a box to run that animation.
You can also drag the headed line in its position graph to inspect the exact
position and velocity at any point in time.

## The Four Implementations

These declarations are loaded from the same generated data as the interactive
examples. This keeps the source shown in the article identical to the source
used to produce the traces.

### Custom Animatable

<pre><code data-swiftui-shake-source="customAnimatable">Loading source…</code></pre>

<div data-swiftui-shake-example="customAnimatable" data-wide></div>

### Phase Animator

<pre><code data-swiftui-shake-source="phaseAnimator">Loading source…</code></pre>

<div data-swiftui-shake-example="phaseAnimator" data-wide></div>

### Keyframe Animator

<pre><code data-swiftui-shake-source="keyframeAnimator">Loading source…</code></pre>

<div data-swiftui-shake-example="keyframeAnimator" data-wide></div>

### Timeline View

<pre><code data-swiftui-shake-source="timelineView">Loading source…</code></pre>

<div data-swiftui-shake-example="timelineView" data-wide></div>
