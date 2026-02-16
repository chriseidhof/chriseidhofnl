---
headline: Context-Aware Styling
title: Semantic Colors and Styles
date: 2023-02-09
---

In SwiftUI, most colors are *semantic colors* that get resolved at runtime. For example, here are a few colors (rendered on macOS) in both light mode and dark mode. It's a little hard to see, but even colors like `.blue` and `.red` are slighly different:

![](/post/semantic-colors/1.png)

Note that the above colors might be influenced by other things as well. For example, they can change when you increase the color scheme contrast or enable other accessibility settings.

In my experience, most people build their apps in light mode, with dark mode often being added as an afterthought. This is absolutely fine. However, it does make sense to get into the habit of using `.primary` instead of `.black`, and using `.secondary` for a secondary color. Then those parts will automatically adapt.

By default, text (and shapes, etc.) are not rendered using the current foreground color (which is .primary by default) but using the current *foreground style*. Here's a rectangle filled with the four foreground styles:

![](/post/semantic-colors/3.png)

As far as I know, `Color.primary` and `Color.secondary` are (currently) not settable via the environment, but the foreground style is. For example, here's the same view, but with a `.foregroundStyle(.blue, .green, Gradient(colors: [.red, .yellow])` applied. Note that the tertiary and quaternary styles are optional. The tertiary style defaults to the secondary style, and the quaternary to the tertiary style. As you can see, you don't just have to use colors, you can also use any other type that conforms to `ShapeStyle`:

![](/post/semantic-colors/5.png)

There's a fourth useful style: `BackgroundStyle`. You would typically use it using `.background`, for example, like so:

```swift
Text("Hello, world")
    .padding(10)
    .background(.background)
    .padding(20)
    .background(.blue)
```

On macOS, this will default to white in light mode, and a dark gray in dark mode. Similar to the foreground styles, you can also set it using the environment:

![](/post/semantic-colors/7.png)

In general, stick to using `.primary` and `.secondary` colors when you can. Also use the semantic foreground styles and background style, and you will be well prepared to add dark mode support to your app. Of course, you could go much further and define your own stylesheet, pass it through the environment and rely on that, but the builtin semantic styles will support both color scheme changes and respect accessibility settings.