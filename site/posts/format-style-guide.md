---
date: 2026-04-16
title: FormatStyle Guide
headline: An Interactive Guide to Swift Foundation FormatStyle APIs
---

I just launched the [FormatStyle Guide](https://formatstyle.guide/), a new project that explores Swift Foundation's `FormatStyle` APIs in the browser via WebAssembly.

Similar in spirit to the [SwiftUI Field Guide](https://www.swiftuifieldguide.com/), I always wanted a quick visual overview of the available APIs. Unlike the SwiftUI Field Guide, I didn't want to reimplement all of the APIs in TypeScript.

However, now that Wasm support is [officially part of Swift](https://www.swift.org/documentation/articles/wasm-getting-started.html) I realized we could just do it interactively in the browser.

Doing this with Wasm is great because I don't need a server. What's not so great is that the binary size is big (47 MB). The setup was extremely easy for me (just prompting the LLM).

The guide contains interactive samples for formatting numeric values, dates and measurements that you can see and manipulate. It also contains advice about how to use this with SwiftUI, which has deep integration for `FormatStyle`. Finally, there are some examples in there that show parsing using the formatters as well.

I've added a beta badge because it's not quite finished yet, but I'm happy to hear your thoughts. There are some more things I'd like to add, but for now I think it's good enough for people to have a first look.

This was also an experiment in using an LLM to write the code. I wrote very little of this by hand. The quality is not the same as hand-written code, but: I was able to build and release this in two days.
