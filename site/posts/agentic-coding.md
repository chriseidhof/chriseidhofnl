---
date: 2025-07-08
title: Agentic Coding
headline: Experimenting with SwiftUI
---

I teach SwiftUI for a living. Through our [workshops](https://www.swiftuifieldguide.com/workshops/), books, and videos we try to help people build a mental model of how SwiftUI works as well as show some of the details. I really, really enjoy doing that and have built a successful lifestyle business doing just that.

> Note: this post was written by me, not by an LLM. I don't feel comfortable at all letting it do that.

To me, the quality of the LLMs and their tooling (looking at you, Claude Code) feel like a threat to my business. Will people still need to learn SwiftUI? Do we need to teach in different ways? What will the LLMs be capable of in a year from now? Will there still be enough people to teach?

I'm in an ongoing process of figuring this out. I've experimented a whole bunch with LLMs, have read and watched many things ([Essential Reading for Agentic Engineers](https://steipete.me/posts/2025/essential-reading) is a really good start). In this post, I'll try to share some of the stuff I learned. I'm by no means an expert, but I still hope that this is useful.

## Easy Things You Can Do Today

If you are not using an LLM or have not had success using it ("it just didn't work for me") here are some quick ideas in which it can help you today. I'm mainly using Claude Code (and sometimes the Claude desktop app):

Using the Claude desktop app, you can very quickly build basic prototypes. This can be extremely helpful in understanding a problem and can be a big motivation to build it "properly". If you need a quick web service prototype, you can use tools like [val.town](https://www.val.town) to host (and further refine) stuff.

If you are working with an existing code base and don't want an LLM touching your precious code (this is often how I feel!), you can have an LLM build little debugging tools. For example, I had it visualize some internal state for me during debugging. Seeing the current state in my app was much quicker to parse than reading through the debug output. Once I found the problem I immediately deleted the debug code.

I found it helpful to get a quick grasp of existing code. I just took a bunch of code and asked the LLM to explain it. I absolutely do not feel confident about my understanding after reading the explanation. It just helps to get a first basic feeling so that I can explore further. 

I'll also ask an LLM about possible algorithms I could use to solve problems. I'll tell it I know Swift, Haskell and Typescript. I'll make it generate examples. I don't trust the output, and will verify things myself.

I found it helpful to ask an LLM to give me options to implement stuff (while also telling it to explicitily not implement it). I'll use it to help me think through problems. 

 If I feel stuck on something or somehow can't get started, I can always prompt the LLM to start on something tiny. I can then carry that momentum forward myself.

If I need to generate mock data (e.g. for my workshops) I'm often too lazy myself to really put time into it. Even the builtin LLM to Xcode has been giving me way better results than doing it myself.

Personally, if I think of my app's architecture, I'm much more willing to let an LLM generate "leaf nodes" that can easily be replaced rather than trusting it with "core" nodes that require much more consideration.

I did find that getting better at prompting really can improve the results you're getting.

## Weird Things

Things are changing *so* quickly. It's hard to keep up with new things, what might have been true last month is not true anymore this month. My setup is pretty simple: I mainly use Claude Code and the Claude desktop app. 

I often "feel bad" about deleting code that was just written. The AI will often just write the wrong thing. I take full responsibility for the result (I either need to improve my instructions or write it myself). It's okay to delete the just-generated code, ignore the responses and start over. However, I do still anthropomorphize the LLM: it'd be hard to tell a human to throw away what they just did, and I still feel a bit bad about it when doing that to the LLM.

I'll have the LLM do non-code stuff as well. For example, you can tell Claude Code to create a git commit, to set up parts of your dev environment, and so on.

## What Doesn't Work

I don't really believe in "vibe coding" beyond basic prototypes. To build quality non-trivial software, I think you (still?) need to have a very good understanding of what's happening. For example: I asked Claude Code to add an inspector to an app I'm working on. Rather than using the [inspector API](https://developer.apple.com/videos/play/wwdc2023/10161), it generated an HStack. When I specifically told it to use the inspector API, it did do so. I still needed to change things myself. In other words: writing code with AI is absolutely not a fully automated process for me. I don't shy away from writing code.

I had some fun with a side project and it looked like things were going well. I was doing TDD and iterating quickly. I got lazy, did not review the code, but trusted my tests. Turns out, the agent had been adding special cases to the code just to make the tests pass.

Another "fun" thing is that these models are not lossless. For example, I wanted to move some code to a different file. While doing this, Claude Code just hallucinated some new code and changed some of the old code. This becomes hard to spot when the diff gets large (when the diff gets too large, I'll just undo the change and do stuff myself).

I had people in my workshop that used an LLM to generate a whole bunch of code that wasn't working and not using the suggested APIs. Instead of using SwiftUI's animation system, they animated with a timer. They were solving the wrong problem in the wrong way. The goal of the workshop was understanding, and not getting through the exercises as quickly as possible.

## You Still Need to Understand What's Happening

I feel like I still need a very strong understanding about the APIs that exist, about how to structure the code and about the mental model behind SwiftUI. My iterations are pretty short. I want to understand *exactly* what is happening.

[Peter](https://bsky.app/profile/steipete.me) seems to have a lot of success with a more hands-off approach, letting his agents run for a very long time.

## Feedback Loops

The current thing I'm thinking about is how we can increase the feedback loop between the agent and me. This is the current loop:

- I prompt the agent to make a change.
- The agent starts working, this often takes a while (30s to a few minutes). The better my prompt is, the quicker the work often goes.
- The agent verifies its own work (by running the tests, compiling the project, etc.)
- I need to verify what happened. Because I do a lot of GUI stuff, this often involves running and clicking through the app (or opening different previews in Xcode).
- At this point, I'll have three choices: I commit when I'm happy, I iterate to refine the solution, or I start over.

I think the second step (agent building things) will get much quicker over time. I think the third step (agent verifying its own work) still has a lot of untapped potential. But by far, the slowest part of the loop is me verifying what happened.

## Opportunities

- It's hard to keep up. A good reliable source of information could be helpful. (I'm considering turning what I've learned (and will learn) into a workshop).
- We can build tools to help the agent work more effectively. Linters, type checkers, tests, but possibly also other methods of formal verification. 
- We can build tools to shorten the feedback loop (how can *we* verify the agents' work more quickly?)
- ...

## Conclusion

I don't see a future without agentic coding. It feels like we're just at the start. I think we still need a very strong understanding of what's happening to be truly effective. It feels like things are changing very quickly, and none of the above might be true in a few days, weeks or months.
