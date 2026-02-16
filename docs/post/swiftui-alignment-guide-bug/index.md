---
title: SwiftUI Alignment Guide Bug
date: 2025-05-05
---

For the last few years SwiftUI's [alignment guides](https://www.swiftuifieldguide.com/layout/alignment/) have been broken in combination with `if`-statements. Here's a small example:

```swift
struct ContentView: View {
    var value = true
    var body: some View {
        Color.green
            .frame(width: 100, height: 100)
            .overlay(alignment: .topLeading) {
                if true {
                    Circle()
                        .alignmentGuide(.leading) { $0.width/2 }
                }
            }
    }
}
```

![](/post/swiftui-alignment-guide-bug/1.png)

I expected the horizontal center of the circle to be aligned with the leading edge of the green color. Instead, both views are centered on top of each other. When you remove the `if` it works as expected. If you replace the `if` with an `if/else` it's still broken, but if you replace the `if` with a `switch` it does work as expected.

Depending on your use case you can also replace the `if` statement with an opacity modifier or something similar.

(*FB13676056* for Apple folks. Last tested on Xcode 16.3).