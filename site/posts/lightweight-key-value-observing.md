---
aliases:
  - /posts/lightweight-key-value-observing.html
date: 2013-10-09
title: Lightweight Key-Value Observing
headline: Making KVO simpler and easier
---

In this article, I’d like to implement a simple class I use for key-value
observing. I think KVO is great, however, for most of what I do, there are two
problems:&#10;

0.  I don’t like the dispatching in
    `observeValueForKeyPath:ofObject:change:context:`. I think it gets messy and
    confusing if you observe more than one object.

1.  You have to balance each *add observer* with a *remove observer*, it would
    be nice if this can be done automatically.

So, off we go. The trick we will use is one I first saw in
[THObserversAndBinders](https://github.com/th-in-gs/THObserversAndBinders), and
this post is basically a description of what they did, but in the most
minimalistic way.&#10;

First, we’ll define the interface for our object:&#10;

``` 
@interface Observer : NSObject
+ (instancetype)observerWithObject:(id)object
                           keyPath:(NSString*)keyPath
                            target:(id)target
                          selector:(SEL)selector;
@end
```

The observer takes four parameters, which are hopefully self-explanatory. I
chose to use the target/action pattern: an alternative would have been blocks,
but then you would have to do the weakSelf/strongSelf dance, and it’s often nice
to have a separate method anyway.&#10;

What we will do is set up the KVO inside the initializer, and remove it in the
`dealloc` method. What this means is that as long as the `Observer` object is
retained, we will have an observer. The way I typically use this, for example,
in a view controller:&#10;

``` 
self.usernameObserver = [Observer observerWithObject:self.user
                                             keyPath:@"name"
                                              target:self
                                            selector:@selector(usernameChanged)];
```

By putting it in a property, we are making sure it gets retained. As soon as our
view controller deallocates, it’ll set the property to nil and the observer will
stop observing.&#10;

In the implementation, it’s important that we keep a weak reference to both the
observed object and the target. If one of the two gets nil, we want to stop
sending messages:&#10;

``` 
@interface Observer ()
@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;
@property (nonatomic, weak) id observedObject;
@property (nonatomic, copy) NSString* keyPath;
@end
```

The initializer sets up the KVO notifications. It uses `self` as the context.
This is necessary if we would ever have a subclass that adds a similar
observer:&#10;

``` 
- (id)initWithObject:(id)object keyPath:(NSString*)keyPath target:(id)target selector:(SEL)selector
{
  if (self) {
    self.target = target;
    self.selector = selector;
    self.observedObject = object;
    self.keyPath = keyPath;
    [object addObserver:self forKeyPath:keyPath options:0 context:self];
  }
  return self;
}
```

When a change happens, we just notify our target, if it still exists:&#10;

``` 
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (context == self) {
    id strongTarget = self.target;
    if ([strongTarget respondsToSelector:self.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [strongTarget performSelector:self.selector];
#pragma clang diagnostic pop
    }
  }
}
```

And finally, in the `dealloc` we remove the observer:&#10;

``` 
- (void)dealloc
{
    id strongObservedObject = self.observedObject;
    if (strongObservedObject) {
        [strongObservedObject removeObserver:self forKeyPath:self.keyPath];
    }
}
```

That’s all there is to it. There are a lot of ways this could be extended: add
blocks support, or my favorite trick: another convenience constructor that call
the action directly the first time. However, I wanted to show the core of the
technique, adjust it to your needs.&#10;

By using this technique you don’t have to remember too much when doing KVO. Just
retain the observers, and set them to nil when you’re done. The rest will happen
automatically.&#10;
