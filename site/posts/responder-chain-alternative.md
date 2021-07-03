---
advanced_swift: true
date: 2016-06-03
headline: Simple vs. Easy
title: Responder Chain Alternatives
---

There's been some recent talk about the [responder chain](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/EventOverview/EventArchitecture/EventArchitecture.html#//apple_ref/doc/uid/10000060i-CH3-SW2). The responder chain works on a tree structure: the view hierarchy plus some other things. An event or action gets sent to a certain view (a node in the tree structure). Until it gets handled, it moves up the tree towards the root, going through all superviews, all the way until the `NSWindow`, up to the `NSWindowController`. You can even modify this tree structure, and insert your own responders. Depending on what you're building (e.g. a document-based application), the responder chain can even be more advanced.

The responder chain is really powerful, and saves you from writing boilerplate. It is built on top of runtime programming. For example, an action consists of a selector (in other words: a string) and the sender object. Using introspection, the application tries to dispatch an action through the responder chain, starting with the first responder, all the way up until some object handles the event.

When you create a new Mac application, it comes with a menu by default. The menu items in send actions, for example, `paste:`. If you want to implement paste support, it's really easy. The only thing you'll have to do (besides the domain logic of pasting) is implement a `paste:` method somewhere in an object that will be in the responder chain. That's it. Menu items can even be enabled and disabled automatically if you implement `validateMenuItem:`.

This is easy to write, but you do pay a price: maintaining these actions is more difficult than writing them. It's hard to change code: if you ever want to refactor (for example, if you choose to rename the action), you'll have to be very careful to change it in all places in your code, and in the Interface Builder file. If you forget to change things in one place, Interface Builder might be able to tell you this. But not always.

The responder chain is easy, but it's not simple[^simpleasy]. There is a lot of magic behind the scenes. It makes it hard to change your code. In addition, the responder chain on the Mac is complex: you need to have the order of the chain in your head (or read the documentation) to work effectively. You need to know your view hierarchy, and changes you intend to be local can accidentally be global.

The responder chain is cool, but I'm not sure if we need to replicate it in Swift. Rather, we could try to think of a way that is just as easy as the responder chain, but also *simple*. It should be easy to refactor code. It should be easy to understand. It should be easy to debug. In order to make a local change, you shouldn't have to worry about the global effects. I'm not sure if we can solve all these issues, but I'm pretty sure we can solve a few of them.

(Functional) Reactive Programming[^3] might be one solution to this. I'm not sure, because I have never applied FRP in production. The idea behind FRP is simple (and easy), but all implementations I've tried aren't easy, nor simple. I think a React-like architecture is really cool, it's simple, it's easy, but then you want to do animations: not so easy.

In short, I don't know a good alternative to the responder chain. I don't think FRP will be a silver bullet. For now, we can keep using the responder chain anyway, because Cocoa and Objective-C are probably not going anywhere[^lindy]. Sometimes, I hope that the answer comes when the Interface Builder team starts talking to the SourceKit API, and really leverage all this deep knowledge about the current program. In the mean time, we can try to come up with solutions ourselves, by keeping the following in mind: it should not only be easy, but also simple.

[^simpleasy]: See Rich Hickey's amazing [presentation](https://www.infoq.com/presentations/Simple-Made-Easy), or read the [transcript](https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy.md).

[^lindy]: If I understand the [Lindy effect](https://en.wikipedia.org/wiki/Lindy_effect) correctly, Cocoa might be around for 30 more years...

[^3]: It's not so much about the functional part of FRP, but more about the reactive part, as pointed out by [JP](https://twitter.com/simjp/status/738830379298131969).
