+++
title = "A Micro Auto Layout DSL"
headline = "Three Methods To Make Life Easier"
date = "2017-10-27"
advanced_swift = true
+++

These days, I'm using fewer external libraries. First, I don't like most Swift libraries out there, they're often implemented in a complicated way and contain too many protocols for my taste. Second, I'm not sure how they'll be maintained in the future, and most libraries are pretty big -- I don't really want to own that code. Third, I'm too lazy to set up a dependency manager, so I'll keep my projects dependency-free.

However, the other day as I was writing some UIKit code, I found myself annoyed at the verbosity of Auto Layout. Here's some code that I wrote over and over again:

```swift
let view = UIView()
let label = UILabel()
view.addSubview(label)
label.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
])
```

It's always the same pattern: adding the subview, setting `translatesAutoresizingMaskIntoConstraints` to false, and then activating the constraints. The first anchor and the second anchor are almost always the same, and on the left-hand side we always have the child and on the right-hand side we always have the parent view. Often, when I write the code above, I forget to active the constraints or forget to set `translatesAutoresizingMaskIntoConstraints`. Let's try to solve as many of these problems as we can in as little code as possible.

Rather than pulling in a library, I decided to write my own. The first bit of my micro-library is a function that, given a child and a parent, returns a layout constraint:

```swift
typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint
```

Ideally, we would now write a method `equal` which allows us to write following:

```swift
let constraint: Constraint = equal(\.topAnchor, \.safeAreaLayoutGuide.topAnchor)
```

Note that `constraint` is just a description of a layout constraint -- it's still waiting for a concrete child and parent view. It says that, given a child and parent, the child's top anchor should be equal to the parent's `safeAreaLayoutGuide.topAnchor`.

We can implement `equal` with a little bit of keypath magic:

```swift
func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>, _ to: KeyPath<UIView, Anchor>, constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}
```

Most of the time, the two layout anchors are the same (e.g. `leadingAnchor` and `leadingAnchor`), so let's write a small helper for that case:

```swift
func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>, constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return equal(keyPath, keyPath, constant: constant)
}
```

Finally, let's solve the last two problems: we don't want to forget to set `translatesAutoresizingMaskIntoConstraints` to false, and we don't want to forget to activate the constraints. What if we create another version of `addSubview` that does this for us?

```swift
extension UIView {
    func addSubview(_ child: UIView, constraints: [Constraint]) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { $0(child, self) })
    }
}
```

We now have everything in place to rewrite our initial example:

```swift
let view = UIView()
let label = UILabel()
view.addSubview(label, constraints: [
   equal(\.leadingAnchor),
   equal(\.topAnchor, \.safeAreaLayoutGuide.topAnchor),
   equal(\.trailingAnchor)
])
```

The code is shorter and much more to the point. The `translatesAutoresizingMaskIntoConstraints` is set automatically, and all constraints are activated. Instead of depending on a big library, we wrote three methods; 15 lines of code in total. Obviously, there are many things you can't do with this: for example, you can't easily keep a reference to a specific constraint and change the `constant` property. That's fine, we can keep using the regular Auto Layout API for this.

There are a few obvious extensions that are left as an exercise:

- Add a way to constrain an anchor to a constant (instead of another anchor and a constant)
- Add a way to constrain to a different view than the parent (e.g. the content view of a `UIVisualEffectView`)

Thanks to Florian Kugler for helping me simplify the code a lot. We'll also make a [Swift Talk](https://talk.objc.io) episode about the code above, it should be online soon.

