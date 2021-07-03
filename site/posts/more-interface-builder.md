---
aliases:
  - /posts/more-interface-builder.html
date: 2012-09-23
title: More Interface Builder
---

When I started iPhone programming, I built most of my interfaces in code. It was
much easier: full control over your interface. Sometimes I would start in
Interface Builder, but once I stumbled upon limitations I would rewrite the
whole thing in code.&#10;

After learning some more things about Interface Builder, I started using it more
and more. These days, I try to do almost every UI in Interface Builder. Apple
has made it a lot easier for us, too: designing your table view cells in
Interface Builder was quite easy already, but is even easier with
Storyboards.&#10;

Here’s one example where I used to revert to code, but now use nibs. One of the
projects I worked on required a horizontally paging scrollview. Each page was
for answering a question, and contained a description and a slider. If you want
to play with the example, please download [the
project](https://github.com/chriseidhof/interface-builder-test) from github.
Let’s see how to do this using mostly IB:&#10;

Start by creating a view controller and adding a scroll view to it. Create an
outlet scrollView on the view controller. Then, create a new empty XIB. We add a
single UIView to the XIB with nested subviews (the text label and the slider).
Then, in the view controller, add a method to setup the pages and call it from
`viewDidLoad`. Note that the method is a bit long, normally you would probably
factor it into components:&#10;

``` 
- (void)setupPages {
    pages = [NSMutableArray arrayWithCapacity:NUM_PAGES];

    CGFloat pageWidth = self.scrollView.bounds.size.width;
    CGRect pageFrame = self.scrollView.bounds;

    self.scrollView.contentSize = CGSizeMake(pageWidth*NUM_PAGES, self.scrollView.bounds.size.height);

    for(int i = 0; i < NUM_PAGES; i++) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:pageNibName owner:nil options:nil];
        UIView* pageView = [topLevelObjects lastObject];
        pageFrame.origin.x = pageWidth * i;
        pageView.frame = pageFrame;
        [self.scrollView addSubview:pageView];
        [pages addObject:pageView];
    }
}
```

For this code to work, it’s important that there is only one view at the
top-level of the xib. The above code creates the pages and adds them to the
subviews. However, the separate pages don’t have a way to access the label and
slider. A crude way to do this is give both of them a tag, and use something
like `[pageView viewWithTag:LABEL_TAG]`. Indeed, for small views this can work,
but it gets messy and hard to maintain quickly.&#10;

A better way is to add a new subclass of UIView, named `CEPageView` and change
the root-element of PageView.xib to that `UIView` subclass in the Identity
Inspector. If you open the Assistant Editor, you can create outlets on that
newly created class and connect them to the XIB. Note that normally, you would
drag from a view to the File’s Owner, now you drag to the root element in the
Top Level Objects. Change the body of the for-loop to this:&#10;

``` 
    NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:pageNibName owner:nil options:nil];
    CEPageView* pageView = [topLevelObjects lastObject]; // change
    pageFrame.origin.x = pageWidth * i;
    pageView.frame = pageFrame;
    [self.scrollView addSubview:pageView];
    [pages addObject:pageView];
    // Add these lines:
    pageView.title.text = [NSString stringWithFormat:@"Page %d", i+1];
    pageView.slider.value = i / 3.0;
```

You can also override the layoutSubviews of the UIView if you want some
programmatic control over the layout.&#10;

I hope that this technique will make you more productive. I’m no expert on
Interface Builder, so if you have any tips let me know\!&#10;

*Update*: Ole Begemann recommends using UINib instead of `loadNibNamed:owner`,
it should be faster when loading a nib multiple times. I haven’t tested it yet,
but will check it out. See also: [NSBundle vs. UINib
performance](http://oncocoa.blogspot.de/2011/02/nsbundle-vs-uinib-performance.html)&#10;
