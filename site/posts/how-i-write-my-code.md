---
aliases:
  - /posts/how-i-write-my-code.html
date: 2012-01-19
title: How I write my code
---

Recently I saw a couple of posts on how people write their code. I found it
inspiring, and part of the reason I’m writing this article is that I don’t know
how I write my code (not explicitly, at least).&#10;

Most of the time, I know what I’m going to build a few days, weeks or even
months beforehand. During the time between idea and building, I think about it.
I don’t set apart time to do that, it just happens. If the problem is
interesting, I’ll think more about it than a problem with a straightforward
solution.&#10;

Once I start coding, most of the times I start with the hardest problem. For
example, if I would build a Google Maps like application I would start by
implementing the map view and the tiles. Later on, I will add the more “boring”
parts. The upside of this approach: you will discover the hard problems early on
in the process. The downside: you sometimes have to push yourself to finish all
the little details. Sometimes I lose interest in the last part of the
process.&#10;

During the coding, I’m logging a lot. I’m a big logger. I love NSLog,
console.log, println and their friends. I once heard that there are two cults of
programmers: those who log, and those who use breakpoints. I hardly ever use
breakpoints, although sometimes they can be handy.&#10;

I always put my projects under version control, but in the beginning of the
project I don’t write any useful commit messages. Lots of commits are named
“checkpoint”. When collaborating or working on a larger project I do make sure
my commits are logical and have a good commit message.&#10;

I almost never write tests. I think this is one of my major professional
weaknesses. This also has to do with the fact that I’ve programmed Haskell a
lot, where you don’t need much testing, as you can use the type system to do
testing. Maybe it would be a good new year’s resolution: write more tests.&#10;

I sparsely document my code. I try make sure it is very readable. For example,
when writing a complex if condition, you can add some documentation to explain
what it does. Instead, I will pull it out into a variable and name it
appropriately. I also use method names that describe what they are doing.&#10;

When I’m quickly building something, I sometimes copy/paste code, but always put
a comment: “copy pasted from \[filename\]”. This way I can continue my train of
thought. However, it hurts me to see this, so when I’m refactoring I try to
simplify it. I can’t stand repetitive code, and will work hard to eliminate it
and solve things in a beautiful way.&#10;
