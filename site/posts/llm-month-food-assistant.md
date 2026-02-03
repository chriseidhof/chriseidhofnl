---
date: 2026-02-03
title: "Food Assistant"
headline: "Month of LLMs"
---

This month, I want to focus on using LLMs more, and AI in general, so I'm working on a bunch of projects. I've been using Claude (and more recently Codex) over the last year or so, but now I'm actually using them very intentionally with the goal of understanding how to work with them better and to understand what the possibilities are.

This morning I built a small custom agent. I used the new Codex Mac app to build this agent from scratch, and of course I've been inspired by the work that [Peter](https://steipete.me) has been doing with [OpenClaw](https://openclaw.ai). This agent is taking care of my food, so it has an idea of what I have in stock. It knows about my allergies, my dietary wishes, and it has recipes and a grocery list. It also has a list of dishes I enjoy making and eating. I managed to get it up and running in about half a day.

I started by creating a new TypeScript project and using the [Agents SDK](https://openai.github.io/openai-agents-js/) from OpenAI. The main interface is a Telegram bot because Telegram has strong support for bots, and that way I have both a text and a voice interface for free. If I send it a voice message, it uses ffmpeg to convert the audio, then I send it over to OpenAI to get it transcribed.

The agent operates on Markdown files; they all live in a Git repository, and every time I change something it gets committed automatically. Also, the agent pulls from Git automatically. I've used a [GitHub deploy key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys) to give the agent access to just the one repository. This gives me persistent memory, change tracking, and I can just host my agent on Fly.io. I'm really liking this pattern. I wonder if I could extract it out into something more reusable. I

One of the fun things is that the system prompt is in a Markdown file as well, so I can actually tell my agent to change its prompt and that will automatically get reloaded. This is a powerful concept. Of course, things like OpenClaw can completely rebuild and rewrite themselves, which is even more powerful. I did not want that for this project, but being able to talk and chat to my software in order to then rewrite itself is very powerful.

I finally added some support for images and meal planning as well, so I can be a little bit smarter about going shopping and reusing things and meal prepping certain ingredients. All in all, it was half a day of work, and it's already very useful. It's online all the time, I can talk to it, it has no access beyond the files it needs, and we'll see how I will use this in the future.

Today, I used it to plan my next four meals and my shopping list. It updated my plan, gave me a few recipe ideas and made me a shopping list.
