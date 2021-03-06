---
aliases:
  - /posts/swift-tricks.html
date: 2014-07-14
title: Swift Tricks
headline: Some useful functions that make life easier
---


Here are some quick Swift functions that can make your life easier. First, a function that splits up an array into head and tail:

    extension Array {
        var match : (head: T, tail: [T])? {
          return (count > 0) ? (self[0],Array(self[1..<count])) : nil
        }
    }

You can use it like this:

    func map<A,B>(f: A -> B, arr: [A]) -> [B] {
        if let (head,tail) = arr.match {
            return [f(head)] + map(f, tail)
        } else {
            return []
        }
    }

If you lazily want to generate a list of things, but don't really know how many will be needed, you can use a Generator. It turns out there's a type `GeneratorOf` that makes it really easy for us to define one. For example, this is how you can generate an infinite list of numbers:

    func naturalNumbers() -> GeneratorOf<Int> {
        var i = 0
        return GeneratorOf { return i++ }
    }


You can now just iterate over the generator it with `for..in`:

    for x in naturalNumbers() {
        println("x: \(x)")
    }

Finally, a sketch of how you could wrap `NSScanner` to have a more Swift-like API:

    struct Scanner {
        let scanner : NSScanner
    
        init(string: String) {
            scanner = NSScanner(string: string)
        }
        
        func scanInt() -> Int? {
            var int : CInt = 0
            let didScan = scanner.scanInt(&int)
            return didScan ? Int(int) : nil
        }
        
        func scan(token : String) -> Bool {
            return scanner.scanString(token, intoString: nil)
        }
    }

I hope that these snippets will help a bit in writing cleaner Swift code. Enjoy!

