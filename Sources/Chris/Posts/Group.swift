import SwiftUI
import HTML

let avoidGroups = BlogPost(metadata: .init(title: "Why I Avoid Group", date: "2025-03-19"), body: .pieces(myPostBody), link: "/post/why-i-avoid-group")


@PieceBuilder
fileprivate var myPostBody: [any PostPiece] {
    Markdown("""
    In [our workshops](https://www.swiftuifieldguide.com/workshops/), we often see people reaching for `Group`. There's a lot of code out there that does the same, and yet, I noticed myself avoiding it, even though it can be pretty handy. In investigating, I realized that it's not even `Group` that is the problem.

    In my understanding, `Group` is just a way to view builder syntax, but doesn't really add any "structure" or "container" node. For example, if you have an `if/else` statement and want to apply a modifier to that, it won't compile:

    ```swift
    if let image {
        Image(image)
    } else {
        Text("Loading…")
    }
    .onAppear {  } /* does not compile */
    ```

    You can fix this by wrapping everything in a `Group`:

    ```swift
    Group {
        if let image {
            Image(image)
        } else {
            Text("Loading…")
        }
    }
    .onAppear {  } /* works */
    ```

    So far, so good. And yet, everytime I see this it makes me uneasy, because `Group` has such strange, unpredictive behavior. For some reason, it always seems to come back and bite me. However, I couldn't really put my finger on it. In this post I boiled down the problem, so that in the future, I have a clear explanation I can link to.

    ## Group Variadics

    You can also use `Group` to apply some modifiers to *each* of the subviews rather than to the subviews as a whole. For example, you can apply padding and a background to each of the elements in a `Group`:

    ```swift
    Group {
        Text("One")
        Text("Two")
    }
    .padding()
    .background(.blue)
    ```

    If you create a new Xcode project and add this as the `body` of your `ContentView`, it will look like this in the previews:
    """)
    SwiftUIView {
        VStack {
            Group {
                Text("One")
                Text("Two")
            }
            .padding()
            .background(.blue)
        }
        .asPhone()
    }
    Markdown("""
    However, if you then run that very same app in the Simulator, it looks very different:
    """)
    SwiftUIView {
        VStack {
            Group {
                Text("One")
                Text("Two")
            }
        }
        .padding()
        .background(.blue)
        .asPhone()
    }
    Markdown("""
    The difference above is the reason why I avoid `Group`.  From my interpretation, the [Group documentation page](https://developer.apple.com/documentation/swiftui/group) makes it clear that the preview behavior is correct, and the Simulator behavior is a bug.

    Some modifiers do seem to work differently. In the documentation, it says:

    > The modifier applies to all members of the group — and not to the group itself. For example, if you apply onAppear(perform:) to the above group, it applies to all of the views produced by the if isLoggedIn conditional, and it executes every time isLoggedIn changes.

    In my testing, I saw a different behavior, it only called `onAppear` once. If I understand the intended behavior correctly, this would also print twice (and yet it doesn't):

    ```swift
    Group {
        Text("One")
        Text("Two")
    }
    .onAppear {
        print("Appear")
    }
    ```
    
    It seems that the behavior not only differs between simulator and previews, but also between different modifiers.

    ## Aside: View Lists

    Before we look at the problem, let's consider some theory. If we look at the definition of (say) `HStack`, we'll see that it's generic over a single `Content` parameter that conforms to view. Looking at the type, we could say that an `HStack` as a single subview. But clearly we know that an `HStack` has multiple subviews!

    The `HStack` receives a single type that conforms to the `View` protocol, but it can *flatten* that into a list of subviews. For example, the two texts in the group above turn into a `TupleView<(Text, Text)>`. The HStack can flatten the tuple view to get a list of the two subviews. A few years ago I wrote more about how [SwiftUI Views are Lists](https://chris.eidhof.nl/post/swiftui-views-are-lists/).

    When a flattened view list turns out to be a single item list it's called a *unary view*, and if it's zero or more items, it's a *multiview*. You can also read about this in [Robb's post](https://movingparts.io/variadic-views-in-swiftui) or my own post on [variadic views](https://chris.eidhof.nl/post/variadic-views/).

    ## Investigating the Problem

    At first, I thought the problem was with `Group`. But it seems to be a problem with the "root view" that renders a SwiftUI view. I believe (but haven't verified) that ultimately, at the very root of our app, there is still some UIKit that renders our root view. If that root view is not a *unary view* the behavior can be unexpected.

    For example, with the code below, the root view is not unary but actually returns two views:

    ```swift
    Group {
        Text("One")
        Text("Two")
    }
    .padding()
    .background(.blue)
    ```

    We can see the exact same behavior difference between previews and the Simulator when we replace the `Group` with an explicit view builder:

    ```swift
    struct ContentView: View {
        var body: some View {
            helper
                .padding()
                .background(.blue)
        }

        @ViewBuilder var helper: some View {
            Text("One")
            Text("Two")
        }
    }
    ```

    To fix the differences in behavior, we can just wrap our `body` in a `VStack`. This way, the `VStack` is the new, stable, unary root view and SwiftUI will have no problems rendering this as expected:

    ```swift
    VStack {
        helper
            .padding()
            .background(.blue)
    }
    ````

    Wrapping in a `VStack` works with both the view builder variant as well as the `Group`, which seems to conform that `Group` is really just a way to get view builder syntax, nothing more.

    > The `onAppear` problem still exists: if you replace the padding and background with an `onAppear`, it'll still only get called once for the entire group. At least this behavior is consistent between the Simulator and previews, and between `Group` and view builders.

    ## Other Possible Problems

    If my hunch is correct, it might be a problem where UIKit meets SwiftUI. There are actually a few places where this happens. Many of the builtin components still use UIKit under the hood and could be a candidate for this behavior. For example, let's try navigation views:

    ```swift
    NavigationStack {
        Group {
            Text("One")
            Text("Two")
        }
        .padding()
        .background(.blue)
    }
    ```

    This renders as expected: the modifiers are applied to the items and not to the group as a whole.

    Sheets are broken, though, ImageRenderer is broken and UIHostingView doesn't work either.

    ```swift
    Text("Hello")
        .sheet(isPresented: .constant(true)) {
            Group {
                Text("One")
                Text("Two")
            }
            .padding()
            .background(.blue)
        }
    ```

    Again, for these broken cases you can fix the behavior by having a stable unary view as the root. I haven't tested this in detail, there are probably more broken implementations.

    ## Conclusion

    I think the behavior of `Group` (or to be more precise: applying modifiers to lists of views) is just too unreliable to use in production. Why does it differ between the Simulator and previews? Why does `onAppear` on a list get called once, but the background gets applied to each item?

    For me, I'm avoiding this use of `Group` entirely and always choose for "stable containers" such as a stack (`VStack` and `ZStack` are my favorite, for some reason `HStack` feels wrong). Going back to the initial example, I would write it like this:

    ```swift
    VStack {
        if let image {
            Image(image)
        } else {
            Text("Loading…")
        }
    }
    .onAppear {  } /* works */
    ```

    Note: all of this is tested with iOS 18.2, hopefully some of this will be fixed in the future.

    """)
}
