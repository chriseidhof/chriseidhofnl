+++
title = "Types vs TDD"
headline = "A response"
date = "2017-01-12"
+++

This morning, I read [an article](http://blog.cleancoder.com/uncle-bob/2017/01/11/TheDarkPath.html) against static typing. To be more precise: it argues against static typing in the way Swift/Kotlin implement it. I don't know anything about Kotlin, so I'll try to relate everything to Swift.  The main point of the article is that too much static typing is a bad thing. I agree: although my definition of "too much" is very different.

The main point of critique is that we can't possibly keep adding features to a language to solve actual problems, because we would end up with too many features. Instead, we should solve everything by writing tests. I don't think it's an either/or situation at all: we can have a solid type system and write "manual" tests.

A type checker actually does testing for you. It's not a replacement for TDD, but it allows you to completely get rid of a whole bunch of tests. For example, if you define a method `foo` that returns an `Int`, you can be sure it will only return `Int`s. Not `String`s, not `nil` or `null`, not anything else. No need to write a test.

The article argues that specifying a type such as `Int` is very inflexible: what if you ever wanted to change `foo` to return an optional?  According to the article, you have to know this before you write the system. (And if I interpret the article correctly, it argues that TDD would solve this).

I agree on at least one thing: at some point, code is going to change. However, I couldn't disagree more on the statement that typing makes this hard. 

In Swift, once you change `foo` to return an `Int?`, the compiler will now show an error for each time you call `foo`. This makes it *easy* to make that change, because until you have reviewed every single call to `foo`, the program simply won't compile. I think of the compile errors as a todo-list, not as a [speed bump](https://twitter.com/unclebobmartin/status/819262224686546945).

When you make changes (small or large ones), it's good to have a system in place that checks whether your code still works. With many kinds of changes, the compiler can do this automatically. You don't have to write tests for that.

Don't get me wrong: types are not a silver bullet. You still need to test your code. But wouldn't you rather test interesting parts, and leave the boring stuff to the compiler?

