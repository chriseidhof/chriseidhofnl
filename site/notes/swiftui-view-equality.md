---
title: "SwiftUI View Equality"
created: 2025-07-10
---

Main pages: [Attribute Graph](/note/attribute-graph) and [Attribute Graph in SwiftUI](/note/attribute-graph-in-swiftui).

When a view gets marked as potentially dirty in the Attribute Graph, SwiftUI will compare the previous and next values. If it can "prove" the view is the same as before, it doesn't need to reevaluate the view's `body`. I'm not 100% sure how this works, this my current mental model:

- SwiftUI will look at all the properties of the struct and try to compare them. To compare it tries `Equatable`'s `==`, but will also do `memcmp`
- If a view type conforms to `Equatable` that conformance is used to detect changes. This might not be true, as there is also [`equatable`](https://developer.apple.com/documentation/swiftui/view/equatable()).

Closures in Swift can't be compared for equality. This means that storing closures in your view might lead to more view invalidations. See [Closures in SwiftUI](/note/closures-in-swiftui).

## References

> SwiftUI assumes any Equatable.== is a true equality check, so for POD views it compares each field directly instead (via reflection). For non-POD views it prefers the view’s == but falls back to its own field compare if no ==. EqView is a way to force the use of ==.
>
> - <https://x.com/jsh8080/status/1206617106160246784>

> When it does the per-field comparison the same rules are applied recursively to each field (to choose direct comparison or == if defined). (POD = plain data, see Swift’s _isPOD() function.)
>
> - <https://x.com/jsh8080/status/1206617804113432576>

- [The Mystery Behind View Equality](https://swiftui-lab.com/equatableview/). 
