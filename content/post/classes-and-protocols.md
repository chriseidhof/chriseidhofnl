+++
title = "Classes That Conform To Protocols"
headline = "How to use type-erasers as a workaround"
date = "2017-02-01"
advanced_swift = true
+++

The other day, someone asked how to have a variable which stores a `UIView` that also conforms to a protocol. In Objective-C, you would simply write `UIView<HeaderViewProtocol>`. In  current Swift, you can't write something like that. This posts shows two workarounds.

First, let's set the stage, and assume we have a `HeaderViewProtocol`:

```swift
protocol HeaderViewProtocol {
    func setTitle(_ string: String)
}
```

Until [generalized existentials](https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#generalized-existentials) arrive, we'll have to make do with a workaround. The most mechanical solution would be to write a struct which has two properties, one for the protocol and one for the `UIView`. Both point to the same reference:

```swift
struct AnyHeaderView {
    let view: UIView
    let headerView: HeaderViewProtocol
    init<T: UIView>(view: T) where T: HeaderViewProtocol {
        self.view = view
        self.headerView = view
    }
}

let header = AnyHeaderView(view: myView)
header.headerView.setTitle("hi")
```

Alternatively, we could also completely [get rid of the protocol](http://chris.eidhof.nl/post/protocol-oriented-programming/), and create a `HeaderView` struct which simply stores a view and a way to set the title:

```swift
struct HeaderView {
    let view: UIView
    let setTitle: (String) -> ()
}

var label = UILabel()
let header = HeaderView(view: label) { str in
    label.text = str
}
header.setTitle("hello")
```

One benefit of this solution is that there are no protocols involved. More importantly, we can have multiple "implementations" of `HeaderView` for a single class. This eliminates the need to subclass. I prefer this solution, as it's really simple: just bundle up a function and a view.

(If your protocol has associated types or a `Self` constraint, it will be a bit more work to write the type-eraser, see [here](http://chris.eidhof.nl/post/type-erasers-in-swift/) for an explanation).

