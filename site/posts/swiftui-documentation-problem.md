---
date: 2023-10-16
title: "The SwiftUI Documentation Problem"
headline: We Need to Talk
published: false
---

SwiftUI has a serious documentation problem. When we teach our workshops, we often talk to people who've written SwiftUI for multiple years, and they don't understand the fundamentals. These are typically very smart people, yet they spend (and spent) too much time guessing how things behave.

If you want to understand the way SwiftUI's layout system works, the way the state system works, the way [preferences](https://developer.apple.com/documentation/swiftui/preferences) work, or the way [animations](https://developer.apple.com/documentation/swiftui/animatable) work, Apple's current API documentation won't be of much help.

SwiftUI views get converted into attribute graph nodes when they're rendered. You need to understand the lifecycle of this in order to be effective with SwiftUI. There's no mention of this anywhere in Apple's documentation, and there's no written documentation that explains the lifetime of SwiftUI views[^1]. Likewise, if you want to something as simple as accessing a `@State` property, you can only do this inside the body of a view. This is not documented. Almost everyone makes the mistake of trying to mutate state properties in the view's `init`. It should be basic knowledge.

For years, the layout mechanism was completely opaque. It almost feels like the documentation is actively trying to avoid mentioning that views choose their own size in response to a proposal (yet this is the essence of how SwiftUI layout works). On the other hand, the [frame](https://developer.apple.com/documentation/swiftui/view/frame(minwidth:idealwidth:maxwidth:minheight:idealheight:maxheight:alignment:)) modifier assumes you know all about proposing and choosing sizes.

Almost everything I know about SwiftUI and wrote about in our book I have learned through our own research. The things we describe in our book are not weird edge cases or obscure APIs, they are the fundamentals of SwiftUI, and they're not documented by Apple. Understanding a framework as important as this should not be an empirical science.

When we teach our SwiftUI workshops, we often hear people gasping for air before saying "aha!" when we teach these fundamentals. They had an inkling of how things worked, but were never able to completely put the pieces together. You won't learn these things from Apple's current documentation.

I think the time has come for Apple to do something about this. The lack of conceptual documentation is harmful for the ecosystem at large. There is so much lost developer time, guesswork and frustration that could be prevented. Please note that this article comes from a good place: I love SwiftUI and think it's amazing, and I wish more people would understand it.

[^1]: There is a good explanation in [this WWDC talk](https://developer.apple.com/wwdc21/10022), but important things like these should not be hidden away in videos or transcripts.
