---
date: 2026-06-02
title: Learning in the age of LLMs
headline: The benefits of writing code by hand
---

I've been working on an experimental project with a friend, a static analyzer. This project has been in my head for years now, but it's quite ambitious and in my estimate, it'd take at least a few months before you'd have something decent.

My friend used AI to build it in a few days. He used a very sophisticated workflow (using [beads_rust](https://github.com/Dicklesworthstone/beads_rust)) so that multiple agents could work on tickets at the same time, almost completely unsupervised. The result was very impressive. However, some things were too complicated and it became hard to make progress.

We actually went through this loop three times. He threw everything away, started from scratch, and each time it got better. The results kept being more impressive but we always ended up throwing everything away.

At some point, we realized that our algorithm was too inefficient, walking the syntax tree many times, rather than doing a single pass. What really helped was sitting down together -- no LLM -- and writing a few sample implementations by hand. It felt very strange, as our progress was extremely slow, but we did walk away with a much deeper understanding, and if we do another iteration, we now know how to prompt the LLM.

As I make my money by educating people (writing books, running workshops, making videos) I think about this a lot.

What does learning look like in this new age? I find it hard to imagine that temporarily throwing out the LLM and doing stuff by hand is the best way, and yet, I don't know anything that's better currently. I tried letting the LLM teach me, give me exercises, ask me questions, and while it was helpful, it didn't make a big difference.

This quote really summed it up for me:

> you can outsource your thinking  
> but you cannot outsource your understanding

(Source: <https://x.com/karpathy/status/2049907410303865030>)

This is also written after thinking more about my [last post](/post/deep-understanding-while-using-llms/). How can we teach better in the age of LLMs? What skills do you need to have to build complicated software with these new techniques? I don't have the answers yet, and I'd love to know what your experiences are. Build faster, learn slower?
