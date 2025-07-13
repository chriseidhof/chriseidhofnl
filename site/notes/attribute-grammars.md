---
title: "Attribute Grammars"
created: 2025-07-13
---

Main article: 

- [Attribute Graph](/note/attribute-graph)

Attribute Grammars are a way of describing computations on a tree. An attribute is a property of a subtree. There are two kinds of attributes:

- *Synthesized attributes* is a property that gets formed by combining values from the children. In SwiftUI this is modeled as a preference.
- *Inherited attributes* are passed down the tree. In SwiftUI, environment values are inherited attributes.
