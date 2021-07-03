---
advanced_swift: true
date: 2017-12-08
headline: Comparing structs, enums and protocols
title: Swift Analytics
---

There have been a number of blog posts about the best way to do analytics in Swift:

- John writes about using [enums](https://www.swiftbysundell.com/posts/building-an-enum-based-analytics-system-in-swift).
- Matt writes about using [structs](http://matt.diephouse.com/2017/12/when-not-to-use-an-enum/).
- Dave writes about using [protocols](https://davedelong.com/blog/2017/12/07/misusing-enums/).
- Soroush writes about [subclasses](http://khanlou.com/2017/12/misusing-subclassing/).

Krzysztof [asked](https://twitter.com/kprofic/status/938910246810062848) about whether I would do a function-based version.

I think all solutions are valid. They're different embeddings of the same problem. Another version to consider is the simplest one: just inlining the network calls into your code. Maybe that already does the job, and you're set. 

Now imagine that you find you make mistakes when writing the code. For example, you forget to provide the name, or you mistype the metadata keys. To prevent this, you could wrap up the network calls in functions. Functional programmers call this a *shallow embedding*: you express your domain logic in a very thin wrapper. It's the easiest way to add type-safety to an untyped domain.

A *deep embedding* is when you can also inspect (and possibly modify) the data. This is useful when you write tests, or when you need to change the structure at a later point. Matt's struct-based solution provides the most minimal way to inspect the data: he just bundles up the analytics parameters. By providing type-safe initializers, the construction is made type-safe, even though the actual embedding (a string and a dictionary) loses the type-safety. This is a great choice, unless you need to transform the data afterwords. 

John's enum-based approach is another deep embedding: by providing cases for each possible event, he maintains the structure and type-safety. If you need to transform analytic events (for example, merging multiple events, or changing them in some other way) the enum approach is great: as long as you get out an enum value at the end, you know the data is well-formed.

Dave's protocol-based approach allows you to have multiple different representations for your analytics events. For example, you could use Dave's approach with John's enums, Matt's structs, and Soroush's subclasses, at the same time, as long as they all conform to the protocol. 

Another approach would be to group all the function wrappers in a protocol that you can send events to. Then you could have two implementations: one for testing/serialization, and for direct sending of the events. This is often used with dependency injection.

Each approach above adds a little bit of complexity to the code.

I'm a big fan of using the simplest possible solution for your problem and team:

- If you're a precise programmer and don't care about testing, just inline your network calls
- If you want more type-safety, wrap your network calls in functions
- If you use Matt's struct-based initializer, you know the result is well-formed. 
- If you plan to transform your values and want this to be safe, use John's enums
- If you need ultimate flexibility, use Dave's protocols
