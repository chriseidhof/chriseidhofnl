# Layout using the Attribute Graph

Let's imagine we have an stack with two children:

```swift
HStack {
    Color.blue
    Nested() 
}
```

I think these are the constraints that happen when we lay out the following view:


![](/images/media/2024-11-1208-20PastedImage.png)

In other words, whenever either the color or the nested view changes its structure or internal state (e.g. the nested could have an internal state prop that causes it to reevaluate its body) the layout computer is marked as potentially dirty. It then relayouts. The actual size/position of either child is then dependent on the result of that (captured in `ChildGeometries`). This way, there is no cycle.

