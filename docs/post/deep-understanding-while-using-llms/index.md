---
headline: "Solve It in 20 Minutes \u2014 Or Actually Understand It"
title: Deep Understanding while using LLMs
date: 2026-05-04
---



In our recent SwiftUI workshops, we have told people at the start to not use an LLM during the workshop. We think LLMs are great and help us to get to the results we want much quicker — for some tasks we easily get a ten times speedup. We tell the workshop attendees that they could solve all exercises within twenty minutes using an LLM, rather than two days of working through it by hand.

The goal of our workshop is not to solve the exercises, but instead, the goal is to build a very deep understanding of how SwiftUI works. We do this through multiple steps: first, we struggle through exercises. Then we talk about how we solved the exercises. Finally, we look at the theory behind it, we answer questions and look at visualizations of how SwiftUI works.

There is no shortcut to building deep understanding. Just reading a book or watching a video will not help. We often see that the explanations we give *before* the exercise don't really sink in until people work their way through it themselves.

From our perspective, the people that seem very successful in using LLMs have a deep knowledge of programming. They understand exactly how things work. This is what our SwiftUI workshops focus on as well. Building really deep knowledge so that you can work more effectively, with or without assistance. Many of my very experienced engineering friends who are into LLMs told us they mostly do shallow thinking nowadays. We just prompt away until we end up with something we don't really understand anymore, and making progress becomes increasingly harder.

The principles of software design still apply, more than ever. We need fundamental understanding. We need clear design and architecture. Many of the ideas from functional programming are a massive help in times of LLMs: clear boundaries, interfaces. Modeling your data so that it is correct by construction and impossible states are impossible. All of this helps with testability, which in turn makes the LLMs more effective. For example, I believe the constraints that the [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) puts in place make everything easier for building with LLMs.

When you're vibe coding a grocery list app for your family (as I have done) you can easily get away without any of this. A few prompts and it's done. But for robust software you'll still have to engineer it. LLMs do not replace understanding and engineering, they amplify it.

One of my favorite exercises during the SwiftUI workshop involves working your way through how state management works in SwiftUI, similar to the problem described in [task identity](https://chris.eidhof.nl/post/swiftui-task-identity/). Most people that read that post might think they understand it. But the literal (sometimes loud!) a-ha's that we hear during the workshop are one of the things that make me happiest when teaching. Even the people that thought they understood often get to a way deeper understanding by working through every step of the problem themselves.

Going forward, our workshops will mostly be hand-written code. Not because it's faster -- it's not. The main goal of our workshop is to deepen people's understanding and mental model. That's what we optimize for.
