+++
date = "2016-08-29"
headline = "From Runtime Magic To Functions"
title = "Sort Descriptors in Swift"

+++

Just last week, someone asked me "in what respect does Swift fall short of the
dynamic features of Objective-C"? 

Dynamic programming means a lot of different
things to different people, and I think they meant runtime programming. In this
post, we'll look at replacing runtime programming (in `NSSortDescriptor`) with
functions. 

This post is an excerpt from the Functions chapter in [Advanced
Swift](https://www.objc.io/books/advanced-swift/), which we're currently
rewriting (and making very good progress).  The text below was originally written by [Airspeed
Velocity](https://twitter.com/airspeedswift). I took his text and code, updated
everything for Swift 3 and made some heavy edits.

---

In the chapter on [collections](#collections), we talked about parametrizing
behavior by passing functions as arguments. Let's look at another example of
this: sorting.

If you want to sort an array in Objective-C using Foundation, you are met with a
long list of different options. These provide a lot of flexibility and power,
but at the cost of complexity — even the simplest probably needs a trip to the
documentation to know how to use it.

Sorting collections in Swift is simple:

```swift
var myArray = [3, 1, 2]
myArray.sorted() // [1, 2, 3]
```
There are really four sort methods: `sorted(by:)` and `sort(by:)`, times two for
the overloads that default to sorting comparable things in ascending order. But
the overloading means that when you want the simplest case, `sorted()` is all
you need. If you want to sort in a different order, just supply a function:

```swift
myArray.sorted(by: >) // [3, 2, 1]
```
You can also supply a function if your elements don't conform to `Equatable` but
*do* have a `<` operator, like tuples:

```swift
var numberStrings = [(2, "two"), (1, "one"), (3, "three")]
numberStrings.sort(by: <)
numberStrings // [(1, "one"), (2, "two"), (3, "three")]
```
Or, you can supply a more complicated function if you want to sort by some
arbitrary calculated criteria:

```swift
let animals = ["elephant", "zebra", "dog"]
let sortedAnimals = animals.sorted { lhs, rhs in
    let l = lhs.characters.reversed()
    let r = rhs.characters.reversed()
    return l.lexicographicallyPrecedes(r)
}
sortedAnimals // ["zebra", "dog", "elephant"]
```
It is this last ability — the ability to use any comparison function to sort a
collection — that makes the Swift sort so powerful, and makes this one function
able to replicate much (if not all) of the functionality of the various
different sorting methods in Foundation.

To demonstrate this, let's take a complex example inspired by the [Sort
Descriptor Programming
Topics](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/SortDescriptors/Articles/Creating.html).
The `sortedArray(using:)` method on `NSArray` is very flexible and a great
example of the power of Objective-C's dynamic nature. Support for selectors and
dynamic dispatch is still there in Swift, but the Swift standard library favors
a more function-based approach instead. Later on, we'll show a few techniques
where functions as arguments, and treating functions as data, can be used to get
the same dynamic effects.

We'll start by defining a `Person` object. Because we want to show how
Objective-C's powerful runtime system works, we'll have to make it an `NSObject`
subclass (in pure Swift, a struct might have been a better choice):

```swift
final class Person: NSObject {
    var first: String
    var last: String
    var yearOfBirth: Int
    init(first: String, last: String, yearOfBirth: Int) {
        self.first = first
        self.last = last
        self.yearOfBirth = yearOfBirth
    }

}
```
Let's also define an array of people, with different names and birth years:

```swift
let people = [
    Person(first: "Jo", last: "Smith", yearOfBirth: 1970),
    Person(first: "Joe", last: "Smith", yearOfBirth: 1970),
    Person(first: "Joe", last: "Smyth", yearOfBirth: 1970),
    Person(first: "Joanne", last: "smith", yearOfBirth: 1985),
    Person(first: "Joanne", last: "smith", yearOfBirth: 1970),
    Person(first: "Robert", last: "Jones", yearOfBirth: 1970),
]
```
We want to sort this array first by last name, then by first name, and finally
by birth year. We want to do this case insensitively and using the user's
locale. An `NSSortDescriptor` object describes how to order objects, and we can
use them to express the individual sorting criteria.

```swift
let lastDescriptor = NSSortDescriptor(key: "last", ascending: true,
  selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
let firstDescriptor = NSSortDescriptor(key: "first", ascending: true, 
  selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
let yearDescriptor = NSSortDescriptor(key: "yearOfBirth", ascending: true)
```
To sort the array, we can use the `sortedArray(using:)` method on `NSArray`.
This takes a list of sort descriptors. To determine the order of two elements,
it starts by using the first sort descriptor, and uses that result. However, if
two elements are equal according to the first descriptor, it uses the second
descriptor, and so on.

```swift
(people as NSArray).sortedArray(using: [lastDescriptor, firstDescriptor, yearDescriptor]) 
// [Robert Jones (1970), Jo Smith (1970), Joanne smith (1970), Joanne smith (1985), Joe Smith (1970), Joe Smyth (1970)]
```
A sort descriptor uses two runtime features of Objective-C: the `key` is a key
path, and [key-value
coding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html)
is used to lookup the value of that key at runtime. The `selector` parameter
takes a selector (which is really just a `String` describing a method name). At
runtime, the selector is turned into a comparison function. When comparing two
objects, the values for the key are compared using that comparison function.

This is a pretty cool use of runtime programming, especially when you realize
the array of sort descriptors can be built at runtime, say based on a user
clicking a column heading.

How can we replicate this functionality using Swift's `sort`? It's simple to
replicate *parts* of the sort, for example, if you want to sort an array using
`localizedCaseInsensitiveCompare`:

```swift
var strings = ["Hello", "hallo", "Hallo", "hello"]
strings.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending}
strings // ["hallo", "Hallo", "Hello", "hello"]
```
If you want to sort using just a single property of an object, that's also
simple.

```swift
people.sorted { $0.yearOfBirth < $1.yearOfBirth } 
// [Jo Smith (1970), Joe Smith (1970), Joe Smyth (1970), Joanne smith (1970), Robert Jones (1970), Joanne smith (1985)]
```
This approach doesn't work so great when optional properties are combined with
methods like `localizedCaseInsensitiveCompare`, though — it gets ugly fast. For
example, consider sorting an array of filenames by file extension (using the
`fileExtension` property from the [Optionals](#optionals) chapter):

```swift
var files = ["one", "file.h", "file.c", "test.h"]
files.sort { l, r in r.fileExtension.flatMap { l.fileExtension?.localizedCaseInsensitiveCompare($0) } == .orderedAscending }
files // ["one", "file.c", "file.h", "test.h"]
```
Later on, we'll make it easier to use optionals when sorting. However, for now,
we haven't even tried sorting by multiple properties. To sort by last name, then
first name, we can use the standard library's `lexicographicalCompare` method.
This takes two sequences and performs a phonebook-style comparison by moving
through each pair of elements until it finds one that isn't equal. So we can
build two arrays of the elements and use `lexicographicalCompare` to compare
them. It also takes a function to perform the comparison. We'll put our use of
`localizedCaseInsensitiveCompare` in the function:

```swift
let sortedPeople = people.sorted { p0, p1 in
    let left =  [p0.last, p0.first]
    let right = [p1.last, p1.first]

    return left.lexicographicallyPrecedes(right) {
        $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
    }
}
sortedPeople // [Robert Jones (1970), Jo Smith (1970), Joanne smith (1985), Joanne smith (1970), Joe Smith (1970), Joe Smyth (1970)]
```
At this point, we've almost replicated the functionality of the original sort in
roughly the same number of lines. But there's still a lot of room for
improvement: the building of arrays on every comparison is very inefficient, the
comparison is hardcoded, and we can't really sort by `yearOfBirth` using this
approach.

### Functions as Data

Rather than writing an even more complicated function that we can use to sort,
let's take a step back. So far, the sort descriptors were much clearer, but they
use runtime programming. The functions we wrote do not use runtime programming,
but they are not so easy to write (and read).

A sort descriptor is a way of describing the ordering of objects. Instead of
storing that information as a class, we can define a function to describe the
ordering of objects. The simplest possible definition would take two objects,
and returns `true` if they are ordered. This is also exactly the type that the
standard library's `sort(by:)` and `sorted(by:)` methods take as an argument.
It's helpful to define a generic `typealias` to describe sort descriptors:

```swift
typealias SortDescriptor<Value> = (Value, Value) -> Bool
```
As an example, we could define a sort descriptor that compares two `Person`
objects by year of birth, or a sort descriptor that sorts by last name:

```swift
let sortByYear: SortDescriptor<Person> = { $0.yearOfBirth < $1.yearOfBirth }
let sortByLastName: SortDescriptor<Person> = { 
  $0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending 
}
```
Rather than writing the sort descriptors by hand, we can write a function that
generates them. It's not nice that we to write the same property twice: in the
`sortByLastName`, we could have easily made a mistake and accidentally compared
`$0.last` with `$1.first`. Also, it's tedious to write these sort descriptors:
to sort by first name, it's probably easiest to copy and paste the
`sortByLastName` definition and modify it.

Rather than copying and pasting, we can define a function with an interface that
is much like `NSSortDescriptor`, but without the runtime programming. This
function takes a key and a comparison method, and returns a sort descriptor (the
function, not the class `NSSortDescriptor`). Here, `key` is not a string, but a
function. To compare two keys, we use a function `isOrderedBefore`. Finally, the
result type is a function as well, even though that is slightly obscured by the
`typealias`.

```swift
func sortDescriptor<Value, Key>(
  key: @escaping (Value) -> Key,
    _ isOrderedBefore: @escaping (Key, Key) -> Bool) 
    -> SortDescriptor<Value> {
    return { isOrderedBefore(key($0), key($1)) }
}
```
This allows us to define `sortByYear` in a different way:

```swift
let sortByYearAlt: SortDescriptor<Person> = sortDescriptor(key: { $0.yearOfBirth }, <)
people.sorted(by: sortByYearAlt) 
// [Jo Smith (1970), Joe Smith (1970), Joe Smyth (1970), Joanne smith (1970), Robert Jones (1970), Joanne smith (1985)]
```
We can even define an overloaded variant that works for all `Comparable` types:

```swift
func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key)
    -> SortDescriptor<Value> where Key: Comparable {
    return { key($0) < key($1) }
}
let sortByYearAlt2: SortDescriptor<Person> = sortDescriptor(key: { $0.yearOfBirth })
```
Both `sortDescriptor` above work with boolean functions. The `NSSortDescriptor`
class has an initializer that takes a comparison function such as
`localizedCaseInsensitiveCompare`. Adding support for this is easy as well:

```swift
func sortDescriptor<Value, Key>(
    key: @escaping (Value) -> Key,
    ascending: Bool = true,
    _ comparator: @escaping (Key) -> (Key) -> ComparisonResult
    ) -> SortDescriptor<Value> {
    return { lhs, rhs in
        let order: ComparisonResult = ascending ? .orderedAscending : .orderedDescending
        return comparator(key(lhs))(key(rhs)) == order
    }
}
```
This allows us to write our `sortByFirstName` in a much shorter and clearer way:

```swift
let sortByFirstName: SortDescriptor<Person> = 
  sortDescriptor(key: { $0.first }, String.localizedCaseInsensitiveCompare)
people.sorted(by: sortByFirstName) 
// [Jo Smith (1970), Joanne smith (1985), Joanne smith (1970), Joe Smith (1970), Joe Smyth (1970), Robert Jones (1970)]
```
This `SortDescriptor` is just as expressive as its `NSSortDescriptor` variant,
but it is typesafe, and it does not rely on runtime programming.

Currently, we can only use a single `SortDescriptor` function to sort arrays. If
you recall, we used the `NSArray.sortedArray(using:)` method to sort an array
with a number of comparison operators. We could easily add a similar method to
`Array`, or even to the `Sequence` protocol. However, we would have to add it
twice: once for the mutating variant, and once for the non-mutating variant.

We take a different approach so that we don't have to write more extensions.
Instead, we write a function that combines multiple sort descriptors into a
single sort descriptor. It works just like the `sortedArray(using:)` method: it
first tries the first descriptor and uses that result. Unless the values are
equal, then it uses the second descriptor, and so on.

```swift
func combine<Value>
    (sortDescriptors: [SortDescriptor<Value>]) -> SortDescriptor<Value> {
    return { lhs, rhs in
        for isOrderedBefore in sortDescriptors {
            if isOrderedBefore(lhs,rhs) { return true }
            if isOrderedBefore(rhs,lhs) { return false }
        }
        return false
    }
}
```
We can now finally replicate the initial example we had using sort descriptors:

```swift
let combined: SortDescriptor<Person> = combine(
  sortDescriptors: [sortByLastName,sortByFirstName,sortByYear]
)
people.sorted(by: combined) 
// [Robert Jones (1970), Jo Smith (1970), Joanne smith (1970), Joanne smith (1985), Joe Smith (1970), Joe Smyth (1970)]
```
We ended up with the same behavior as before. However, the version using
functions is type-safe and does not rely on runtime programming, so it can be
optimized by the compiler as well. And we can use it with structs, or
non-Objective-C Objects.

This approach of using functions as data — storing them in array and building
those arrays at runtime — opens up a new level of dynamic behavior, and it is
one way in which a statically typed compile-time-oriented language like Swift
can still replicate some of the dynamic behavior of languages like Objective-C
or Ruby.

Also, it is possible to write functions that combine other functions. For
example, our `combine(sortDescriptors:)` function took an array of sort
descriptors, and combined them into a single sort descriptor. Alternatively, we
could have written an operator to combine two sort functions:

```swift
infix operator <||> : LogicalDisjunctionPrecedence
func <||><A>(lhs: @escaping (A,A) -> Bool, rhs: @escaping (A,A) -> Bool) -> (A,A) -> Bool {
    return { x,y in
        if lhs(x,y) { return true }
        if lhs(y,x) { return false }
        
        // Otherwise, they're the same, so we check for the second condition
        if rhs(x,y) { return true }
        
        return false
    }
}
```
Most of the time, writing a custom operator is a bad idea. Custom operators are
often harder to read than functions, because the name isn't explicit. However,
they can be very powerful when used sparingly. The operator above allows us to
rewrite our combined sort example like so:

```swift
let combinedAlt = sortByLastName <||> sortByFirstName <||> sortByYear
people.sorted(by: combinedAlt) 
// [Robert Jones (1970), Jo Smith (1970), Joanne smith (1970), Joanne smith (1985), Joe Smith (1970), Joe Smyth (1970)]
```
That said, we prefer the `combine(sortDescriptors:)` function over the custom
operator. It is clearer at the call-site, which makes for more readable code.
Unless you are writing highly domain-specific code, a custom operator is
probably overkill.

The Foundation version still has one functional advantage over our version. It
can deal with optionals without having to write any more code. For example, if
we would make the `last` property on `Person` an optional string, we wouldn't
have to change anything in our sorting code that uses `NSSortDescriptor`.

However, all is not lost. You can feel it coming: once again, we write a
function which takes a function and returns a function. We can take a regular
comparing function such as `localizedCaseInsensitiveCompare`, which works on two
`String`s, and turn it into a function that takes two optional `String`s. If
both values are `nil`, they are equal. If the left-hand side is nil, but the
right-hand isn't they're ascending, and the other way around. Finally, if they
are both non-`nil`, we can use the `compare` function to compare them.

```swift
func lift<A>(_ compare: @escaping (A) -> (A) -> ComparisonResult) -> (A?) -> (A?) -> ComparisonResult {
    return { lhs in { rhs in
        switch (lhs, rhs) {
        case (nil, nil): return .orderedSame
        case (nil, _): return .orderedAscending
        case (_, nil): return .orderedDescending
        case let (l?, r?): return compare(l)(r)
        default: fatalError() // Impossible case
        }
    } }
}
```
This allows us to "lift" a regular comparison function into the domain of
optionals, and it can be used together with our sortDescriptor function. If you
recall the `files` array from before, sorting them by `fileExtension` got really
ugly because we had to deal with optionals. However, with our new `lift`
function, it's very clean again:

```swift
let lcic = lift(String.localizedCaseInsensitiveCompare)
let result = files.sorted(by: sortDescriptor(key: { $0.fileExtension }, lcic))
result // ["one", "file.c", "file.h", "test.h"]
```
> We can write a similar version of `lift` for functions that return a `Bool`.
> Before Swift 3, operators like `>` were defined on optionals. They were
> removed because they can lead to accidental bugs. However, with a boolean
> `lift` you can easily take an existing operator and make it work for
> optionals.

One drawback of the function-based approach is that functions are opaque. We can
take an `NSSortDescriptor`, print it to the console, and we get some information
about the sort descriptor: the key path, the selector name and whether it's
ascending. Our function-based approach cannot do this. For sort descriptors,
this is not a problem in practice. If it's important to have that information,
we could wrap the functions in a struct or class, and store additional debug
information.

This approach has also given us a clean separation between the sorting method
and the comparison method. The algorithm that Swift's sort uses is a hybrid of
multiple sorting algorithms — as of writing, it is an
[introsort](https://en.wikipedia.org/wiki/Introsort) (which is itself a hybrid
of a quicksort and a heapsort), but it switches to an [insertion
sort](https://en.wikipedia.org/wiki/Insertion_sort) for small collections to
avoid the upfront startup cost of the more complex sort algorithms.

Introsort is not a
"[stable](https://en.wikipedia.org/wiki/Category:Stable_sorts)" sort. That is,
it does not necessarily maintain relative ordering of values that are otherwise
equal according to the comparison function.

But if you implemented a stable sort, the separation of the sort method from the
comparison would allow you to swap it in easily:

``` swift
people.stableSorted(by: combine(
  sortDescriptors: [sortByLastName,sortByFirstName,sortByYear]
))
```
