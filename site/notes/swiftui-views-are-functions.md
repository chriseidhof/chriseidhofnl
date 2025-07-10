---
title: "SwiftUI Views are Functions"
created: 2025-07-10
---

See also: [Defunctionalization](/note/defunctionalization).

You can think of a SwiftUI view as a defunctionalized function. The parameters to the function are the properties of the struct. The body is the return type of the function. We cannot call the function ourselves: instead, the framework can call it. It passes in things like the environment, the attribute graph handlers (e.g. to create new nodes, etc). The `body` contains the return type of the function call.

SwiftUI views are defunctionalized so that they can be compared for equality and prevent unnecessary view updates.
