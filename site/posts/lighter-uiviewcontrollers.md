---
aliases:
  - /posts/lighter-uiviewcontrollers.html
date: 2012-12-17
title: Lighter UIViewControllers 
---

Recently, I’ve been a bit obsessed with writing simpler code. It happened
because I passed on some projects to other programmers. I would like to feel
minimally embarrassed when doing so.&#10;

In the projects I’ve taken over from other people, one of the most common
problems is that view controller code is big and complicated. In this article,
we’ll look at some ways to make the view controller smaller and thus simpler. In
a project I’m working on currently, we have about 150 classes, and almost none
of them is larger than 100 lines. The ones that are larger than that are on the
top of my refactoring list.&#10;

# Separate out UITableViewDataSource and UITableViewDelegate&#10;

One of the first things I often do is create a separate class for the
tableView’s data source and delegate. Just create a new class, take all the
methods that start with `tableView:` and put them in there. The compiler will
then show you which things are missing in that class (e.g. instance variables),
and you pass them on. Then you can remove them from the view controller.&#10;

# Don’t do domain logic&#10;

Most of my apps are backed by a Core Data stack (but this is true for any kind
of data store). I Try to do as little domain logic as possible. For Core Data,
my favorite trick is to add a category to the generated models where I put my
logic. For example, instead of doing this in your view controller:&#10;

``` 
- (Department*)getRootDepartment:(Department*)department {
  if(department.parent == nil) return department;
  return [self getRootDepartment:department.parent];
}
```

Do this in `Department+Extensions.m`:&#10;

``` 
- (Department*)rootDepartment {
  if(self.parent == nil) return self;
  return [self rootDepartment];
}
```

Even for small methods like this, it helps a lot to keep your view controllers
small. You also have the added benefit that it’s much easier to reuse this
code.&#10;

# Don’t do webservice logic&#10;

Don’t call and parse a webservice request in your view controller.&#10;

I always create a separate set of classes that do the dealing with webservices.
It depends how complicated your webservice / persistency is, but I mostly have a
class called `Webservice` that gives you high-level methods to call the
webservice. Either the methods accept callbacks or I use KVO (more about that
later). It uses the “fire and forget” approach: you tell the webservice that you
want something and then forget, assume it will get back to you at some
point.&#10;

The webservice class calls the API and turns the API results into domain
objects. This functionality is often achieved by multiple classes that are used
by the webservice, but that’s a topic for a later post.&#10;

# Don’t create complicated view hierarchies&#10;

Don’t set up complicated view hierarchies in your view controller. Personally,
I’m a big fan of designing my views in a nib/xib/storyboard. But even if you
don’t, I think it’s better to compose several views into a new view. For
example, if you want a date slider, it’s better to create the view hierarchy for
that (the labels at the axes, a label representing the current date and the
UISlider) in a separate class.&#10;

# Create child view controllers&#10;

Since iOS 5, it’s very easy to create child view controllers. Use this
functionality. It makes your life easier. This is mostly useful for iPad apps,
but might be useful for iPhone apps as well. A classical example of this is the
split view, but in any screen where you have components that are almost
independent it might be useful.&#10;

# Use KVO&#10;

Key value observing can make your life a lot easier. It’s also a bit tricky
sometimes, so you do need to spend some time to learn it, and you will probably
make some mistakes (I still get tripped up every now and then).&#10;

One example where KVO really shines is the `NSFetchedResultsController`. It
listens to changes in core data objects and can be used to implement a
`UITableViewDataSource` or `UICollectionViewDataSource`.&#10;

For example, suppose you have a list of `Departments`. Then you want to refresh
that list from the API. In your view controller, you fire a off a request like
`[webservice reloadDepartments]` and then forget. Once the webservice updates
the Core Data managed objects, magic happens: Because you implemented your
`UITableViewDataSource` using an `NSFetchedResultsController`, it gets refreshed
automatically.&#10;

KVO by itself can be a bit hairy sometimes, and there are small libraries like
[THObserversAndBinders](https://github.com/th-in-gs/THObserversAndBinders) that
make things easier.&#10;

# Other ideas?&#10;

This is just a list of things that I could come up with and common refactorings
I use. I’m sure there are a lot of things I forgot, let me know your tips and
I’ll add them to the article.&#10;
