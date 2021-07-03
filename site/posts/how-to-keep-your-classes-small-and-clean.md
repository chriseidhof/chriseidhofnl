---
aliases:
  - /posts/how-to-keep-your-classes-small-and-clean.html
date: 2013-02-24
title: How to keep your classes small and clean
---

I’m a little obsessed with trying to write maintainable, clean code. I’m not yet
really good at it, but try to become better every day. It started to become more
of an obsession than usual when I realized that a lot of the projects I work on
will someday be taken over by other people, and I don’t want to be
embarassed.&#10;

This explains my recent interest in testing ([some](http://iosunittesting.com/)
[interesting](http://blog.securemacprogramming.com/)
[blogs](http://qualitycoding.org/) on that).&#10;

Although I’m not yet very good at testing everything, I have two other
heuristics that I use to keep my code maintainable: I try to keep my `.m` files
under a hundred lines (this is hard), and try to keep the number of imports
small.&#10;

Here are two scripts that I use to achieve this. The first one shows the `.m`
files in your project with their line counts, and sorts them by line count. The
bottom of the list (largest files) are top candidates for refactoring:&#10;

``` 
find . -path './Pods' -prune -o -name "*.m" -exec wc -l "{}" \; | sort -n
```

The other script I wrote generates a `.dot` file from your imports, and you can
open it with an app like [GraphViz](http://www.graphviz.org) to get a quick
overview of how your imports are. (I tried to keep it under 140 characters so
it’s tweetable).&#10;

``` 
echo "digraph G {";grep "import \"" **/*.m|sed "s/.m:#import \"/ /;s/.*\///;s/+/_/g;s/.h\"//"|awk "{print \$2,\"-> \"\$1\";\"}";echo "}"
```

Put the above line in a file or in a shell alias, run it and pipe the output to
a file that you can open with GraphViz. I’m pretty sure this can be done even
more effectively using just `awk`, but I’m not an expert yet. Bonus points for
the shortest solution\!&#10;
