---
aliases:
  - /posts/typesafe-url-routes-in-swift.html
date: 2014-08-18
title: Type-safe URL routes in Swift
headline: A micro library
---


While Ash Furrow is working on his [Moya](https://github.com/AshFurrow/Moya) project, I got inspired by his approach, and decided to write a little bit of code to demonstrate a technique I used in Haskell a few years ago.

It uses Swift enums to describe API endpoints. Instead of describing endpoints this with strings, you can use Swift's enums to make it type-safe and well-documented. Let's build an example that wraps a very small part of the [GitHub API](https://developer.github.com/v3/).

There's an API endpoint "zen", which works like this:

    $ curl 'https://api.github.com/zen'
    Favor focus over features.~

There's a different API endpoint "/users/name", which works like this:

    $ curl 'https://api.github.com/users/chriseidhof'
    {
      "login": "chriseidhof",
      "id": 5382,
      ...
    }
    
Now, what we can do is define an enum with a case for all endpoints. Note that the "zen" endpoint doesn't take any parameters, where as the "users" endpoint takes a string parameter (the user name):

    enum Github {
        case Zen
        case UserProfile(String)
    }

We can then define a protocol `Path` that, for a given type, describes how to turn this into a `String` value.

    protocol Path {
        var path : String { get }
    }

Now we can make our Github enum conform to the Path protocol. Because this is just a proof of concept, we don't escape the user's name (which should definitely be done in production code).
     
    extension Github : Path {
        var path: String {
            switch self {
            case .Zen: return "/zen"
            case .UserProfile(let name): return "/users/\(name)"
            }
        }
    }

Having done this work, we can create a route, and get the path out:

    let sample = Github.UserProfile("ashfurrow")
    println(sample.path) 
    // Prints "/users/ashfurrow"
 
In Ash's library, generates full URLs, and also has sample data included for each endpoint (which makes it really convenient when doing TDD). We can create a protocol that helps us with both:

    protocol Moya : Path {
        var baseURL: NSURL { get }
        var sampleData: String { get } // Probably JSON would be better than String
    }

The above protocol says that there has to be a base URL of type NSURL, and that for each value of `Moya` there should be sample data available in string form (this string would probably contain JSON data).

Implementing this for the Github API is simple. For the sample data, we use a switch and depending on the case, we return different sample data. We can even use the user's name in the sample data:
 
    extension Github : Moya {
        var baseURL: NSURL { return NSURL(string: "https://api.github.com") }
        var sampleData: String {
            switch self {
            case .Zen: return "Half measures are as bad as nothing at all."
            case .UserProfile(let name): return "{login: \"\(name)\", id: 100}"
            }
        }
    }

Now we have all the pieces to write a function `url` that, given an object conforming to the `Moya` protocol, will return us a URL. Note that this doesn't depend on the Github enum at all, it'll work on any type that conforms to the `Moya` protocol:
 
    func url(route: Moya) -> NSURL {
        return route.baseURL.URLByAppendingPathComponent(route.path)
    }

We can use it like this:
 
    println(url(sample)) 
    // prints https://api.github.com/users/ashfurrow

I think it's a really nice way of building APIs. The Github enum makes it very clear which endpoints are available, and the form of their parameters. By defining these things once, we can make it much harder for users of this API to make mistakes. For example, it's not possible to pass in a `nil` username, because the `UserProfile` takes a non-optional string. If we wanted to add optional parameters, we have to be explicit about that.

The other nice thing is that all of the above code is independent of any networking library. It's so simple that it could be used with any library, be it [AlamoFire](https://github.com/Alamofire/Alamofire), [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest/) (remember that?) or just plain `NSURLSession`. Enjoy! 

The full code is available as a gist [here](https://gist.github.com/chriseidhof/1fc977ffb856dbcdc113).
