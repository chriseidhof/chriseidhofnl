---
aliases:
  - /posts/accessing-an-api-using-coredatas-nsincrementalstore.html
date: 2012-02-18
title: Accessing an API using CoreData's NSIncrementalStore
---

*Note: I’ve also posted this article on github as gist, for better readability
of the code: [nsincrementalstore.markdown](https://gist.github.com/1860108).*

In this article, we will see how to use Core Data for accessing your API. We
will use the Bandcamp API as our running example. I’ve only been experimenting
with this code for a few days, so there might be mistakes in there.&#10;

One of the problems with accessing an API is that you typically have API calls
everywhere in your code. If the API changes, there are probably multiple spots
in your code that you have to change too. Your code knows about the structure of
the API results in lots of places, for example, in the [Bandcamp
API](http://bandcamp.com/developer) there is a
[`track`](http://bandcamp.com/developer#track) entity which has the property
`title`. It would be easy to pass the API results around as an NSDictionary and
lookup the title key in that dictionary. However, if they would change it to
`songtitle`, you have to find this everywhere in your code.&#10;

Another problem is that most APIs are not object oriented. Suppose you have an
`Album` entity that has a to-many relationship with a `Track` entity: each album
can have multiple tracks. In your controller, you will probably have multiple
API calls, one for getting the album and another for getting its tracks.&#10;

By using a new feature in Core Data we can solve these problems by adding
another layer on top of the API which allows us to access the API as if it were
an object graph. Entities can be concrete subclasses of `NSManagedObject`.&#10;

First, we will build a regular class that accesses the API and parses the JSON.
Then, we will create a CoreData data model that represents the API in an
object-oriented way. Finally, we will create an `NSIncrementalStore` subclass
and implement the necessary methods to fetch the entities and
relationships.&#10;

**Step 1: Wrap the API**

The first step is to create a simple class that implements your API. Doing this
is straightforward, and I will not go into details here. This is the header file
for the Bandcamp API:&#10;

``` 
@interface BandCampAPI : NSObject
+ (NSArray*)apiRequestEntitiesWithName:(NSString*)name 
                             predicate:(NSPredicate*)predicate;
+ (NSArray*)apiDiscographyForBandWithId:(NSString*)bandId;
@end
```

In summary, you can search for bands, get a band by id, get an album by id, get
a track by id. If you request the info for an album, you also get a list of its
tracks included in the response. Finally, there is a method for getting the
discography of a band.&#10;

To find all bands named “Rue Royale” we can do the following API call:&#10;

``` 
NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Rue Royale"];
NSArray* bands = [BandCampAPI apiRequestEntitiesWithName:@"Band"
                                               predicate:predicate];
```

This will return an `NSArray` with an `NSDictionary` for each found band. Please
have a look at the
[source](https://github.com/chriseidhof/NSIncrementalStore-Test-Project/blob/master/IncrementalStoreTest/BandCampAPI.m)
to see how it is implemented. The result is as following:&#10;

``` 
({
    "band_id" = 4246760315;
    name = "Rue Royale";
    "offsite_url" = "http://rueroyalemusic.com";
    subdomain = rueroyale;
    url = "http://rueroyale.bandcamp.com";
})
```

The discography call looks like this:&#10;

``` 
NSString* sideditchId = [NSString stringWithFormat:@"2721182224"];
NSArray* albums = [BandCampAPI apiDiscographyForBandWithId:sideditchId];
```

And the result like this:&#10;

``` 
({
    "album_id" = 3366378415;
    artist = Sideditch;
    "band_id" = 2721182224;
    downloadable = 1;
    "large_art_url" = "http://f0.bcbits.com/z/70/81/70810089-1.jpg";
    "release_date" = 1267401600;
    "small_art_url" = "http://f0.bcbits.com/z/37/58/3758272301-1.jpg";
    title = "Mary, Me Demo";
    url = "http://sideditch.bandcamp.com/album/mary-me-demo?pk=191";
})
```

Now that we have access to the raw API, we can continue by making an
object-oriented version of the API.&#10;

**Step 2: Define the model**

The next step is to create a new CoreData data model. For each API entity, we
create a corresponding CoreData entity (named `Band`, `Album` and `Track`).
There are properties for all of the entities, and more importantly:
relationships between the entities. For example, the `Album` entity has a
relationship `tracks` which is a to-many relationship to the `Track` entity.
Creating this data model is exactly the same as creating a normal CoreData data
model.&#10;

In this project, I’ve reused all the keys that Bandcamp uses. For example, an
album has a key `large_art_url`, so our entity has a key like that as well.
However, this is not necessary. We can name the keys anything we want, we just
have to make sure that we convert them in our `NSIncrementalStore`
subclass.&#10;

**Step 3: implement the `NSIncrementalStore` methods**

Now the hard bit: creating a subclass of `NSIncrementalStore`. There is a really
interesting article by [Drew
Crawford](http://sealedabstract.com/code/nsincrementalstore-the-future-of-web-services-in-ios-mac-os-x/)
about how to do this. However, it lacks a concrete example. I created a subclass
`BandCampIS` of `NSIncrementalStore`. In the documentation, you can see which
methods to implement. We will start with `executeRequest:withContext:error:`.
This method is called for multiple purposes, but we will now focus on only one
case: when it’s called with an `NSFetchRequest`.&#10;

The first argument is of type `NSPersistentStoreRequest` which is the request we
have to act upon. By inspecting its `requestType` we can turn it into a specific
subclass, such as `NSFetchRequest`. For clarity, the handling code is factored
out into a method `fetchObjects:withContext`, which we will define later.&#10;

``` 
- (id)executeRequest:(NSPersistentStoreRequest*)request 
         withContext:(NSManagedObjectContext*)context 
               error:(NSError**)error {
    if(request.requestType == NSFetchRequestType)
    {
        NSFetchRequest *fetchRequest = (NSFetchRequest*) request;
        if (fetchRequest.resultType==NSManagedObjectResultType) {
            return [self fetchObjects:fetchRequest 
                          withContext:context];
        }
    }
    return nil;
}
```

The `fetchObjects:withContext` method should return an `NSArray` containing
`NSManagedObject` items. In the `fetchObjects:withContext` method, we call the
appropriate API method, and get back an `NSArray` with an `NSDictionary` for
each item. For each item, we create a new `NSManagedObjectID` and cache the
values. Again, this is factored out into a separate method. Then, we call the
`objectWithID` method of `NSManagedObjectContext` to create an empty
`NSManagedObject` for the item.&#10;

``` 
- (id)fetchObjects:(NSFetchRequest*)request 
       withContext:(NSManagedObjectContext*)context {
    NSArray* items = [BandCampAPI apiRequestEntitiesWithName:request.entityName 
                                                   predicate:request.predicate];
    return [items map:^(id item) {
        NSManagedObjectID* oid = [self objectIdForNewObjectOfEntity:request.entity 
                                                        cacheValues:item];
        return [context objectWithID:oid];
    }];
}
```

In the Bandcamp API, each entity can uniquely be identified by its key. For
example, a `Band` entity has the key `band_id` that uniquely identifies a band.
Using the CoreData method `newObjectIDForEntity:referenceObject` we can create
an `NSManagedObjectID` based on this id. Finally, we cache the values for an
entity in the `cache` instance variable (which is an `NSDictionary` with
`NSManagedObjectID` as keys and `NSDictionary` objects as values).&#10;

``` 
- (NSManagedObjectID*)objectIdForNewObjectOfEntity:(NSEntityDescription*)entityDescription
                                       cacheValues:(NSDictionary*)values {
    NSString* nativeKey = [self nativeKeyForEntityName:entityDescription.name];
    id referenceId = [values objectForKey:nativeKey];
    NSManagedObjectID *objectId = [self newObjectIDForEntity:entityDescription 
                                             referenceObject:referenceId];
    [cache setObject:values forKey:objectId];
    return objectId;
}
```

Note that when we created the `NSManagedObject`, the properties were not set.
The managed objects only contain their unique ID. Core Data uses
[faulting](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreData/Articles/cdFaultingUniquing.html)
when you access the properties, and we have to implement another method to
support it: `newValuesForObjectWithID:withContext:error:`. This method will get
called when we access the property of a managed object. Each `NSManagedObject`
is backed by an `NSIncrementalStoreNode` that holds the values. In a database
backend, the `NSIncrementalStoreNode` would correspond to a database record. In
our API, it will be filled with an `NSDictionary` returned from the API. Note
that in the previous method, we already cached this `NSDictionary`, so we don’t
need to do an API request:&#10;

``` 
- (NSIncrementalStoreNode*)newValuesForObjectWithID:(NSManagedObjectID*)objectID 
                                        withContext:(NSManagedObjectContext*)context
                                              error:(NSError**)error {
    NSDictionary* cachedValues = [cache objectForKey:objectID];
    NSIncrementalStoreNode* node = 
        [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                              withValues:cachedValues 
                                                 version:1];
    return node;
}
```

There is one more important method to implement:
`newValueForRelationship:forObjectWithID:withContext:error:`. As you can guess
from its name, this is where we lookup the relationships. We look at the
relationship source and target entity and name, and call the appropriate API
methods to fetch the relationship objects. Again, we cache the API results and
return an `NSArray` with `NSManagedObjectID` for each result.&#10;

We will implement two relationships in this method: `discography`, which relates
a `Band` to its `Album`s, and `tracks` which relates an `Album` with its
`Track`s. In this method, we dispatch on the relationship name. In a more
complicated situation where multiple relationships with the same name exist you
can also inspect the relationship’s entities.&#10;

``` 
- (id)newValueForRelationship:(NSRelationshipDescription*)relationship 
              forObjectWithID:(NSManagedObjectID*)objectID
                  withContext:(NSManagedObjectContext*)context
                        error:(NSError**)error {
    if([relationship.name isEqualToString:@"discography"]) {
        return [self fetchDiscographyForBandWithId:objectID 
                                       albumEntity:relationship.destinationEntity];
    } else if([relationship.name isEqualToString:@"tracks"]) {
        return [self fetchTracksForAlbumWithId:objectID 
                                   trackEntity:relationship.destinationEntity];
    }
    NSLog(@"unknown relatioship: %@", relationship);
    return nil;
}
```

Note that the return value of the method should be an `NSArray` with
`NSManagedObjectID`s, not `NSManagedObject`s\! To give an example, for the
discography we do an API call to fetch the raw data, and then create
`NSManagedObjectID`s for each album returned by the API:&#10;

``` 
- (NSArray*)fetchDiscographyForBandWithId:(NSManagedObjectID*)objectID
                              albumEntity:(NSEntityDescription*)entity {
    id bandId = [self referenceObjectForObjectID:objectID];            
    NSArray* discographyData = [BandCampAPI apiDiscographyForBandWithId:bandId];
    return [discographyData map:^(id album) {
        return [self objectIdForNewObjectOfEntity:entity cacheValues:album];

    }];
}
```

**Usage**

Now we can leverage the power of CoreData to access our API. Consumers of our
model don’t know whether they are accessing an API, an SQLite database or an XML
file. It’s all abstracted away into our `NSIncrementalStore` subclass.&#10;

To give an example, here’s how you can find a band using Core Data:&#10;

``` 
NSEntityDescription *entityDescription = [NSEntityDescription
                                          entityForName:@"Band" inManagedObjectContext:moc];

NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Rue Royale"];
NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
fetchRequest.entity = entityDescription;
fetchRequest.predicate = predicate;

NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
Band* band = [results lastObject];
```

This code will make the appropriate API request and return an object of type
`Band`. The `Band` class is generated from our CoreData model, and all of the
properties are accessible as Objective-C properties.&#10;

When you then want to find the bands albums, it’s as simple as doing:&#10;

``` 
for(Album* album in band.discography) {
  NSLog(@"album title: %@", album.title);
}
```

The nice thing about this code that there are no implementation details which
bleed through. We could change the backend to an SQLite store and the code won’t
break. Additionally, the code is more type-safe: if we mistype a property name
(for example, `discograhpy` instead of `discography`) we get a compiler
error.&#10;

**Next steps / Problems**

Because this is all very new and not too well documented, I might have made a
couple of mistakes. I would be really interested in hearing about it if you do
spot something, and will update this post accordingly.&#10;

All the API calls and Core Data calls are done in a synchronous way. This is not
a good idea in production code, as it will block the main thread. I’m
experimenting myself with how to deal with that, and don’t have a single answer
yet. The
[comments](http://sealedabstract.com/code/nsincrementalstore-the-future-of-web-services-in-ios-mac-os-x/#comments)
on Drew’s article are really helpful.&#10;

Finally, we implemented a readonly API. By implementing some more things in our
`NSIncrementalStore` subclass we can add support for changing, saving, deleting
and creating objects.&#10;

I can imagine it would be really interesting to write a subclass of
`NSIncrementalStore` that can deal with [CouchDB](http://couchdb.apache.org/) or
[Parse](https://parse.com/). Implementing a backend would then be as simple as
defining your CoreData data model and initializing the class and you’re up and
running.&#10;

This is the first long technical blogpost I’ve written, and I would love to hear
your thoughts on it. Especially parts that are not clear or written in a bad
way. Please [email me](mailto:chris@eidhof.nl) with your thoughts.&#10;

**Running the example code**

To run the example code, clone [the
project](https://github.com/chriseidhof/NSIncrementalStore-Test-Project/tree/blogpost)
from github and open it in XCode. I just used a standard iOS template, and
pressing ‘Run’ will not do much. The documentation is in the tests: open
`IncrementalStoreTestTests.m` to see how to use the code. You can run the tests
by pressing *Cmd+U* or *Product \> Test*.&#10;

**References**

[Project on
Github](https://github.com/chriseidhof/NSIncrementalStore-Test-Project/tree/blogpost)  
[SealedAbstract](http://sealedabstract.com/code/nsincrementalstore-the-future-of-web-services-in-ios-mac-os-x/)  
[NSIncrementalStore Programming
Guide](https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/IncrementalStorePG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010706)  
[NSIncrementalStore Class
Reference](https://developer.apple.com/library/mac/#documentation/CoreData/Reference/NSIncrementalStore_Class/Reference/NSIncrementalStore.html#//apple_ref/occ/cl/NSIncrementalStore)  
[Core Data talks](http://developer.apple.com/videos/wwdc/2011/)  
[Core Data Programming
Guide](https://developer.apple.com/library/mac/#documentation/cocoa/conceptual/coredata/cdprogrammingguide.html)
