import Foundation
import StaticSite
import HTML

struct AboutMe: Rule {
    var body: some Rule {
        WriteNode(outputName: "index.html", node: [
            aboutMe
        ])
        .extraFooterContent(back)
    }

    var back: Node {
        HTML.footer(id: "footer") {
            """
            <a href="/" class="back"><span class="arrow">←</span>Back</a>
            """.fromMarkdown
        }
    }

    @NodeBuilder var aboutMe: Node {
        """
        Hi, I'm Chris!

        I created the [SwiftUI Field Guide](https://www.swiftuifieldguide.com/workshops/) and teach [workshops](https://www.swiftuifieldguide.com/workshops) about Swift and SwiftUI. Together with Florian Kugler, I run [objc.io](https://www.objc.io), where we [write books](https://www.objc.io/books/) and [create videos](https://talk.objc.io). 

        I started my career building websites with PHP, HTML and CSS (actually, CSS wasn't a big thing yet back then). I moved on to writing lots of Haskell (in uni) and Javascript (although I hardly recognize today's Javascript). Towards the end of my uni career iOS came out and I started building iOS apps using the very first public SDK.

        In 2012, I moved from The Netherlands to Berlin. I was frustrated by the lack of English-speaking iOS conferences I could attend, so together with Matt and Peter we organized [UIKonf](https://www.uikonf.com). This was a big deal for me personally, and seeing the first edition was pure magic. Many friendships (and more!) have started during the two editions of UIKonf that we organized, and I'm really proud to have played a part in that.
        
        ## objc.io

        After the first edition of UIKonf, Florian, Daniel and me started [objc.io](https://www.objc.io). We came up with the idea while sitting outside during the hack day following the conference. At first, we put out a [monthly magazine](https://www.objc.io/issues/) with many amazing contributors.

        When Swift was first announced, we figured we were in the perfect position to explain functional programming to the people in the ObjC/Swift ecosystem. Together with [Wouter](https://webspace.science.uu.nl/~swier004/), Florian and me wrote a book called [Functional Swift](https://www.objc.io/books/functional-swift). About a year later I met [Ben](https://mastodon.social/@airspeedswift) at a conference, and we started writing [Advanced Swift](https://www.objc.io/books/advanced-swift/). Another few years later, I met [Matt](https://www.cocoawithlove.com) at a conference and we decided to write [App Architecture](https://www.objc.io/books/app-architecture).

        In between writing those books, we also started [Swift Talk](https://talk.objc.io). This is a weekly video series where we build stuff in Swift. We started in 2016 and have been putting out a weekly episode ever since, covering topics such as parsers, SwiftUI, networking, server-side programming, app architecture and much more.
        
        In 2024 I created the [SwiftUI Field Guide](https://www.swiftuifieldguide.com) as a way to visually teach how SwiftUI's layout system works.

        I enjoy running, cycling and spending lots of time with my young kids. I like building physical things (I'm not very good at it, but I really enjoy woodworking).
        
        ## Conferences

        I enjoy speaking at conferences. Here are two recent talks:
        
        - [SwiftUI Animations](/presentations/swiftui-animations) (Paris, 2024)
        - [Attribute Graph](/presentations/attribute-graph) (Cupertino, 2025)
        
        I'll try to add more presentations here in the future.

        ## Bio
        
        > Chris is the founder of [objc.io](https://www.objc.io) and creator of [SwiftUI Field Guide](https://www.swiftuifieldguide.com/). He wrote multiple books about Swift, runs the [Swift Talk](https://www.objc.io) video series and organizes [SwiftUI workshops](https://swiftuifieldguide.com/workshops/).
        
        ![](/images/chris.jpg)
        
        (Photo by [Jack Hare](https://www.jackharephotography.com))

        """.fromMarkdown
    }
}
