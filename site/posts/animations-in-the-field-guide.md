---
date: 2026-09-17
title: Animations in the SwiftUI Field Guide
headline: Working in Public
---

Two years ago, I created the [SwiftUI Field Guide](https://www.swiftuifieldguide.com/) together with [Nicholas](https://nicholaschristowitz.com/), who did the design. It's one of the things I'm most proud of. It contains a small SwiftUI reimplementation in TypeScript, and everything works on the web and is interactive. I deliberately chose to keep the text very minimal and let the examples do the work. Building it taught me a lot, but after the release I eventually focused on other things.

A few weeks ago, I started integrating all kinds of components and pieces we've built over the years into a single reimplementation of SwiftUI in Swift. This reimplementation is very far from production ready, and that's not the goal at all. I want to use it for teaching. It contains instrumentation and tracing so you can see the layout process, the animation process, and inspect and debug the entire attribute graph.

I then compiled this to WebAssembly and integrated it into the Field Guide in a [new section on animations](https://www.swiftuifieldguide.com/animations/). All the examples there run through WebAssembly and show how animations work in SwiftUI. I haven't made the section "public" yet.

It's still a work in progress, but I wanted to release it anyway, in a build-in-public kind of way. I hope that in the next few weeks I can get all the pages out that I wanted to do, and then do more editing passes.

I've been able to move really quickly because of LLMs, building new examples and making edits to them with a much higher velocity than doing everything by hand. I spend most of my time thinking about the writing, which I do myself, and what examples I actually want to show.

It took quite a while to teach the LLM what the examples should look like. Most of its initial output was quite bloated and overcomplicated, but now we've settled into something that's mostly right the first time around.

In any case, I wanted to let people know that this now exists, and would love to hear any feedback on this work. I also added an animations workshop to the [workshops page](https://www.swiftuifieldguide.com/workshops/) in addition to the regular SwiftUI Workshop.
