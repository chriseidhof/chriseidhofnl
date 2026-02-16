---
headline: Book Layout
title: "Weeknotes \u2116 15"
date: 2023-04-16
---

In Germany everyone gets time off for easter, and we spent time with friends and family. We also planted a bunch more things, really looking forward to summer where we'll have a lot of fresh vegetables. We're trying out a bunch of new things, so excited to see how well everything goes. The spinach, salad and onions are cropping up already.

I worked on getting our book building software up to date. There are many dependencies (rendering using attributed strings, drawing diagrams, our own layout implementation to help generate explanations, and so on). We were still depending on an internal version of [attributed-string-builder](https://github.com/objcio/attributed-string-builder) which was essentially an extend subset of the public repository.

I configured everything to (hopefully) be a very low-friction experience. I set up single Xcode project with virtually all code in Swift packages. For editing, we can just drop the package into the Xcode project and have a local editable version.

While we wrote the book using Dropbox Paper, we now are typesetting it using attributed strings. All of our previous published books were typeset using a mix of homegrown scripts, Pandoc, LaTeX and a bunch of other stuff. We always had the full setup working on at least one machine, but we decided to try a different setup for this release.

I also worked on a simple "connecting the dots" view to draw lines between arbitrary views in the view hierarchy. This works by propagating the center of each of the icons up (using anchors), and then drawing lines between all the connections. This technique is useful beyond this example, of course:

![](/post/2023-15/1.png)

I'll try to either write this up as a blog post or we'll record it for Swift Talk.

The painter spent last week painting the house, I helped with a bunch of preparation and final details. Next week we'll get the flooring done on the ground floor, and in a few more weeks we'll finally move in!