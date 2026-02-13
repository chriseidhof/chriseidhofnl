---
date: 2026-02-13
title: Self-Forking Agents
headline: Teaching an Agent to Improve Itself
---

Over the last weeks, I've been experimenting with building agents. An agent in itself is a simple concept. It's a loop where you give it input, and then the LLM responds. Crucially, you can tell the LLM to use specific tools that you describe, and the LLM's response can include calls to those tools.

There is an inner loop where, before accepting the next user input, you process all the tool calls and feed that information back into the LLM. And it turns out you can write an agent with very few tools. The [PI agent](https://github.com/badlogic/pi-mono) uses just four: read, write, edit, and bash.

I built a few things on top of Pi. I made a Mac GUI using SwiftUI, which turned out to be relatively useless for now. Then I wanted to take a key concept from [OpenClaw](https://github.com/openclaw/openclaw), which is *self-improving code*. Here's the goal I had in mind: I wanted to talk to an agent (running on a server) through Telegram and tell it to improve its own code. To do so, I wanted it to fork itself using a git worktree, make the changes, verify them and then open a pull request. This way I can talk to my agent and have it improve itself over time.

It took me a few hours of prompting to get this up and running. First, I created a *self-fork* skill. A skill is just a text file that describes how to do something specific, and it took a few tries to get this right. One of the key insights was to have as little code in the text as possible. I moved almost all the code out into separate scripts. This makes the skill much more reliable. Given what I learned, I do think I can prompt my way to the same result much quicker now.

For me, this is the way I like to learn. I recreate things from the ground up so that I understand how it works. And I feel that I've now understood a key part of how to build something like [OpenClaw](https://github.com/openclaw/openclaw). Of course, there is a lot more to it, but to me, this was one of the pieces I wanted to see for myself.

If you want to try this yourself, here's the goal to aim for: build an agent that you can talk to through a chat app. You should be able to tell the agent to improve itself and get that improvement out as a GitHub pull request. The agent needs to run on a server so that you can always access it. Getting this loop closed felt really magical to me. Good luck!
