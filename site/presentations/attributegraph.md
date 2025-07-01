Here is an at-home recording of a presentation I gave about the Attribute Graph:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/dCSf9nR6SOQ" title="YouTube video player" frameborder="0" allow="autoplay; encrypted-media; picture-in-picture; web-share" allowfullscreen></iframe>

*Below is the transcript of that talk, with some light edits by an LLM.*


Good morning. This is an at-home or in-the-office recording of my talk that I gave a few weeks ago. I'm not sure if it gets published, so I figured I might as well just record it. It's about the attribute graph, and I want to start off by saying I don't know how this works, but I think we can make some educated guesses based on the information that's out there and based on the dumps you can get. In my head, it kind of makes sense, and it really helps, I think, to understand how SwiftUI rendering works and how SwiftUI can be as efficient as it is.

## Building the Graph

Let's start building up some code and look at the graph. Here we have a simple counter struct with a body, which looks like this in the attribute graph. Then we can add a button, and so that gets added to the graph. We can add a handler and a state property. We can see now that the state property points to the body node, which I think is kind of interesting. So the counter node, whenever it's invalidated, recreates the body node, and whenever the body is invalidated, it recreates the button—or actually not recreates, but more re-evaluates.

Likewise, when the state node is invalidated, it triggers a redraw of the body, so it recomputes the body node. Even though in the code the state is a property of the counter, in the attribute graph, the state actually points to the counter's body, and only if the body accesses that state property. The attribute graph really tracks dependencies. It's not a one-to-one representation of what we write in our code, because there the state would be a child of the counter, but it's really saying if the counter changes, the body needs to be re-evaluated, or if the state changes, the body needs to be recomputed.

We can add a content view node with a body, and then we have two separate subgraphs. Of course, we can make the counter part of our content view's body, and so now the graph looks like this. If we were to invalidate the state property, for example, that would mark it as pending or as potentially needing recomputation. The body would be marked as pending in the button, and so everything down below in the graph.

## Layout Dependencies

Now we can actually add a text node to our content view and an HStack around it, and then the graph looks like this. Again, if we were to invalidate the state property, the body would get recomputed and the button would get recomputed, but the content view will not. What's interesting, though, is if we look at a preview of this, the moment we interact with that sample, we can see the text jumping, and it gets clearer when we switch from 9 to 10. So the text "Hello, world" jumped ever so slightly to the right. Apparently this graph is not the whole story, because if you look at it, changing the state should not render the content view again, right? And yet the HStack is re-rendering itself and repositioning its children. So what's going on?

We can make this step even more clear by adding a frame. If the view is a multiple, the value is a multiple of 2—in other words, if it's an even number—the frame is going to be 100 wide, otherwise 50. We can really see this layout effect in action. So clearly the HStack is laying out again, and yet in the graph we're not taking that into account.

Let's add a print statement as well to the content view body, and we can see now if we tap it, nothing happens, right? So it doesn't get printed. It's clear that the content view's body does not get re-evaluated. If we print the counter body, we can see every time we tap, we can see a log message appended.

## Layout Computers

Let's hide the preview and actually build up the graph here. I quickly removed the frame modifier again so that the graph is a little simpler. The first thing to know is that for each leaf node and for some of the layout nodes, there's something called a layout computer. This is a type that's in the graph, and other layout computers can ask it for, "Hey, what's your size for the given proposal?" and all of those things. The text has a layout computer as well, and the HStack also has a layout computer.

The layout computer of the HStack is actually dependent on both the button and the text. So it's dependent on the button, and it's dependent on the text. Now it makes a little bit more sense how this could work, right? So if we were to invalidate the state node, for example, that would mean the state is invalid, the body, the button, the button layout computer, and that triggers a redraw—or it marks the layout computer of the HStack as invalid. Then whenever that value is requested, it actually recomputes everything that's needed.

This is not the entire story. Out of the layout computer, we get two geometries. Again, this is a simplified version of what the actual graph really does under the hood, but you can think of this as the frame for that button and the frame for that text. So that would be the position and the size. That means that the layout computer might be rerunning, but if the geometry never changed, then everything down below in that graph will also never invalidate.

## Display Lists

Out of those geometries, we get a display list. The display list for the button depends on the button's geometry and on the button itself. Right? If the title changes or anything like that, we need to recreate that display list. The display list is a description of what needs to be rendered on screen. So think of this as a drawing command. The text also has a display list. It also depends on both the geometry as well as the text. Then those are combined into the root display list, which depends on both.

