---
aliases:
  - /posts/one-app-in-four-weeks-week-1.html
date: 2011-09-30
title: "One App in Four Weeks: Week 1"
---

This Monday, I started [One App in Four
Weeks](/post/10680838726/one-app-in-four-weeks-kickoff). I started by posting a
list of ideas. The third idea was the most appealling to people (although I
still want to build the other two as well, but not now), and I got some great
feedback from everybody.&#10;

I selected the idea and [defined the Minimum Viable
Product](/post/10723613553/check-in-to-people), which is quite simple: you can
check in to people, add a time and note to that checkin and possibly a location
as well.&#10;

Yesterday I wrote about the first [sketches and
ideas](/post/10801169656/sketches-and-ideas), and after that I started working
on the very first version.&#10;

Normally I don’t show these first versions to people, but because I want to show
you all the steps I’ll include the screenshots today. The app is barely
functional: you see a list of Checkins, and when you press the ‘+’ button it
shows the list of your contacts in Address Book. Tapping on a contact takes you
to the ‘Add Checkin’ screen, where you can add a note. The time is not
changeable yet, and the location isn’t implemented at all. When you then press
‘Done’ you’ll go back to the start screen, and the checkin was added. You can
also edit it again by tapping on it.&#10;

For the location, I’m thinking of using the Foursquare API, which can provide
you with venue information based on lat/lon. I’ll probably store the locations
and try to find a previously used location when possible (about half the time I
meet people it’s in the same places).&#10;

I also had some ideas about searching: I want to index all the words in the
checkin database, and do autocompletion using those words. This means that
searching can be a very fast experience. Search could probably be quite
important: I can also imagine it’s handy if I want to find a PHP developer in my
network (I always forget who knows which languages).&#10;

[Discuss on Hacker News](http://news.ycombinator.com/item?id=3056207)

![](http://dl.dropbox.com/u/1264810/blog-content/IMG_1194.PNG
"List of Checkins")

![](http://dl.dropbox.com/u/1264810/blog-content/IMG_1197.PNG "Checkin Screen")
