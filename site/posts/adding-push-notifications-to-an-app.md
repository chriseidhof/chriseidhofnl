---
aliases:
  - /posts/adding-push-notifications-to-an-app.html
date: 2012-11-01
title: Adding push notifications to an app
---

Last week, I’ve built an app that’s quite simple: there are categories, and in
the categories are messages. People can subscribe to a category and get a push
notification when there’s a new message in the category, or when a significant
change was made to the message. The badge icon should update appropriately,
showing the number of unread messages. There are lots of tricky things when
implementing this, and the point of this article is to explore them.&#10;

In a naive approach, you can start by implement the application delegate’s
`application:didReceiveRemoteNotification`. This method is called when you
receive a push notification. However, it is only called when your application is
running. When your application is not running, this method doesn’t get called.
You also need to implement `application:didFinishLaunchingWithOptions:`, and
check if there is a push notification in the options (this dictionary gets set
when you open the app by clicking on the notification).&#10;

The problem, however, is that not all push notifications arrive. For example, if
you get 5 push notifications, but open the app via the home screen, you will not
get any notification in the options dictionary, and you won’t get a
`didReceiveRemoteNotification` either.&#10;

To do push notifications correctly, you will need to keep a list on the server,
and on application startup your app needs to synchronise with the server. That
way, you can mark the right and also tell the server that you have seen the push
notification.&#10;

Now, when you exit the app you can set the badge count based on the number of
unread push notification. However, the server needs to know this number as well,
so that it can correctly set the badge number in the next push notification that
is sent. When you read a message that was marked by the push notification, you
need to tell the server as well. (Edge-case: when you read the message in
offline mode, you will need to tell the server once you’re back online).&#10;

In order to do push notifications right, the client and server need to
communicate a lot. Hopefully, in your next project, you can read this article so
you don’t have to find these things out while you are programming.&#10;

In a next article, I will sketch the application architecture I used for the app
above.&#10;