It's actually kind of funny how the display list, if you look into it and look a bit inside the framework, is actually implemented as a preference in SwiftUI. In my mind, preferences sort of take multiple values and combine them into one, right? So in the graph, that sort of means a node with a bunch of incoming edges. That's the combining part.

## Environment Dependencies

Let's look at our preview again because there is more at work here. What's really interesting is if we clear the console here and then actually switch to dark mode, there's no print statements in the console. You can test this out yourself by running the code yourself, and you'll see that no code gets executed here. And yet the view is re-rendering itself completely, right? The background is re-rendered, the text is re-rendered, the button has a different color. So how can it happen? How does it not re-evaluate the graph on the right? We switch back to light mode, we can still see no print statements. So again, what we're seeing here in the graph is not the full story.

It turns out that the text is just a description of what needs to be rendered, right? Like, it's just saying, for example, "Hello, world." In order to actually render this on screen, we need to get a font, we need to get a font size, a color, and so on. So out of the text, we get a resolved text. That's a new node there. This resolved text depends on the text. If the text changes, we also need to re-compute the resolved text. That's actually the value that's used for the layout computer, right? Not the text itself. Likewise, currently the text has an edge going out to the display list, and of course that should be from the resolved text to the display list.

The way to resolve this is through the environment. The resolved text actually depends on a root environment. This environment gets threaded through the program, and as the attribute graph builds up, things that read from the environment will actually be able to create a dependency. That's what's happening with the resolved text. So any time, for example, the root environment changes and the color scheme changes, that means that that node gets invalid, the resolved text, the layout computer, the HStack layout computer, the geometries, the display lists, and finally the root display list. If nothing changes, for example, in the button display list, it won't be re-computed.

The thing that happens is this will all be marked as invalid indefinitely until somebody requests the root display list. That will actually trigger a redraw of or a re-compute of all the nodes that have been marked as dirty or potentially dirty.

## Environment Modifiers

How does that work with modifying the environment? Let's actually remove our counter node here and simplify our HStack to have just two texts. Let's update the graph for this. So the HStack now has two text nodes. They both have a resolved text, and they both depend on the root environment. Now, if we add a large title font, that actually modifies the environment, and we can now see that this environment writing modifier is actually dependent on the root environment, and the resolved texts are not dependent on the root environment anymore. So they now observe this modified environment, and that again happens as the graph is built up.

I guess it looks a little bit more like this in practice. I'm not 100% sure, but what's happening here is that if, let's say, the root environment changes, that will cause a change to the environment writing modifier, which might actually re-compute the body. I'm not sure, but definitely the two texts will change, the resolved texts will change, and the display list down below.

## Conclusion

The attribute graph, as we've seen here, is actually mostly a static thing. It gets, for the most part, built completely statically during initialization of our views. Some parts are dynamic, like if nodes and for each, but most of it is static, and it's all about invalidating stuff, and then the system will request new values, for example, for the display list.

There's so much more to say. However, we're both getting to the limits of my time and the limits of my knowledge. What I found really helpful to understand the basics of this and a lot more advanced stuff as well is the post by Rens about entangling the attribute graph. It's the first post that I read that actually helped me make sense of this, and I think one of the first posts that I read about how any of this stuff works. So it's really helpful to understand stuff.

As far as I know and heard of, the attribute graph is based on this paper about Eval/Vite, and it's a C++ paper, and 80% of the paper is about C++, but the attribute graph's algorithm is described here. By now the algorithm has evolved from the paper, but a lot of this behavior you see makes a lot of sense when you understand the algorithm described in this paper.

If you want to look at the attribute graph yourself, you can use AGDebugKit. It's the easiest way to get printouts of the dot or the graph structure. Be warned because the attribute graph gets really complex very quickly, even for simple examples, so don't be intimidated if you see a massive dot diagram there or graph diagram. On Swift Talk, we tried to implement the algorithm from the paper, and it seems to be what we would expect, and so if you're interested in that, you can have a look at that.

That's really all I have to say. You can find me on Mastodon or BlueSky, and if you want to know more about the layout system and how that works in SwiftUI, then check out the SwiftUI field guide. That's it for me.

## References

- [Untangling the AttributeGraph](https://rensbr.eu/blog/swiftui-attribute-graph/)
- [A System for Efficient and Flexible One-Way Constraint Evaluation in C++](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=9609985dbef43633f4deb88c949a9776e0cd766b)
- [AGDebugKit](https://github.com/OpenSwiftUIProject/AGDebugKit)
- [Swift Talk](https://talk.objc.io/episodes/S01E429-attribute-graph-part-1)
