---
aliases:
  - /posts/introducing-met.html
date: 2011-10-11
title: Introducing Met
---

After yesterday’s post, a lot of people contacted me with ideas for a name.
Thanks Pim, Martijn, Miles, Wilfred and Fabian (I hope I didn’t forget
somebody). Some liked James, some liked Meetups, all with good reasons.&#10;

However, one reply stood out: [Jurriaan](http://iksi.tv) had an idea for a more
minimalistic name: “Met”. Short and to the point. It’s about who you met. The
best thing is: in Dutch it means “with”, and this is about who you were with.
Awesome\!&#10;

Today I started designing a splash screen and an icon (see below). I also added
an optional passcode lock (as this can be very private data). Getting the design
and logic right took a bit of thinking and experimenting, but I think it’s good
now. It’s enabled whenever you start the app, or resume the app (for example,
after you lock the screen, switch to a different app or get a phone call).&#10;

Martijn and Eelco send in a bunch of very good feature requests / tips today,
thanks guys\! To give a glimpse of my next actions:&#10;

  - Pressed state for passcode buttons

  - Use secure passcode storage (currently, I hacked it together using
    NSUserDefaults, which is unsafe)

  - Swipe to delete

  - Text color for selected tableview cells

  - Link to Address Book from a contact / meetup

  - Screen rotation support (as this gives you a bigger keyboard)

I will also add search, eventually. It’s a bit complicated, because I’ll have to
compile my own sqlite library, and I’m a bit afraid that it might break in the
future. However, analysis paralysis is a horrible thing, and making decisions is
a good thing, so I decided to first do all the other stuff and then think about
it again.&#10;

![](http://dl.dropbox.com/u/1264810/blog-content/splashscreen.png
"Splash Screen")![](http://dl.dropbox.com/u/1264810/blog-content/icon-v1.png
"Icon")
