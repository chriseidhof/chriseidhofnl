---
date: 2021-07-03
title: "Rewriting objc.io"
headline: In Swift
published: false
---

A few weeks ago we started to rewrite [objc.io](https://www.objc.io), which was previously generated using Middleman (Ruby) and was an absolute pain for us to maintain: there were Javascript build steps, CSS compilation, NPM dependencies, Ruby dependencies and we were using an old version of Middleman. At some point it stopped working on almost all of our machines, even the Docker build stopped working. So we decided to bite the bullet and rewrite our site into Swift.

We had actually previously started building static site generators, and while you can get a lot done in an afternoon, you can also easily get lost for months in making it do everything for everyone. We never actually finished one.

This time around, we decided to be as practical as possible: we just wanted to get it done. No nice generic abstractions, no incremental builds, just get it out the door before we went on holidays. We wanted to rip out as much of the Javascript as possible, and ended up with only a tiny fraction of what we had, written in [VanillaJS](http://vanilla-js.com).

Previously, building objc.io took minutes (close to 20 minutes on our CI provider). Now we can locally build it in under 2 seconds. It's probably not too hard to shave off even more time, but this is good enough for us. There are a lot of cool things we could build on top of this, but for now, it's great: we have very few dependencies, and all the code is written by us and in Swift, which makes it much simpler to maintain.



Once we finished it I took a few early mornings and rewrote this site using the [same framework](https://github.com/chriseidhof/StaticSite/). It was a breeze and is much simpler to maintain (for me) than the previous version, which was written in Go (and before that, in Jekyll).
