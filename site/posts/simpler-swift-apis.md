---
date: 2023-03-03
headline: Simpler Swift APIs
title: You Don't Need Routes
---

For the Mac app we use during our workshops, we also have a web server with an API. The server handles user registration and some other minor things. We just added support for sending one-way messages (from the instructors to the attendees). This involved the following steps:

- I added endpoints for each separate messages
- I added a route parser for each endpoint
- I added the code to actually handle the endpoint (update the database, etc.)
- I added endpoints to the client library
- I added all the necessary data and wrapper methods to the client library for each endpoint

This is a bit of work, and we are already using a simple trick to make this easier. Because we will only use this API from Swift, our endpoints require that you post JSON to them. For example, to add a message, you can simply send the following `Codable` struct, encoded as JSON:

```swift
struct AddMessage: Codable, Hashable {
    var workshop: String
    var message: Message
}
```

We can share this struct between client and server and they automatically have matching interfaces. As I was out for a walk, it dawned on me that we could also do the same for our endpoints! Instead of having separate routes for each API endpoint, we could just have a single API endpoint that takes in a huge enum and switches on that. We can then share that enum with the client and they'd automatically be in sync.

```swift
public enum APICall: Hashable, Codable {
    case addWorkshop(WorkshopData)
    case addMessage(AddMessage)
    case messages(workshop: String)
    // ...
}
```

This saves us from a lot of manual typing, as we don't need separate endpoints and routes, neither in the client nor the server. We simply add a case to the enum and add a corresponding wrapper call on the client. On the train, I made the change and was able to delete a bunch of code from both client and server.

One possible improvement would be to somehow encode the result type in this enum as well. Our `messages` call will always return a `[Message]` array, but that's not encoded in the type system. However, for now, this greatly simplifies our code. 

I wouldn't recommend this approach when your API is consumed from other languages, as it will probably feel quite weird for those developers. But when you're writing a server that will only be used by Swift clients, this is really nice.
