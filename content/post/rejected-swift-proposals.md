+++
aliases = [
  "/posts/rejected-swift-proposals.html"
]
date = "2016-04-22T15:46:42+02:00"
headline = "What we can learn from the rejections"
title = "Rejected Swift Proposals"
+++

Not too long ago, we finally shipped [Advanced Swift](http://www.objc.io/books/advanced-swift). It was a long process, but I'm really happy about the result. Just before we finished it, Swift became open-source, the mailing lists opened up, and many GitHub repositories appeared.

At first, I subscribed to all the mailing lists, and added a filter to move them into a separate folder. There was so much discussion that I couldn't keep up at all - at least not while finishing the book. I was so overwhelmed that I completely stopped reading the lists, let alone participate in the discussions.

In the next edition of Advanced Swift (the update for Swift 3) we want to include a chapter about the history of Swift. At the beginning of this week, I set aside a day to read through all current proposals in detail. Not only to understand what is coming up, but also to learn what got rejected. With most rejections, the core team included a good rationale that can help us understand how they see the language evolve.

One interesting thing I found while going through all proposals is the ever-present discussion about "readability". I'm convinced more than ever that readability is subjective in many cases.

I am going to write a series of posts about all the proposals. First off, let's start with all the rejected proposals. Here, it's especially interesting to see why they got rejected, and I've selectively quoted the rationales given by the core team.

## [SE-0009 Require self for accessing instance members](https://github.com/apple/swift-evolution/blob/master/proposals/0009-require-self-for-accessing-instance-members.md)

This proposal wants to make `self.` mandatory for all instance members. The author feels that requiring `self.` increases readability, and make everything more consistent.

> Mandatory “self.” introduces a significant amount of verbosity that does not justify itself with added clarity. While it is true that mandatory “self.” may prevent a class of bugs, the cost of eliminating those bugs is fairly high in terms of visual clutter, which goes against the generally uncluttered feel of Swift. Paul Cantrell put it well in his review <https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20151214/002910.html> when he said, “anything that is widely repeated becomes invisible.” Swift aims to avoid such boilerplate and repetition in its design, a principle also espoused by the Swift API Design Guidelines <https://swift.org/documentation/api-design-guidelines.html>.
>
> The requirement to use “self.” within potentially-escaping closures is a useful indicator of the potential for retain cycles that we don’t want to lose. Additionally, developers can optionally use “self.” when they feel it improves clarity (e.g., when similar operations are being performed on several different instances, of which “self” is one).
>
> The name-shadowing concerns behind the mandatory “self.” apply equally well to anything found by unqualified name lookup, including names found in the global scope. To call out members of types as requiring qualification while global names do not (even when global names tend to be far more numerous) feels inconsistent, but requiring qualification for everything (e.g., “Swift.print”, “self.name”) exacerbates the problem of visual clutter. 
>
> [Rationale](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160104/005478.html)

The author of the proposal feels that requiring `self.` makes the code more readable. I can see why, yet still feel the opposite. This is one of those cases where we can hardly say anything objective about it being more readable, instead, we should probably say "it's more readable for me".

## [SE-0010 Add StaticString.UnicodeScalarView](https://github.com/apple/swift-evolution/blob/master/proposals/0010-add-staticstring-unicodescalarview.md)

This proposal wants to make it possible to make static substrings of `StaticString` by adding a new type `StaticString.UnicodeScalarView`.


> While the addition of StaticString.UnicodeScalarView is a useful feature by itself, the core team felt that it would be inconsistent just to add this narrow set of APIs for Unicode scalars. (...) If StaticString is to gain Unicode support, it should be done comprehensively, not piecemeal. Moreover, *with the aforementioned String re-evaluation underway*, it is possible that StaticString itself might change considerably or even be obsoleted.
>
> [Rationale](http://thread.gmane.org/gmane.comp.lang.swift.evolution/7697)

Emphasis mine: strings are being re-evaluated. I'm not sure what will happen to the `String` type. I can imagine that it could get simpler somehow.

## [SE-0027 Expose code unit initializers on String](https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md)

This proposal wants to make it easier to build Swift strings from C strings.

> At this point, the core team feels that we have not fully explored the design space here, and that known alternatives (e.g., making the UTF-16 and UTF-32 views of a String mutable collections) might provide a better long-term solution. Moreover, the String type itself is undergoing a significant re-evaluation, so the core team feels that improvements to String should be delayed until the newer design is better understood.
> 
> [Rationale](http://thread.gmane.org/gmane.comp.lang.swift.evolution/7695)

Just like before, it seems like big changes will happen to the `String` type.

## [SE-0024 Optional Value Setter `??=`](https://github.com/apple/swift-evolution/blob/master/proposals/0024-optional-value-setter.md)

This proposal wants to add another setter, `??=`, which sets the left-hand side to the value of the right-hand side (but only if the left-hand side is `nil`).

> The proposal is rejected. While the ‘??=‘ operator’s semantics are clear and fit with other compound assignment operators, the use cases are not strong enough to motivate inclusion of this operator. [Radek’s lukewarm +0.5 review](http://thread.gmane.org/gmane.comp.lang.swift.evolution/6895) captures the sentiment of the core team fairly well (as was echoed by others): one very common use case in the Ruby’s similar ||= operator is to assign a default value to an optional parameter or a local variable. However, neither case works well in Swift because ??= does not erase the optionality of the variable (and cannot be used to change a parameter now that var has been removed from parameters). Property access and subscripting could still benefit from ??=, but the latter case is likely to be handled better by a Dictionary subscript operator that can substitute a default value (see, e.g., [Joe Groff’s suggestion](http://thread.gmane.org/gmane.comp.lang.swift.evolution/6895)).
> 
> [Rationale](http://article.gmane.org/gmane.comp.lang.swift.evolution/7694)

I've used `||=` in Ruby as well, and really like it there. But with Swift's Optionals, I never felt the need for this. As an aside, the mentioned dictionary subscript operator is really cool. We use it in the functions chapter of Advanced Swift, in a way very similar to this: <https://twitter.com/AirspeedSwift/status/626701244455895044>


## [SE-0018 Flexible Memberwise Initialization](https://github.com/apple/swift-evolution/blob/master/proposals/0018-flexible-memberwise-initialization.md) (Draft)

This was a really long proposal, and really long rejection [rationale](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160111/006469.html) mail. It's about the automatic memberwise initializers that get generated (e.g. when you create a struct). The proposal wants to make this possible in more places, and make it easier to control this. The core team decided that it isn't in scope for Swift 3. An interesting meta-point they raised it that the length of the proposal was off-putting for many people. Another thing I learned is that the Swift team really strives for predictable models. You can also see this in the accepted proposals, there are a few that really make the language more predictable and consistent (e.g. [named first parameters](https://github.com/apple/swift-evolution/blob/master/proposals/0046-first-label.md)). 

## [SE-0056 Allow trailing closures in guard conditions](https://github.com/apple/swift-evolution/blob/master/proposals/0056-trailing-closures-in-guard.md)

This proposal is about letting trailing closures in `guard` conditions compile. For example, like this:

```swift
guard let object = someSequence.findElement { $0.passesTest() } else {
  return
}
```

Currently, it doesn't like the trailing closure when using a `guard` (or `if`/`while`), and it needs to be written with parentheses around the closure. 

The proposal was [rejected](https://lists.swift.org/pipermail/swift-evolution-announce/2016-April/000108.html) with a very short sentence:

> The core team felt that the benefits from this change were outweighed by the inconsistency it would introduce with `if` and `while`.

Interestingly, it was proposed by Chris Lattner, a member of the core team. Again, I can see how they made the decision. If you look at it from being able to write it in a `guard`, it seems like a logical proposal. However, once you can write trailing closures in a `guard` condition, you'll probably be surprised that you can't write them in `if`/`while`.


---

In the next post, we'll look at accepted proposals. Stay tuned!
