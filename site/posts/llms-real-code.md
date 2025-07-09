---
date: 2025-07-09
title: LLMs for "Real Projects"
headline: Different Kinds of Prompts
---

When I have an LLM assistant write prototypes in a language that I don't know, my prompts are high-level and focused on features, not implementation. For simple projects, often a one-shot approach works. For example, I'll say:

> take these notes from my therapist and help me build a simple react app that asks me those questions.

For the project I was building above, I didn't really care about the code, I just wanted it to work.

When I write SwiftUI, I'd like to have a *lot* more control, because that's the domain I know. I care about the code. My prompts become a lot more technical and implementation-specific. For example, I said:

> When hovering over an anchor/socket, propagate that anchor's bounds, including its unit point up using a preference. The preference should contain an array of all the anchors that are currently hovered over.  I think we should do the bounds as an Anchor&lt;CGRect>. Before we do this, we should extract the socket view out into its own view. 

My prompts are typically smaller, but still: this prompt worked really well. I was already in the context of making edits to that node view that contained the sockets. The code it generated was very close to what I would've written myself.

One interesting note: somewhat confusingly, I have anchors in my code that represent the sockets a node has (I'm building a small drawing app). Claude Code did not confuse them with SwiftUI's builtin `Anchor` values.
