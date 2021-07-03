---
date: 2016-05-26
headline: We're not doomed yet
title: Dynamic Swift
---

Recently, [Brent](http://inessential.com) and others wrote a lot about the lack of dynamic features[^1] in Swift. I tried distilling Brent's thoughts, and came up with the following summary:

- It's easy to write code in AppKit and UIKit, because many things just work, without having to write a lot of code. 
- AppKit/UIKit are written in Objective-C, and use runtime programming to remove boilerplate. 
- Therefore, we either need these same features in Swift, or need to find a different way of solving some problems.

I think we don't need all the runtime programming features from Objective-C.

As long as AppKit and UIKit will be around, we'll have Objective-C and its runtime. If Apple releases a Swift-only successor to either one of these frameworks, I'm confident that they will do a good job: they'll make us write less boilerplate, rather than more. 

Let's look at a completely different context: web programming. I've seen amazing web frameworks that rely a lot on runtime programming (stuff like Rails, but also [Seaside](http://seaside.st), back in its day). But, there are web frameworks in languages like Haskell, Scala and C# that use features like protocols, datatype-generic programming[^2] and passing around functions to reduce boilerplate. With both approaches you can get short, simple, maintainable code that's easy to write. 

Yet, techniques you don't know will almost always seem more complicated at first. I tried arguing with a Haskell programmer that runtime programming can be useful. I tried arguing with a Ruby programmer that static types can be helpful. To both, it seemed unnecessary and complicated. They've been writing great code without those features.

Brent, if you read this, I'd like to offer you a free copy of my books. Just send me an email. There are some techniques in there that will show how to replace runtime programming with things like functions, or protocols. These techniques definitely won't solve all your problems. I do think they will show you some ways in which you can write short, simple, and maintainable code in Swift today, without having to resort to runtime programming. 

[^1]: To have a productive discussion, I think it's important to understand about which dynamic features we are speaking. Dynamic can mean so many different things: KVO/KVC, late binding, subclassing, swizzling, dependency injection, reflection, runtime casting, and so on. Because the word dynamic means different things to different people, the discussion has been (and will be) hand-wavy. Swift has a lot of dynamic features, but they are different: protocols, safe runtime casting, passing around functions, and so on.

[^2]: Datatype-generic programming is a cool technique in functional programming. It allows you to write methods that operate on the structure of the data. For example, it would let you write something like an NSCoder implementation that works on all structs and classes. It's much the same as writing it using runtime introspection, except that it's type-safe, and more importantly, the compiler can help you catch mistakes. Unfortunately, datatype-generic programming isn't yet (but almost!) possible in Swift.
