---
title: "Attribute Graph in SwiftUI"
created: 2025-07-10
---

Main page: [Attribute Graph](/note/attribute-graph). 

In this article, I say *node* but in the Attribute Graph this is typically called an *attribute*.

The Attribute Graph in SwiftUI builds up a graph of the SwiftUI views we declare. It creates nodes for the views, the view's' inputs and the view's outputs. The graph is mostly static. While properties change a lot, nodes mostly stay persistent and don't get recreated all the time.

- For each SwiftUI view, a `body` node will be part of the graph, containing the entire view body
- A `State` property in a view gets turned into its own node. Every view body that reads the state property creates a (dynamic) dependency on that node.

Views are compared for equality to see if they are marked as dirty (and need to reevaluate their body). See [view equality in SwiftUI](/note/swiftui-view-equality).

## Environment 

As the Attribute Graph builds up, SwiftUI keeps track of the current environment node. If a view reads from the environment a dependency is created. If a view modifies the environment, the modified environment points to the previous node, and the subtree will receive the modified environment node. You can see this in [my presentation](https://youtu.be/dCSf9nR6SOQ?si=_aoisG8CnYkc-Peq&t=579) at 9:39.

## Preferences

I'm not quite sure yet how to implement this, TBD.
