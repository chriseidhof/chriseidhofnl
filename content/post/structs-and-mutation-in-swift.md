+++
date = "2016-08-16"
headline = "How I Learned To Stop Worrying and Love mutating"
title = "Structs and mutation in Swift"
+++

*Note*: This post is a draft-version of a new section in our book [Advanced Swift](https://www.objc.io/books/advanced-swift/). We're currently updating the book for Swift 3. It'll be a free update for everyone who has bought a digital version of the book. Thanks to [Ole Begemann](https://twitter.com/olebegemann) for suggestions and improvements.

Value types imply that whenever a variable is copied, the value itself — and not just a reference to the value — is copied. For example, in almost all programming languages, scalar types are value types. This means that whenever a value is assigned to a new variable, it is copied rather than passed by reference:

```swift
var a = 42
var b = a
b += 1
```

After the code above executes, the value of `b` will be 43, but `a` will still be 42. This is so natural that it seems like stating the obvious. However, in Swift, all structs behave this way.

Let's start with a simple struct that describes a `Point`. This is similar to `CGPoint`, except that it contains `Int`s, whereas `CGPoint` contains `CGFloat`s.

```swift
struct Point {
    var x: Int
    var y: Int
}
```

For structs, Swift automatically adds a memberwise initializer. This means we can now initialize a new variable:

```swift
let origin = Point(x: 0, y: 0)
```

Because structs in Swift have value semantics, we cannot change any of the properties of a struct variable that's defined using let. For example, the following code will not work:


```highlight-swift
origin.x = 10 // error
```

Even though we defined `x` within the struct as a `var` property, we cannot change it, because `origin` is defined using `let`. This has some large advantages. For example, if you read a line like `let point = ...`, and you know that `point` is a struct variable, then you also know that it will never, ever, change. This is a great help when reading through code.

To create a variable that we can mutate, we need to create it using `var`:

```swift
var otherPoint = Point(x: 0, y: 0)
otherPoint.x += 10
otherPoint
```

Once we create a variable using `var`, we can mutate it. However, unlike with objects, every struct variable is unique. For example, we can create a new variable `thirdPoint`, and assign the value of `origin` to it. Now we can change `thirdPoint`, but `origin` (which we defined as an immutable variable using `let`) will not change. 

```swift
var thirdPoint = origin
thirdPoint.x += 10
thirdPoint
origin
```

Once you assign a struct to a new variable, Swift automatically makes a copy. Even though this sounds very expensive, many of the copies can be optimized away by the compiler, and Swift tries hard to make the copies very cheap. In fact, many structs in the standard library are implemented using a technique called copy-on-write, which we will look at later.

If we have struct values that we plan to use more often, we can define them in an extension as a static property. For example, we can define an `origin` property on `Point`, so that we can write `Point.origin` everywhere we need it:

```swift
extension Point {
    static let origin = Point(x: 0, y: 0)
}
Point.origin
```

Structs can also contain other structs. For example, if we define a `Size` struct, we can create a `Rect` struct which is composed out of a point and a size:

```swift
struct Size {
    var width: Int
    var height: Int
}

struct Rectangle {
    var origin: Point
    var size: Size
}
```

Just like before, we get a memberwise initializer for `Rectangle`. The order of the parameters matches the order of the property definitions:

```swift
Rectangle(origin: Point.origin, 
          size: Size(width: 320, height: 480))
```

If we want a custom initializer for our struct, we can add it directly inside the struct definition. However, if the struct definition contains a custom initializer, Swift does not generate a memberwise initializer. By defining our custom initializer in an extension, we also get to keep the memberwise initializer.

```swift
extension Rectangle {
    init(x: Int = 0, y: Int = 0, width: Int, height: Int) {
        origin = Point(x: x, y: y)
        size = Size(width: width, height: height)
    }
}
```

Instead of setting `origin` and `size` directly, we could have also called `self.init(origin:size:)`.

If we define a mutable variable `screen`, we can add a `didSet` block that gets executed whenever `screen` changes. This `didSet` works for every definition of a struct, be it in a playground, in a class or when defining a global variable.

```swift
var screen = Rectangle(width: 320, height: 480) {
    didSet {
        print("Screen changed! \(screen)")
    }
}
```

Maybe somewhat surprisingly, even if we change something deep inside the struct, this will get triggered:

```swift
screen.origin.x = 10
```

Understanding why this works is key to understanding value types. Mutating a struct variable is semantically the same as assigning a new value to it. When we mutate something deep inside the struct, it still means we are mutating the struct, so `didSet` still needs to get triggered.

With regular structs, the compiler will mutate the value in place, and not actually make a copy. With copy-on-write structs (which we'll discuss later), this works differently.

It would make sense to add two `Points` together. We can use the `+` operator for this, add both members, and return a new `Point`.

```swift
func +(lhs: Point, rhs: Point) -> Point {
    return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
screen.origin + Point(x: 10, y: 10)
```

We could also lift this operation to rectangles, and add a `translate` method which moves the rectangle by a given offset. Our first attempt doesn't work:

```highlight-swift
extension Rectangle {
    func translate(by offset: Point) {
        origin = origin + offset
    }
}
```

The compiler tells us that we cannot assign to the `origin` property, because `self` is immutable (writing `origin =` is shorthand for `self.origin =`). We could think of `self` as an extra, implicit parameter that gets passed to every method on `Rectangle`. You never have to pass the parameter, but it's always there inside the method body. And it's defined as `let` by default. The reason this `let` restriction exists is so that value semantics can be guaranteed. If we want to be able to mutate `self`, or any property of `self`, or even nested properties (e.g. `self.origin.x`), we need to mark our method as `mutating`:

```swift
extension Rectangle {
    mutating func translate(by offset: Point) {
        origin = origin + offset
    }
}
screen.translate(by: Point(x: 10, y: 10))
```

The compiler enforces the `mutating` keyword. Unless we use it, we are not allowed to mutate anything inside the method. By marking the method as `mutating`, we change the behavior of `self`. Instead of it being a `let`, it now works like a `var`: we can freely change any property. (To be precise, it's not even a `var`, but we will get to that in a little bit).

If we define a `Rectangle` variable using `let`, we cannot call `translate` on it, because the only `Rectangle`s that are mutable are the ones defined using `var`:

```highlight-swift
let otherScreen = screen
otherScreen.translate(by: Point(x: 10, y: 10)) // error
```

Thinking back to the collections chapter, we can now see how the difference between `let` and `var` applies to our collections as well. The `append` method on arrays is defined as `mutating`, and therefore we are not allowed to call it on an array defined with `let`. 

Likewise, if we think about a property setter on a struct, it makes sense that they are mutating. Because Swift automatically marks every setter as `mutating`, you cannot call a setter on a `let` variable.

```highlight-swift
let point = Point.origin
// doesn't work, because the setter is mutating.
point.x = 10 
```

In many cases, it makes sense to have both a `mutating` and a non-mutating variant of the same method. For example, arrays have both a `sort()` method (which is mutating and sorts in place) and a `sorted()` method (which returns a new array). We can also add a non-mutating variant of our `translate(by:_)` method. Instead of mutating `self`, we create a copy, mutate that, and return a new `Rectangle`:

```swift
extension Rectangle {
    func translated(by offset: Point) -> Rectangle {
        var copy = self
        copy.translate(by: offset)
        return copy
    }
}
screen.translated(by: Point(x: 20, y: 20))
```

> The names `sort` and `sorted` are not chosen at random, but are names that conform to the Swift [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Likewise, we applied these guidelines to `translate` and `translated`. There is even specific documentation for methods that have a mutating and a non-mutating variant: because `translate` has a side-effect, it should read as an imperative verb phrase. The non-mutating variant should have a -ed or -ing suffix.

In functional programming, side-effects are often considered bad, because they might influence your code in unexpected ways. For example, if an object is referenced in multiple places, every change automatically happens in every place. As we have seen in the introduction, when dealing with multi-threaded code, this can easily lead to bugs: because the object you are just checking can be modified from a different thread, all your assumptions might be invalid.

With Swift structs, `mutating` does not have the same problems. The mutation of the struct is a local side-effect, and only applies to the current struct variable. Because every struct variable is unique (or in other words: every struct value has exactly one owner), it's almost impossible to introduce bugs this way. Unless you're referring to a global struct variable across threads, that is.

To understand how the `mutating` keyword works, we can look at the behavior of `inout`. In Swift, we can mark function parameters as `inout`. Before we do that, let's define a free function that moves a rectangle by ten points on both axes. We cannot simply call `translate` directly on the `rectangle` parameter, because all function parameters are immutable by default. In order to change it, we create a mutable copy using `var`, call `translate` and return the changed value. Then we need to re-assign it to `screen`:

```swift
func moveByTenTen(rectangle: Rectangle) -> Rectangle {
    var changed = rectangle
    changed.translate(by: Point(x: 10, y: 10))
    return changed
}
screen = moveByTenTen(rectangle: screen)
```

How could we write a function that changes the `rectangle` in place? Thinking back, the `mutating` keyword did exactly that. It makes the implicit `self` parameter mutable, and it changes the value of the variable.

In functions, we can mark parameters as `inout`. Just like with a regular parameter, a copy of the value gets passed in to the function. However, we can change the copy (it's as if it were defined as a `var`). And once the function returns, the original value gets overwritten:

```swift
func moveByTwentyTwenty(rectangle: inout Rectangle) {
    rectangle.translate(by: Point(x: 20, y: 20))
}
moveByTwentyTwenty(rectangle: &screen)
```

The `moveByTwentyTwenty` function takes the `screen` rectangle, changes it locally, and copies the new value back (overriding the previous value of `screen`). This behavior is exactly the same as a `mutating` method. In fact, `mutating` methods are just like regular methods on struct, except that `self` is marked as `inout`.

Just to make sure, we cannot call `moveByTwentyTwenty` on a rectangle that's defined using `let`. We can only use it with mutable values:

```highlight-swift
let immutableScreen = screen
moveByTwentyTwenty(rectangle: &immutableScreen) // error
```

Now it also makes sense how we could define a mutating operator like `+=`. Such operators modify the left-hand side by adding the right-hand side:

```swift
func +=(lhs: inout Point, rhs: Point) {
    lhs = lhs + rhs
}
var myPoint = Point.origin
myPoint += Point(x: 10, y: 10)
```

In the [Functions](#functions) chapter, we will go into more detail about `inout`. For now, it suffices to say that `inout` is in lots of places. For example, it's now easy to understand how modifying a subscript works:

```swift
var array = [Point(x: 0, y: 0), Point(x: 10, y: 10)]
array[0] += Point(x: 100, y: 100)
```

The expression `array[0]` is automatically passed in as an `inout` variable. In the Functions chapter, we will look in more detail at `inout` parameters, and see why we can use expressions like `array[0]` as an `inout` parameter.

