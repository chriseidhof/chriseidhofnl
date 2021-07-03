---
aliases:
  - /posts/lots-of-test-projects.html
date: 2011-08-31
title: Lots of Test Projects
---

This might be a trivial thing, and I might be stupid for not having done with it
all my life, but this was a big insight for me. Only a few months ago, I really
started making lots of small test projects to only test out a specific feature
or solution. For example, I have a project that implements UITableViewCells with
XIBs, a test project for working with local notifications, a test project to
play around with rotation events and more. By doing these tests in a separate
project, I get the following two advantages:&#10;

**Lower barrier to testing the new feature**

Sometimes when I want to test out a new feature in one of my apps I get held
back by the fact that it might be complicated to implement. My code will get
cluttered and I have to wade through lots of old code. I need to do lots of
integration before I can even test it. This allows me to focus on the feature
first and integrate it once I’m happy with it.&#10;

**Future Reference**

Having these test projects around is great for future reference. The feature or
solution is implemented on its own, so when I want to use it in a different
project I don’t have to separate it out from the rest of the code.&#10;

**Question**

Do you have any test projects? How do you organize code for future reference?
Keep a notebook? Just dig into old projects? Grep your repos? [Discuss at Hacker
News](http://news.ycombinator.com/item?id=2945167).&#10;
