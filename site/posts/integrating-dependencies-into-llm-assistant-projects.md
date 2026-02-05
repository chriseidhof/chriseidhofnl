---
date: 2026-02-05
title: Integrating Dependencies into LLM-Assisted Projects
headline: Melting Code into your Codebase
---

The other week I met [Orta](https://orta.io) again. When talking about LLM-assisted coding, we also discussed dependencies. He told me about an approach he's been taking: he just integrates dependencies into his code by literally pasting in the files and then adjusting them as needed. He also [recommends this](https://github.com/puzzmo-com/tapped?tab=readme-ov-file#what-is-tapped) way of integrating for one of his projects. To me, it almost feels like "melting" the dependency into the codebase. You start owning the code the moment you integrate.

This is very different from having a dependency manager where you depend on the code other people maintain. Over the years, even before LLMs, I've done the same with my own code. Rather than abstracting things out, I often would just paste in existing code and modify it for that project. With LLMs, it's now become even easier to do that.

Even Donald Knuth was skeptical about reusable code:

> I also must confess to a strong bias against the fashion for reusable code. To me, "re‐editable code" is much, much better than an untouchable black box or toolkit. [...]

([Source](https://mmix.cs.hm.edu/other/knuth-interview.pdf))

In any case, I've been moving towards [fewer dependencies](https://chris.eidhof.nl/post/fewer-dependencies/) for years, maybe now even more? I'm curious about other changes that might happen as well.
