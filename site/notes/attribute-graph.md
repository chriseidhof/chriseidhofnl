---
title: "Attribute Graph"
created: 2025-07-10
---

The Attribute Graph is the system that turns SwiftUI views into an incremental program. It works by building a Directed Acyclic Graph of dependencies. It is based on the ideas of the [eval/vite system](https://repository.gatech.edu/entities/publication/50e6cde9-93e5-41f3-8a69-c7557ac58b2e). The "big idea" is that when a node in the graph becomes invalid (e.g. a state node changes) it recursively marks all dependent nodes as "potentially invalid". It also marks its direct outgoing edges as "pending". Whenever a node is requested (e.g. a display list output node), it goes through the following process to recompute:

- If the node isn't marked as potentially dirty, it uses the previous (cached) value.
- Otherwise, the node recomputes every incoming edge.
- If the node now has incoming pending edges, it recomputes itself, otherwise, nothing has changed so it doesn't need to recompute.
- The node marks all its incoming edges as not pending

(When there is an edge `A -> B` we say that `A` has an outgoing edge to `B` and `B` has an incoming edge from `A`. These are the same edge reference type, e.g. changing the pending state in the outgoing edge also changes the pending state of the corresponding incoming edge).

In the paper, an optimization is described for optional/conditional branches. For example, if we have a dependency on an if-statement, we only want to evaluate the body if the condition does not change.

The attribute graph is one way to implement [Incremental Computing](/note/incremental-programming) by only computing what's needed. It feels like phase one (marking all dependent nodes as potentially dirty) might be a bit expensive, but somehow that information needs to be propagated anyway. The underlying idea is much more general than just SwiftUI, it's akin to something like a build system (in fact, you can [use it as a build system](https://talk.objc.io/episodes/S01E457-swiftui-as-static-site-generator-part-5)).

## Related

- [Attribute Graph in SwiftUI](/note/attribute-graph-in-swiftui)
- [Attribute Graph Implementations](/note/attribute-graph-implementations)
- [Presentation: Attribute Graph](/presentations/attribute-graph/)

## External

- [Untangling the AttributeGraph](https://rensbr.eu/blog/swiftui-attribute-graph/) by Rens Breur. This article really helped me understand things. You can see the three different states (up-to-date, pending and potentially dirty) as different colors in Rens's diagrams.
- [AGDebugKit](https://github.com/OpenSwiftUIProject/AGDebugKit) will help you visualize the *real* attribute graph.
- [Optimize SwiftUI Performance with Instruments](https://developer.apple.com/videos/play/wwdc2025/306?time=1226) (WWDC Video). This also explicitly talks about the Attribute Graph.
