---
aliases:
  - /posts/boring-choice.html
date: 2015-03-05
title: The Boring Choice
headline: It's not all glitters and rainbows
---

I love new and experimental technologies. These days, I like trying to push Swift to the limits. I once wrote a Haskell web backend for financial transactions that used lots of generic programming. When Rails was just out, I started playing around with it (back when hosting was really complicated, except if you wanted PHP3 and MySQL). I've used all these things in production code, mainly in very small teams.

For [Scenery](https://www.getscenery.com), we also had to write a backend. I debated using Swift (but hosting would've been a pain), or maybe something like Haskell or Scala. The cool kids seem to be doing Go and Elixir these days. It'd have been lots of fun. However, I went for one of the most boring choices: Ruby on Rails. Rails is at version 4, and even though a lot has changed, it is also very mainstream these days. This means there's a lot less exciting technology to play around with.

There are a couple of reasons for choosing Rails:

* It's very widely used and tested. During this project, I haven't come across any bugs in Rails.
* It's really easy to get help. Most of the times, I don't even need to ask, but just google my problem and I'll quickly find out what's going wrong.
* There are *so many* libraries available. This is a killer feature: I wanted to keep a history of some of my model objects, and found out about [papertrail](https://github.com/airblade/paper_trail). For testing, I can use [FactoryGirl](https://github.com/thoughtbot/factory_girl). For authentication, we use [devise](https://github.com/plataformatec/devise).
* The eco-system is great, Heroku takes away a lot of deployment worries.

However, one of the most important things is that anybody on our team can contribute. With Haskell, there would have been a decent chance that I would be the only one even being able to build the project. With Rails, none of the people we work with had to learn anything new: they were productive immediately. I recently came across this African proverb, and thought it fitted well to our situation:

> *If you want to go fast, go alone. if you want to go far, go together.*
 
(Via [ryangraves](https://twitter.com/ryangraves/status/562492587039150080) 
)

So far, I'm really happy with the boring choice. Being able to get many hands on deck quickly really made a big difference. Hardly having to worry about stability and deployment helps me sleep at night. And finally, knowing that whenever I have a problem, others will have had the same problem saves me heaps of time. Luckily, we've written the Mac app entirely in Swift, with lots of functional code, so there's always a place left to play with new technology.

