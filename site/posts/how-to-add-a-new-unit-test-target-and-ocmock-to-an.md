---
aliases:
  - /posts/how-to-add-a-new-unit-test-target-and-ocmock-to-an.html
date: 2012-12-03
title: How to add a new Unit Test target and OCMock to an existing XCode project 
---

I had some trouble today trying to add Unit Tests to an existing project that
uses [CocoaPods](http://cocoapods.org). So I decided to do a quick writeup of
how I got it working:&#10;

0.  Create a new project called ‘BetterTodoList’&#10;

1.  Create a new Podfile with the following contents&#10;

``` 
platform :ios, 6.0
pod 'AFNetworking'
```

0.  Close BetterTodoList in XCode, and open the workspace (as instructed by
    CocoaPods)&#10;

1.  Run, and see that everything still works&#10;

2.  Write some legacy code&#10;

3.  Realize you need Unit Tests:&#10;
    
      - File -\> New -\> Target
    
      - Choose Other -\> Cocoa Touch Unit Test Bundle
    
      - Name it “BetterTodoListTests”

4.  Press Cmd+U. If nothing happens, check if Product \> Test is grayed out in
    the menu. In that case, press Cmd+\<, select Test and add the test using the
    + button.&#10;

5.  Add the following lines to your Podfile, and re-run “pod install”&#10;
    
    ``` 
    target 'BetterTodoListTests', :exclusive => true do
    pod 'OCMock' 
    end
    ```

6.  Import `OCMock.h` in one of your files and see that it’s working.&#10;

7.  ?&#10;

8.  Profit&#10;

Addendum: If you still have problems because the test target cannot access the
compiled objects (e.g. “Symbol Not Found” errors), select the project in the
organizer, then select the Test target, go to “Bundle Loader” and add the
following values for both Debug and Release:
`$(BUILT_PRODUCTS_DIR)/BetterTodoList.app/BetterTodoList`&#10;
