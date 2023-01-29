import SwiftUI
import HTML

let variadicViews = BlogPost(metadata: .init(title: "Variadic Views", date: "2023-01-27"), body: .pieces(myPostBody), link: "/post/variadic-views")

@ViewBuilder fileprivate var subviews: some View {
    Rectangle()
        .frame(width: 30, height: 30)
    ForEach(0..<3) { ix in
        Text("Hello \(ix)")
    }
}

extension View {
    @ViewBuilder
    func intersperse<V: View>(@ViewBuilder _ divider: () -> V) -> some View {
        let el = divider()
        variadic { children in
            if let c = children.first {
                c
                ForEach(children.dropFirst(1)) { child in
                    el
                    child
                }
            }
        }
    }
}

struct Helper<Result: View>: _VariadicView_MultiViewRoot {
    var _body: (_VariadicView.Children) -> Result

    func body(children: _VariadicView.Children) -> some View {
        _body(children)
    }
}

extension View {
    func variadic<R: View>(@ViewBuilder process: @escaping (_VariadicView.Children) -> R) -> some View {
        _VariadicView.Tree(Helper(_body: process), content: { self })
    }
}

extension View {
    func reduce<R: View>(@ViewBuilder _ combine: @escaping (AnyView, AnyView) -> R) -> some View {
        variadic { children in
            if let c = children.first {
                children.dropFirst(1).reduce(AnyView(c), { l, r in
                    AnyView(combine(l, AnyView(r)))
                })
            }
        }
    }
}

@PieceBuilder
fileprivate var myPostBody: [any PostPiece] {
    Markdown("""
    This week's post about how the SwiftUI view protocol [really represents lists](/post/swiftui-views-are-lists/) stirred a bit of controversy on Mastodon. But I think we all learned a bit from the discussion that followed (I definitely did).

    To deal with these lists of views (e.g. during layout) we can use the underscored variadic view API. I learned about variadic views through the [Moving Parts](http://movingparts.io/variadic-views-in-swiftui) blog. I don't know whether this API is going to change in the future, whether it's App-Store-proof, and so on. It's probably underscored for a good reason. With that out of the way, let's get started!

    First, I wanted to get a way to iterate over the view list and turn them into views. This code is a bit weird, but we only need to write it once. To get access to the view list, we need to construct a type that conforms to `_VariadicView_MultiViewRoot`[^1]. The only requirement we need to implement is the `body` method. We can provide that using a closure:

    [^1]: You can find more information about this by spelunking into the `.swiftinterface` file that SwiftUI provides. Using your Terminal, go to /Applications/Xcode.app, type `find . -name "SwiftUI.swiftmodule"` and go to that folder. Inside you'll find `.swiftinterface` files which contain *a lot* of interesting things.

    ```swift
    struct Helper<Result: View>: _VariadicView_MultiViewRoot {
        var _body: (_VariadicView.Children) -> Result

        func body(children: _VariadicView.Children) -> some View {
            _body(children)
        }
    }
    ```

    The `_VariadicView.Children` type is a random access collection we can loop over. The elements conform to `Identifiable` and `View`. In addition, we can access the *traits* of the elements (more about this later).

    To use our `Helper` above, we can provide an extension on `View`:

    ```swift
    extension View {
        func variadic<R: View>(@ViewBuilder process: @escaping (_VariadicView.Children) -> R) -> some View {
            _VariadicView.Tree(Helper(_body: process), content: { self })
        }
    }
    ```

    Again, the code above is pretty obscure but we only need to write it once. Before we start using this, let's create a list of views:

    ```swift
    @ViewBuilder var subviews: some View {
        Rectangle()
            .frame(width: 30, height: 30)
        ForEach(0..<3) { ix in
            Text("Hello \\(ix)")
        }
    }
    ```

    The above view builder defines a list containing four views: a rectangle and three text labels. We can use these in a container view:

    ```swift
    HStack { subviews }
    ```

    """)

    SwiftUIView {
        HStack { subviews }
    }

    Markdown("""
    Using our `variadic` method, we can write more helper methods. For example, we could intersperse views in between the elements:

    ```swift
    extension View {
        @ViewBuilder
        func intersperse<V: View>(@ViewBuilder _ divider: () -> V) -> some View {
            let el = divider()
            variadic { children in
                if let c = children.first {
                    c
                    ForEach(children.dropFirst(1)) { child in
                        el
                        child
                    }
                }
            }
        }
    }
    ```

    This lets us create an `HStack` with dividers in between the elements:

    ```swift
    HStack {
        subviews.intersperse {
            Divider().fixedSize()
        }
    }
    ```
    """)

    SwiftUIView {
        HStack {
            subviews.intersperse {
                Divider().fixedSize()
            }
        }
    }

    Markdown(
    """
    We can also write a more low-level abstraction like `reduce` (which unfortunately requires `AnyView`):

    ```swift
    extension View {
        func reduce<R: View>(@ViewBuilder _ combine: @escaping (AnyView, AnyView) -> R) -> some View {
            variadic { children in
                if let c = children.first {
                    children.dropFirst(1).reduce(AnyView(c), { l, r in
                        AnyView(combine(l, AnyView(r)))
                    })
                }
            }
        }
    }
    ```

    We could use this to render the list of views in reverse order, with circles in between for good measure:

    ```swift
    HStack {
        subviews.reduce { view1, view2 in
            view2
            Circle().frame(width: 5, height: 5)
            view1
        }
    }
    ```
    """)

    SwiftUIView {
        HStack {
            subviews.reduce { view1, view2 in
                view2
                Circle().frame(width: 5, height: 5)
                view1
            }
        }
    }

    Markdown(
    """
    Variadic views are also very useful when you want to write reusable components that take a list of views with different types. For example, you could write your own picker that has an interface like this:

    ```swift
    struct Sample: View {
        @State private var selection: Int? = 0

        var body: some View {
            MyPicker(selection: $selection) {
                Text("One").myTag(1)
                Image(systemName: "doc").myTag(2)
            }
        }
    }
    ```

    To implement this, we'll use traits and variadic views. The tags are stored as traits. These are similar to preferences, but don't bubble up as high. For example, they won't bubble up out of a container view.

    Here's the helper to tag views:

    ```swift
    fileprivate struct MyTag: _ViewTraitKey {
        static var defaultValue: AnyHashable? = Optional<Int>.none
    }

    extension View {
        func myTag<Value: Hashable>(_ value: Value) -> some View {
            _trait(MyTag.self, value)
        }
    }
    ```

    In our picker, we loop over all the views and put them in an `HStack`. We add a tap gesture to make the items tappable. We use the custom tag to check whether the item is selected. Except for the variadics and tags, the code is straightforward SwiftUI:

    ```swift
    struct MyPicker<Selection: Hashable, Content: View>: View {
        @Binding var selection: Selection?
        @ViewBuilder var content: Content

        var body: some View {
            HStack {
                content.variadic { children in
                    ForEach(children) { child in
                        let tag: Selection? = child[MyTag.self].flatMap { $0 as? Selection }
                        let selected = tag == selection
                        child
                            .onTapGesture {
                                selection = tag
                            }
                            .padding(.bottom, 5)
                            .overlay(alignment: .bottom) {
                                if selected {
                                    Color.accentColor
                                        .frame(height: 1)
                                }
                            }
                    }
                }
            }
        }
    }
    ```

    I think variadic views are essential if we want to write components that mimic the first-party components. They're useful for small things (intersperse) and bigger things (components that want to be flexible about the types of the child views).
    """)
}
