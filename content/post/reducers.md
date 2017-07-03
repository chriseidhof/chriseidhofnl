+++
title = "Reducers"
headline = "Dealing With Asynchrony"
date = "2017-07-03"
advanced_swift = true
+++

> This blogpost is part of an upcoming project, more about that soon.

Reducers are a way to deal with state changes, and are great for dealing with asynchronous code. They come in a number of different ways, and are used in architectures like [Redux](http://redux.js.org/docs/introduction/Motivation.html), [Elm](https://guide.elm-lang.org/architecture/), [Flux](https://facebook.github.io/flux/) and more. 

Instead of giving a definition up front, we'll look refactor an example app that is well-suited to write with reducers. For a playground with the full code (both [before](https://github.com/chriseidhof/reducers-examples/blob/master/Reducers.playground/Pages/Currency%20Conversion.xcplaygroundpage/Contents.swift) and [after](https://github.com/chriseidhof/reducers-examples/blob/master/Reducers.playground/Pages/Currency%20Conversion%20-%20Reducers.xcplaygroundpage/Contents.swift) refactoring) see [reducers-examples](https://github.com/chriseidhof/reducers-examples) on GitHub.

## Example

To demonstrate reducers, we will write a simple currency conversion app that converts EUR amounts into USD amounts. It has three views: an text field for the input amount, a button to reload the current exchange rate and an output label. The output label will only display the amount if the input amount can be parsed and the current exchange rate are loaded. If the exchanges rates are loaded, changing the input amount should immediately change the output. Here's the code that computes the output rate (this is hooked up to the `.editingChanged` event of the text field):

```swift
var rate: Double?    
@objc func inputChanged() {
    guard let rate = rate else { return }
    guard let text = input.text, let number = Double(text) else { return }
    output.text = "\(number * rate) USD"
}
```

Next up, the code that reloads the exchange rates:

```swift
@objc func reload() {
    URLSession.shared.dataTask(with: ratesURL()) { (data, _, _) in
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? [String:Any],
            let dataDict = dict["rates"] as? [String:Double],
            let rate = dataDict[Currency.usd.rawValue] else { return }
        DispatchQueue.main.async { [weak self] in
            self?.rate = rate
            self?.inputChanged()
        }
    }.resume()
}

```

The code above is hard to test. First of all, there's a dependency on the shared `URLSession`. To make this more testable, we could consider pulling that out into a configurable property. Even if we do that, the code is still hard to test. We'd like to test that the parsing happens correctly, that we switch back to the main thread before updating the UI, that we set the rate and that we finally call `inputChanged()`. The asynchronous code makes it especially hard to verify that our logic is correct.

We can pull out most of the logic into a `State` struct to make the logic easy to test. The `State` struct encapsulates the input amount and the conversion rate, and exposes a single computed property (the output):

```swift
struct State {
    private var inputAmount: Double? = nil
    private var rate: Double? = nil
    var output: Double? {
        guard let i = inputAmount, let r = rate else { return nil }
        return i * r
    }
}
```

Next up, we'll define three messages that this state can receive. The input can change, the reload button could be pressed, or new rate data could be available. The third message is not sent from the outside. Instead of defining these as methods, we'll define the messages as an enum (we'll see why shortly):

```swift
enum Message {
    case inputChanged(String?)
    case ratesAvailable(data: Data?)
    case reload
}
```

Now that we have defined our state and our `Message` enum, we can write a method to interpet messages. Because `State` is a struct, we define it as a `mutating` method `send(_:)`. We switch over the message and interpet it. In case the input changed, we try to parse it. When new rate data is available, we parse it and assign it to `self.rate`. We'll leave out the `reload` case for now.

```swift
mutating func send(_ message: Message) {
    switch message {
    case .inputChanged(let input):
        inputAmount = input.flatMap { Double($0) }
    case .ratesAvailable(data: let data):
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? [String:Any],
            let dataDict = dict["rates"] as? [String:Double],
            let rate = dataDict[Currency.usd.rawValue] else { return }
        self.rate = rate
    case .reload:
        // TODO: load ratesURL() and update the rates
        fatalError()
    }
}
```

In the `.reload` case, we'd like to load the `ratesURL()` and then send the `.ratesAvailable()` message. If we would use `URLSession.sharedSession` directly, we lose our testability. We'd either have to inject the session, mock it, or find a different way to make it testable. Even if we we would do that, we'd have a problem in the `URLSession`'s callback: we cannot update `self` because it's a struct, not a class.

Instead of performing the URL loading side-effect directly, we'll create a `Command` enum that describes the side-effect:

```swift
enum Command {
    case load(URL, onComplete: (Data?) -> Message)
}
```

Note that we cannot use `onComplete` as a callback (because we cannot change the struct value in a callback). Instead, it transforms the optional data back into a `Message`. We'll add `Command?` as a return type for `send(_:)`. If there's no side-effect to be executed, we simply return `nil`.

```swift
mutating func send(_ message: Message) -> Command? {
    switch message {
    case .inputChanged(let input):
        inputAmount = input.flatMap { Double($0) }
        return nil
    case .ratesAvailable(data: let data):
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? [String:Any],
            let dataDict = dict["rates"] as? [String:Double],
            let rate = dataDict[Currency.usd.rawValue] else { return nil }
        self.rate = rate
        return nil
    case .reload:
        return .load(ratesURL(), onComplete: Message.ratesAvailable)
    }
}
```

Note that the code above is completely synchronous. In a test, we can construct a value of `State` and send it any message we want. Afterwards, we can verify that it changed the state as we expected, and that the correct side-effect is executed. For example, in the reload case, we can even test that the `onComplete` is set to the `.ratesAvailable` message. In our initial (non-reducer) code, testing this would involve a lot of mocking and stubbing.

To interpret commands, we can define a separate extension on `State.Command` that interprets a command. Instead of having asynchronous code in our `State`'s logic, we can simply test this `interpret(_:)` method once, in isolation.

```swift
extension State.Command {
    func interpret(_ callback: @escaping (State.Message) -> ()) {
        switch self {
        case let .load(url, onComplete: transform):
            URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
                DispatchQueue.main.async {
                    callback(transform(data))
                }
            }).resume()
        }
    }
}
```

Finally, we need to hook up our `State` to the view controller we're refactoring. Instead of the `rate` property that we had before, we'll now define a `State` property:

```swift
var state = State() {
    didSet {
        self.output.text = state.output.map { "\($0) USD" } ?? ""
    }
}
```

We can also define a `send` method on the view controller. It sends a message to the state, and if there's any `Command`, it interprets that command.

```swift
private func send(_ message: State.Message) {
    state.send(message)?.interpret(self.send)
}
```

The only thing left is sending the correct messages in the view controller's `inputChanged` and `reload` actions:

```swift
@objc func inputChanged() {
    send(.inputChanged(input.text))
}

@objc func reload() {
    send(State.Message.reload)
}
```

Note that it's easy to test `inputChanged` and `reload`. We don't have to mock the state, but just test that the right `Message` is sent. We can then separately test the implementation of `send(_:)` on the state struct.

## Reducers, Defined

Our `send(_:)` method on `State` is defined as a mutating method, and it is a *reducer*. Generally, we could say that the a reducer is a function of type `(inout State, Message) -> Command`, if `State` is a value type. More generally, its type is `(State, Message) -> (State, Command)`.

There is another important requirement in order for a method to be a reducer: it has to be a pure method, with no side-effects. There is no way in Swift to let the compiler enforce this. Instead of reading global state, we have to send `Input` messages to the reducers. And instead of having a side-effect that modifies global state, a reducer returns `Output` messages.

If you have an object-oriented programming background, you might be reminded of objects. Just like objects, reducers encapsulate state and allow only certain messages. However, unlike objects, reducers have no side-effects and are therefore highly testable. We can intercept and inspect both the input and the output messages without having to create mock classes. Reducers don't have asynchronous code; instead, the asynchrony is pushed outside to the code that drives the reducer. This also greatly helps for testability.

Note that instead of a `Message` enum, we could have also defined our messages as `mutating` methods on the `State` type. However, by defining messages as an enum, we gain a lot of flexibility: we can easily check that the right message is sent, we can serialize messages (for example, to send over the network) and we can easily forward them to other parts of the state.

The `State` type with its `send(_:)` method is an example of the ["functional core, imperative shell"](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell) pattern. The reducer is the functional core, and is very easy to test. The view controller's `send` method is the imperative shell: it interprets the side-effects. This pattern can also be applied at a large scale.

For some other examples using reducers, check out my [Swift implementation of The Elm Architecture](https://github.com/chriseidhof/tea-in-swift), or this [awesome list](https://gist.github.com/inamiy/bd257c60e670de8a144b1f97a07bacec) of Elm-inspired frameworks. Matt Gallagher also just wrote a post about [statements, messages and reducers](http://www.cocoawithlove.com/blog/statements-messages-reducers.html)
