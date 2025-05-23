---
date: 2025-05-06
title: SwiftUI View Model Ownership
---

When we cover SwiftUI's state system in [our workshops](https://www.swiftuifieldguide.com/workshops/), we often get asked: *How can I set up my view model in a view?* There's a bit more to this question, so let's try to spell out the requirements:

- We want our view to create a view model and maintain ownership: when the view goes away, the object should go away.
- We want our view model to be an object (not a struct) and the object should use the [Observation](https://developer.apple.com/documentation/observation) framework.

Getting this right is trickier than expected.

Let's consider a view model that counts the number of people in a room. Here's the model definition:

```swift
@Observable class RoomVM {
    let roomName: String
    var count: Int = 0
    init(roomName: String) {
        self.roomName = roomName
    }
}
```

When we now want to create a `RoomView` we are faced with a choice: we need to think about ownership. When the lifetime of our view model is tied to the lifetime of the `RoomView`, we say that the `RoomView` is the *owner* of our object. That means we should use an `@State` property. When the view model is passed from the outside, we are not the owner, and we should not use an `@State` property.

In our requirements, we wanted the `RoomView` to be the owner. This means we should use an `@State` property. My personal rule of thumb is to always mark all `@State` properties as private and to always initialize them on the same line as the declaration. For example, for a simple `Int` property I'd write:

```swift
struct CounterView: View {
    @State private var value = 0
}
```

If you are unable to use those two rules (marking as private and setting the initial value), you should either reconsider using a `@State` property or you should make sure to pay extra attention to the code you're writing. In our case, we want an API that looks like `RoomView(name: "Main Room")`.

```swift
struct RoomView0: View {
    var name: String
    @State var viewModel: RoomVM = // ...
    var body: some View {
        LabeledContent(viewModel.roomName) {
            Stepper("\(viewModel.count)", value: $viewModel.count)
        }
    }
}
```

## The init Trap

What do we write after the equals sign above? Ideally, we'd write `RoomVM(roomName: name)` but that doesn't compile, because the `name` is not available yet. Luckily after a bit of searching, we'll find a solution somewhere on a blog, forum post or in a video:

```swift
struct RoomView1: View {
    var name: String
    @State var viewModel: RoomVM
    init(name: String) {
        self.name = name
        self.viewModel = RoomVM(roomName: name)
    }

    var body: some View {
        LabeledContent(viewModel.roomName) {
            Stepper("\(viewModel.count)", value: $viewModel.count)
        }
    }
}
```

The code above is broken, and it is not obvious. For example, if you run the following snippet, it works exactly as intended. We can navigate to a room, change the value, and when we navigate away the view model is destroyed.

```swift
struct ContentView: View {
    var rooms = ["Main Room", "Breakout", "Hallway"]
    var body: some View {
        NavigationView {
            List {
                ForEach(rooms, id: \.self) { room in
                    NavigationLink(room) {
                        RoomView1(name: room)
                    }
                }
            }
        }
    }
}
```

Let's now consider a different way of using our `RoomView1`:

```swift
struct ContentView: View {
    var rooms = ["Main Room", "Breakout", "Hallway"]
    @State var selectedRoom: String = "Main Room"
    var body: some View {
        VStack {
            RoomView1(name: selectedRoom)
            Picker("Select a room", selection: $selectedRoom) {
                ForEach(rooms, id: \.self) { room in
                    Text(room)
                }
            }
        }
    }
}
```

When we change the counter for a room, then select a different picker value, we never see the `RoomView` update: it always will show the initial room ("Main Room"). Why does this happen?

In our `RoomView1`'s initializer, we're not actually changing the value of the state property. *When we assign to a state property outside of the view's `body`, we are changing the initial value that's used when that view is created in the [attribute graph](https://talk.objc.io/episodes/S01E438-attribute-graph-part-10).* You can only modify the state's value inside the body of a view.

This is why I have that personal rule of always making the state property as private (so no one can assign from the outside) and initializing it straight away (so I'm not allowed to initialize it in the view's `init`). And yet: we cannot do this for our example above. 

## Towards a Fix

There's no one perfect way to solve this, but here's one approach. Because we have a dependency on `name` in our view model expression, we also need to add an `onChange(of:)`. Each time the name changes, we create a new view model.

```swift
struct RoomView2: View {
    var name: String
    @State var viewModel: RoomVM
    init(name: String) {
        self.name = name
        self.viewModel = RoomVM(roomName: name)
    }

    var body: some View {
        LabeledContent(viewModel.roomName) {
            Stepper("\(viewModel.count)", value: $viewModel.count)
        }
        .onChange(of: name) {
            self.viewModel = RoomVM(roomName: name)
        }
    }
}
```

Another way to think about this is that the `name` uniquely determines the identity of our `RoomView2`. When that name changes, the identity changes and we should recreate our view model. The code above works as expected in all scenarios. It is not quite there yet, though. After I published this article, Kyle asked the following question:

> @chris In the fixed example, is it correct to say that an instance of the view model object will be needlessly created each time the view’s initializer is called by the parent? As in: when you change the selected room in the parent, the child’s initializer is run, name is set to the new name, the view model object is created and then not used (because of the attribute graph as you mentioned), and then the “original” view model is replaced by a third inside of onChanged?
> 
> [Source](https://m.objc.io/@kyle@mister.computer/114461147374335228)

Kyle is absolutely right. The example above does have the correct behavior, but unnecessarily creates and discards new objects everytime the initializer runs.

## A Final Solution?

Here's a variant that creates the `RoomVM` once when the view appears, and only recreates when the `name` property changes:

```swift
struct RoomView3: View {
    var name: String
    @State private var viewModel: RoomVM?

    var body: some View {
        ZStack {
            if let viewModel {
                RoomView3Helper(viewModel: viewModel)
            }
        }
        .onChange(of: name, initial: true) {
            self.viewModel = RoomVM(roomName: name)
        }
    }
}

struct RoomView3Helper: View {
    @Bindable var viewModel: RoomVM

    var body: some View {
        LabeledContent(viewModel.roomName) {
            Stepper("\(viewModel.count)", value: $viewModel.count)
        }
    }
}
```

The code is way less clean than what we started with, but at least it's correct and efficient. I wonder if there's an cleaner way to write the code above, or if this is really what we need to resort to.

## Conclusion

One of the hardest parts about this problem is that, initially, our code seemed to work correctly. It seemed to just do the right thing. It's hard to catch this problem during testing, but as long as you stick to the private/initial value rules, you'll never have that problem. If you do need to break the rule, pay extra attention and add on `onChange(of:)` for every property that your view model depends on.

## Updates

*May 7*: Added a version that doesn't recreate the model every single time the `init runs.
