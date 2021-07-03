---
aliases:
  - /posts/implementing-value-objects-in-objective-c.html
date: 2012-12-16
title: Implementing Value Objects in Objective C 
---

[Value Objects](http://en.wikipedia.org/wiki/Value_object) are objects that hold
simple data. This article is about creating such value objects. I use them a lot
in my code, because they are robust and keep the code simple. Note that it’s not
about `NSValue`, but about simple objects with simple data.&#10;

Implementing value objects should be easy, but there are some slightly tricky
bits. So let’s look at the requirements:&#10;

  - We want to create value objects quickly (i.e. an `initWith:`)

  - The created objects should be immutable

  - The created objects should be equal when they have equal values

Suppose we want to create `Person` objects with properties `name` and
`birthDate`, then our interface looks like this:&#10;

``` 
@interface Person : NSObject
- (id)initWithName:(NSString*)name birthDate:(NSDate*)birthDate;
@property (nonatomic, copy, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSDate* birthDate;
@end
```

The important thing to notice here is that the properties are `readonly`.
However, the modern runtime still generates instance variables for us, that are
prefixed by a `_`. Our implementation looks like this:&#10;

``` 
@implementation Person

- (id)initWithName:(NSString*)name birthDate:(NSDate*)birthDate {
  self = [super init];
  if(self) {
    _name = [name copy];
    _birthDate = birthDate;
  }
  return self;
}
@end
```

In the modern runtime, you don’t have to use `synthesize`. If you do, then your
instance variables get different names (without the underscore).&#10;

Now for the equality, we implement the method `isEqual:`. There is an [excellent
article](http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html)
by Mike Ash, however, there is a mistake in there. Following his advice, our
first (incorrect) implementation looks like this:&#10;

``` 
- (BOOL)isEqual:(id)obj {
  if(![obj isKindOfClass:[Person class]]) return NO;

  Person* other = (Person*)obj;
  BOOL nameIsEqual = [_name isEqual:other->_name];
  BOOL dateIsEqual = [_date isEqual:other->_date];
  return nameIsEqual && dateIsEqual;
}
```

There is a problem here: if one of the two properties is `nil`, then `isEqual:`
will return `NO`. This is because methods sent to `nil` always return `NO`, `0`
or `nil`. Even `[nil isEqual:nil]` returns `NO`.&#10;

Therefore, our second, correct implementation looks like this:&#10;

``` 
- (BOOL)isEqual:(id)obj {
  if(![obj isKindOfClass:[Person class]]) return NO;

  Person* other = (Person*)obj;
  BOOL nameIsEqual = _name == _other->_name || [_name isEqual:other->_name];
  BOOL dateIsEqual = _date == _other->_date || [_date isEqual:other->_date];
  return nameIsEqual && dateIsEqual;
}
```

To implement the hashing function, I would like to recommend following Mike’s
advice.&#10;

# Bonus&#10;

Finally, as a bonus, let’s also implement `NSCoding`, so we can serialize our
objects. First change the interface of `Person` to this:&#10;

``` 
@interface Person : NSObject <NSCoding>
```

The implementation is now very simple:&#10;

``` 
- (id)initWithCoder:(NSCoder*)aDecoder {
  self = [super init];
  if(self) {
    _name = [aDecoder decodeObjectForKey:kName]; 
    _date = [aDecoder decodeObjectForKey:kDate]; 
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
  [aCoder encodeObject:_name forKey:kName];
  [aCoder encodeObject:_date forKey:kDate];
}
```

The two constants `kName` and `kDate` are declared in the implementation file,
above the `@implementation` directive:&#10;

``` 
static NSString* const kName = @"name";
static NSString* const kDate = @"date";
```

Voila, now we can create objects, read their properties, serialize them to disk
and read them back in. Some catches: when you add a new property, you have to
make sure to update the code in lots of places:&#10;

0.  Add the property to the interface file

1.  Add the parameter to `initWith:`, and also update the callers of that method

2.  Add a comparison to `isEqual:`

3.  Update the `hash` function

4.  Add the method to both `initWithCoder:` and `encodeWithCoder:`

It helps to have some tests in place that check this for you.&#10;

The full code of the examples (without the `hash` function) is [on
github](https://gist.github.com/78b3ce0edbcdf0d202e2).&#10;

*Update*: changed the `name` attribute to be `copy` instead of `strong`, [thanks
to Christian
Kienle](https://twitter.com/CocoaPimper/status/280335607971074050)&#10;
