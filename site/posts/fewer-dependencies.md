---
title: Dependencies
headline: Why we got rid of most dependencies
date: 2021-07-06
---

Over the last years, I've noticed a change when programming. I used to liberately add third-party dependencies to my code. I would use libraries, or even build on top of frameworks like Ruby on Rails. These days, I tend to use few or no third-party dependencies.

It's not that I don't like third-party code. However, a lot of the projects I've worked on have been around for quite a few years — which also means keeping their dependencies up to date. Sometimes the API breaks, sometimes there are security issues, sometimes a dependency is just not maintained anymore, and very often, a dependency somehow stops working when I upgrade my machine.

I hate dealing with this. My app was working fine, and now I have to debug why Nokogiri does not install, or making sure that my app works with the most recent version of Rails, or seeing one of those Javascript libraries pull in hundreds of additional dependencies. And once I do get everything working again, it turns out one of the dependencies updated itself and doesn't work with my code anymore.

A few years ago, we rewrote our [Swift Talk](http://talk.objc.io) backend from Ruby on Rails to Swift ([here's the code](https://github.com/objcio/swift-talk-backend)). Our Ruby backend had over 70 gem dependencies. The Swift version has fewer than ten dependencies, only two of which we don't maintain ourselves (SourceKitten and SwiftNIO). We can always compile this without any problems, even after we haven't worked on it for a while. (As an aside, rewriting from Ruby to Swift also made everything much faster and way less resource-intensive.)

A few weeks ago, we also rewrote the code that generates objc.io (a static site) into Swift[^1]. Previously, we used an old version of Middleman with a whole bunch of gems, which themselves come with their *own* dependencies. Additionaly, there were git submodules, Bower, NPM and CSS compilation steps. Bit by bit, it stopped building on all but one of our machines, even the Docker version somehow didn't work anymore.

At some point, we were tired of it, and wanted to change something on our website. We decided to bite the bullet and just rewrite it in Swift with very few dependencies[^2]. While we might still have issues whenever these dependencies change, at least we'll probably get type errors and won't have any silent issues. The rewrite took us only about a week and a half. I expect that, for the next few years, we can just keep updating and expanding our site with minimal effort spent on maintaining dependencies. While were at it, we also ripped out almost all Javascript, keeping only a few essential bits. (As an aside, the Ruby version used to take minutes to generate, whereas the Swift version is done within two seconds).

There's a fine line between minimizing dependencies and [NIH syndrome](https://en.wikipedia.org/wiki/Not_invented_here). I'm not sure that our approach is the best way to do things, but I'm really happy that we have full control over our code, and — more importantly — that everything fits into our heads.

There are many upsides to fewer dependencies: we understand the code, it's written in our own style, we don't have to spend time keeping the dependencies up to date, and we can fix any issues ourselves without having to wait for something to be approved. However, there are some downsides as well. For example: our code isn't as battle-tested as other code out there. (This is why we used cmark rather than our own half-working Markdown parser that only parses an extended subset of Markdown.) Another drawback is that there are some really useful features in existing frameworks that we had to write ourselves. We wanted to have asset hashing, and while this is a single flag in most static site generators, we instead spent a morning implementing this.

All in all, I do have to say that minimizing dependencies works really well for us. We have done this with a number of projects, and it's just so nice to be able to just run a project that you've left alone for weeks, months or even years, and everything still works.

[^1]: We took a very *practical* approach and just wanted to get it done before our holidays. We did pull out some of the code into a library, and this very site is generated using that same code. [Here's](https://github.com/objcio/StaticSite) the library.

[^2]: To be fair, we did end up depending on [Yams](https://github.com/jpsim/Yams), [SwiftSyntax](https://github.com/apple/swift-syntax), [Swim](https://github.com/robb/Swim) and [cmark](https://github.com/jgm/cmark).
