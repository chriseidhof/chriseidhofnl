---
aliases:
  - /posts/monads-in-swift.html
date: 2015-06-01
title: Monads in Swift
headline: A very short explanation
---


Last year, many people have dipped their toes into functional programming. Unfortunately, one of the side-effects of learning functional programming is a great amount of people trying to explain monads. Many explanations I've seen were bad and only add to the existing confusion. This makes me quite upset sometimes.

So here's my very short (and slightly simplified) explanation:

> If you can define [`flatMap`](http://swiftdoc.org/func/flatMap/) for a type, the type is often called a monad. 

For example, you can define `flatMap` for `Array`. Array is a monad. You can define `flatMap` for optionals. `Optional` is a monad. You can also define `flatMap` for other types, such as functions, tuples, reactive cocoa signals, the `Result` type, and many more. Defining `flatMap` for a type often is really useful, even if it's not "[officially](http://en.wikipedia.org/wiki/Monad_(functional_programming)#Formal_definition)" a monad. That's really all there's to it. 

If you care for a longer explanation in Swift, then [Alexandros's articles](http://nomothetis.svbtle.com/the-culmination-i) are pretty good. If you prefer video, have a look at [John Gallagher's talk](http://2014.funswiftconf.com/speakers/john.html). Finally, if you like reading books, you can read my book [Functional Programming in Swift](http://www.objc.io/books/) or [Learn You a Haskell](http://learnyouahaskell.com).

