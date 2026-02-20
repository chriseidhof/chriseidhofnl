---
date: 2026-02-20
title: Building Pancake
headline: A Mac App in a Month
published: false
---

In January, Nathan and I built a Mac app over the course of a month. Last year, I set the goal to collaborate more with other people in 2026, and Nathan was the first person I thought of. We've been doing SwiftUI workshops together throughout last year, and I really enjoy working with him. This post is a short story of what we've built and how we did it.

Our goal was to build and ship an app in a month. This is slightly ambitious, and we both succeeded and failed at the same time. We decided last minute that we'd build a Mac app to build static sites. Many static site generators come with all kinds of dependencies that eventually fail to resolve, and installation can be messy. With Mac apps, everything comes bundled and you get the experience of "batteries included".

We decided that we wanted to scope it down to just creating blogs (initially) and speed was a core consideration: it should be extremely fast to create a new website (creating a new file), to write something (integrated editor) and also to publish it (our own server). Because we use a native text editor, adding images is as easy as just dragging the image in. In the video below, you can see exactly this process with Pancake, our new app:

<iframe width="560" height="315" src="https://www.youtube.com/embed/A22kuc9k0Os?si=YYXs1_abT-Ci4pRy" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

We decided beforehand that we wanted to release this at the end of the month. In our case, this meant sharing the download link with just a few close friends. While we both have other obligations this month and next, we haven't found the time to polish this in a way that we feel comfortable putting this out as a "public" release. But if you are interested, just send one of us a message.

I'm proud of what we built in a month. I do think we made a few mistakes. First of all, I think we had too big of a scope given the constraints. Second, including a server component means a lot of responsibility (what if people upload malicious content? what if the server goes down?) that feels unrealistic to support as a side project.

We're not sure yet how we'll proceed from here. Is this a portfolio piece? Will we keep working on it? In any case, it has been a lot of fun. For me, the highlight was actually working together with Nathan, in person, in Paris.
